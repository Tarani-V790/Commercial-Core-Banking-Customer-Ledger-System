// Commercial Core Banking Customer & Ledger System - backend (Node.js + Express + MySQL)
const express = require('express');
const mysql = require('mysql2/promise');
const crypto = require('crypto');
const path = require('path');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'bank_app',
  password: process.env.DB_PASSWORD || 'BankApp#2026',
  database: process.env.DB_NAME || 'core_banking',
  waitForConnections: true, connectionLimit: 10, dateStrings: true, decimalNumbers: true
});

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, '..', '..', 'frontend')));

// ---------- tiny session layer (in-memory tokens; demo-grade, see Ethics report for production controls) ----------
const sessions = new Map();               // token -> {user, role, exp}
const attempts = new Map();               // username -> {count, until}  (brute-force lockout)
const sha256 = s => crypto.createHash('sha256').update(s).digest('hex');
const wrap = fn => (req, res) => fn(req, res).catch(e => {
  const msg = e.sqlState === '45000' ? e.sqlMessage : (e.code === 'ER_DUP_ENTRY' ? 'Duplicate value (PAN/e-mail/CIF already exists)' : 'Server error');
  if (msg === 'Server error') console.error(e);
  res.status(e.sqlState === '45000' || e.code === 'ER_DUP_ENTRY' ? 400 : 500).json({ error: msg });
});
function auth(roles) {
  return (req, res, next) => {
    const t = (req.headers.authorization || '').replace('Bearer ', '');
    const s = sessions.get(t);
    if (!s || s.exp < Date.now()) return res.status(401).json({ error: 'Please log in' });
    if (roles && !roles.includes(s.role)) return res.status(403).json({ error: 'Role not permitted' });
    s.exp = Date.now() + 30 * 60 * 1000;  // 30-min sliding timeout
    req.user = s; next();
  };
}
const mask = v => (v ? v.slice(0, 2) + 'XXXXXX' + v.slice(-2) : v);     // data-privacy masking for PAN/phone

app.post('/api/login', wrap(async (req, res) => {
  const { username = '', password = '' } = req.body;
  const a = attempts.get(username);
  if (a && a.until > Date.now()) return res.status(429).json({ error: 'Account temporarily locked. Try later.' });
  const [rows] = await pool.query('SELECT * FROM users WHERE username=? AND password_hash=?', [username, sha256(password)]);
  if (!rows.length) {
    const c = (a ? a.count : 0) + 1;
    attempts.set(username, { count: c, until: c >= 5 ? Date.now() + 5 * 60000 : 0 });
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  attempts.delete(username);
  const token = crypto.randomBytes(24).toString('hex');
  sessions.set(token, { user: rows[0].username, name: rows[0].full_name, role: rows[0].role, exp: Date.now() + 30 * 60000 });
  res.json({ token, name: rows[0].full_name, role: rows[0].role });
}));

// ---------- dashboard ----------
app.get('/api/dashboard', auth(), wrap(async (req, res) => {
  const [[kpi]] = await pool.query(`SELECT
    (SELECT COUNT(*) FROM customers) customers,
    (SELECT COUNT(*) FROM accounts WHERE status='ACTIVE') active_accounts,
    (SELECT COALESCE(SUM(balance),0) FROM accounts) total_deposits,
    (SELECT COALESCE(SUM(outstanding),0) FROM loans WHERE status<>'CLOSED') loan_book,
    (SELECT COUNT(*) FROM transactions) transactions,
    (SELECT COUNT(*) FROM customers WHERE kyc_status='PENDING') kyc_pending`);
  const [branches] = await pool.query(`SELECT b.branch_name, SUM(a.balance) deposits FROM branches b
    JOIN accounts a ON a.branch_id=b.branch_id GROUP BY b.branch_id, b.branch_name ORDER BY deposits DESC`);
  const [monthly] = await pool.query(`SELECT DATE_FORMAT(t.txn_date,'%Y-%m') month, COUNT(*) txns FROM transactions t GROUP BY month ORDER BY month`);
  res.json({ kpi, branches, monthly });
}));

// ---------- customers ----------
app.get('/api/customers', auth(), wrap(async (req, res) => {
  const q = `%${req.query.q || ''}%`;
  const [rows] = await pool.query(`SELECT c.customer_id, c.cif_no, c.full_name, c.pan, c.phone, c.email, c.city, c.kyc_status,
      c.risk_category, b.branch_name FROM customers c JOIN branches b ON b.branch_id=c.branch_id
      WHERE c.full_name LIKE ? OR c.cif_no LIKE ? OR c.pan LIKE ? ORDER BY c.customer_id`, [q, q, q]);
  const canSee = ['MANAGER', 'ADMIN'].includes(req.user.role);       // role-based PII masking
  res.json(rows.map(r => canSee ? r : { ...r, pan: mask(r.pan), phone: mask(r.phone) }));
}));

app.post('/api/customers', auth(['TELLER', 'MANAGER', 'ADMIN']), wrap(async (req, res) => {
  const b = req.body;
  if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(b.pan || '')) return res.status(400).json({ error: 'Invalid PAN format (e.g. ABCDE1234F)' });
  if (!/^[6-9][0-9]{9}$/.test(b.phone || '')) return res.status(400).json({ error: 'Invalid 10-digit mobile number' });
  if (!b.full_name || !b.dob || !b.email || !b.branch_id) return res.status(400).json({ error: 'Missing required fields' });
  const [[n]] = await pool.query('SELECT COALESCE(MAX(customer_id),0)+1 nxt FROM customers');
  const cif = 'CIF' + (100000 + n.nxt);
  await pool.query(`INSERT INTO customers(cif_no,full_name,dob,gender,pan,phone,email,address,city,branch_id) VALUES (?,?,?,?,?,?,?,?,?,?)`,
    [cif, b.full_name, b.dob, b.gender || 'M', b.pan, b.phone, b.email, b.address || '-', b.city || 'Chennai', b.branch_id]);
  res.status(201).json({ cif_no: cif });
}));

app.patch('/api/customers/:id/kyc', auth(['MANAGER', 'ADMIN']), wrap(async (req, res) => {
  if (!['VERIFIED', 'REJECTED', 'PENDING'].includes(req.body.status)) return res.status(400).json({ error: 'Bad status' });
  await pool.query('UPDATE customers SET kyc_status=? WHERE customer_id=?', [req.body.status, req.params.id]);
  res.json({ ok: true });
}));

// ---------- accounts & ledger ----------
app.get('/api/branches', auth(), wrap(async (req, res) => res.json((await pool.query('SELECT branch_id, branch_name FROM branches'))[0])));
app.get('/api/account-types', auth(), wrap(async (req, res) => res.json((await pool.query('SELECT * FROM account_types'))[0])));

app.get('/api/accounts', auth(), wrap(async (req, res) =>
  res.json((await pool.query('SELECT * FROM v_account_overview ORDER BY account_no'))[0])));

app.post('/api/accounts', auth(['TELLER', 'MANAGER', 'ADMIN']), wrap(async (req, res) => {
  const { customer_id, type_id, opening_deposit = 0 } = req.body;
  const [[c]] = await pool.query('SELECT branch_id, kyc_status FROM customers WHERE customer_id=?', [customer_id]);
  if (!c) return res.status(404).json({ error: 'Customer not found' });
  if (c.kyc_status !== 'VERIFIED') return res.status(400).json({ error: 'KYC must be VERIFIED before opening an account' });
  const [[n]] = await pool.query('SELECT COALESCE(MAX(account_id),0)+1 nxt FROM accounts');
  const accNo = String(c.branch_id).padStart(2, '0') + String(type_id).padStart(2, '0') + String(30000000 + n.nxt * 7919).slice(0, 8);
  await pool.query('INSERT INTO accounts(account_no,customer_id,type_id,branch_id,open_date) VALUES (?,?,?,?,CURDATE())', [accNo, customer_id, type_id, c.branch_id]);
  if (opening_deposit > 0) await pool.query('CALL sp_deposit(?,?,?,?,NOW())', [accNo, opening_deposit, 'BRANCH', 'Account opening deposit']);
  res.status(201).json({ account_no: accNo });
}));

app.get('/api/accounts/:no/statement', auth(), wrap(async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM v_ledger_statement WHERE account_no=? ORDER BY txn_date DESC, txn_ref DESC LIMIT 200', [req.params.no]);
  res.json(rows);
}));

const channels = ['BRANCH', 'ATM', 'UPI', 'NEFT', 'IMPS', 'RTGS', 'NETBANKING'];
app.post('/api/transactions/:kind', auth(['TELLER', 'MANAGER', 'ADMIN']), wrap(async (req, res) => {
  const { kind } = req.params; const b = req.body; const amt = Number(b.amount);
  if (!(amt > 0) || amt > 10000000) return res.status(400).json({ error: 'Amount must be between 0.01 and 1,00,00,000' });
  const ch = channels.includes(b.channel) ? b.channel : 'BRANCH';
  let r;
  if (kind === 'deposit') r = await pool.query('CALL sp_deposit(?,?,?,?,NOW())', [b.account, amt, ch, b.narration || 'Deposit']);
  else if (kind === 'withdraw') r = await pool.query('CALL sp_withdraw(?,?,?,?,NOW())', [b.account, amt, ch, b.narration || 'Withdrawal']);
  else if (kind === 'transfer') r = await pool.query('CALL sp_transfer(?,?,?,?,?,NOW())', [b.from, b.to, amt, ch, b.narration || 'Transfer']);
  else return res.status(404).json({ error: 'Unknown transaction type' });
  res.json(r[0][0][0]);
}));

app.get('/api/transactions', auth(), wrap(async (req, res) => {
  const [rows] = await pool.query(`SELECT t.txn_ref, t.txn_date, tt.type_code, ch.channel_name, t.narration,
      (SELECT SUM(amount) FROM ledger_entries WHERE txn_id=t.txn_id AND entry_type='DR') amount
      FROM transactions t JOIN transaction_types tt ON tt.txn_type_id=t.txn_type_id JOIN channels ch ON ch.channel_id=t.channel_id
      ORDER BY t.txn_date DESC, t.txn_id DESC LIMIT 100`);
  res.json(rows);
}));

// ---------- DSS reports (whitelisted SQL only - no user-supplied SQL: prevents SQL injection) ----------
const REPORTS = {
  'branch-deposits': `SELECT b.branch_name, COUNT(DISTINCT a.customer_id) customers, COUNT(a.account_id) accounts, SUM(a.balance) total_deposits, ROUND(AVG(a.balance),2) avg_balance FROM branches b JOIN accounts a ON a.branch_id=b.branch_id GROUP BY b.branch_id,b.branch_name ORDER BY total_deposits DESC`,
  'wealth-segment': `SELECT c.cif_no, c.full_name, COUNT(a.account_id) accounts, SUM(a.balance) total_balance FROM customers c JOIN accounts a ON a.customer_id=c.customer_id GROUP BY c.customer_id,c.cif_no,c.full_name HAVING SUM(a.balance)>1000000 ORDER BY total_balance DESC`,
  'channel-monthly': `SELECT DATE_FORMAT(t.txn_date,'%Y-%m') month, ch.channel_name, COUNT(*) txn_count, SUM(le.amount) value_cr FROM transactions t JOIN channels ch ON ch.channel_id=t.channel_id JOIN ledger_entries le ON le.txn_id=t.txn_id AND le.entry_type='CR' GROUP BY month,ch.channel_name ORDER BY month,value_cr DESC`,
  'top-customers': `SELECT c.full_name, SUM(le.amount) turnover, COUNT(*) postings FROM ledger_entries le JOIN accounts a ON a.account_id=le.account_id JOIN customers c ON c.customer_id=a.customer_id GROUP BY c.customer_id,c.full_name ORDER BY turnover DESC LIMIT 5`,
  'dormancy': `SELECT a.account_no, c.full_name, a.balance, a.status, (SELECT MAX(t.txn_date) FROM ledger_entries le JOIN transactions t ON t.txn_id=le.txn_id WHERE le.account_id=a.account_id) last_activity FROM accounts a JOIN customers c ON c.customer_id=a.customer_id WHERE a.account_id NOT IN (SELECT le.account_id FROM ledger_entries le JOIN transactions t ON t.txn_id=le.txn_id WHERE le.account_id IS NOT NULL AND t.txn_date>=DATE_SUB(NOW(),INTERVAL 90 DAY)) ORDER BY last_activity`,
  'trial-balance': `SELECT * FROM v_trial_balance`,
  'large-txns': `SELECT t.txn_ref, t.txn_date, ch.channel_name, le.amount, t.narration FROM transactions t JOIN ledger_entries le ON le.txn_id=t.txn_id AND le.entry_type='DR' AND le.account_id IS NOT NULL JOIN channels ch ON ch.channel_id=t.channel_id WHERE le.amount > 3*(SELECT AVG(amount) FROM ledger_entries WHERE account_id IS NOT NULL AND entry_type='DR') ORDER BY le.amount DESC`,
  'loan-quality': `SELECT status, COUNT(*) loans, SUM(principal) sanctioned, SUM(outstanding) outstanding, ROUND(100*SUM(outstanding)/(SELECT SUM(outstanding) FROM loans),2) pct_of_book FROM loans GROUP BY status`,
  'kyc-exposure': `SELECT c.kyc_status, c.risk_category, COUNT(DISTINCT c.customer_id) customers, COALESCE(SUM(a.balance),0) balance_at_risk FROM customers c LEFT JOIN accounts a ON a.customer_id=c.customer_id GROUP BY c.kyc_status,c.risk_category ORDER BY c.kyc_status,c.risk_category`,
  'audit-log': `SELECT * FROM audit_log ORDER BY log_id DESC LIMIT 100`
};
app.get('/api/reports', auth(), (req, res) => res.json(Object.keys(REPORTS)));
app.get('/api/reports/:name', auth(['MANAGER', 'AUDITOR', 'ADMIN']), wrap(async (req, res) => {
  const sql = REPORTS[req.params.name];
  if (!sql) return res.status(404).json({ error: 'Unknown report' });
  res.json((await pool.query(sql))[0]);
}));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Core Banking running on http://localhost:${PORT}`));
