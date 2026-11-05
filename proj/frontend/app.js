// Core Banking front-end (vanilla JS, talks to the Node.js REST API)
const $ = id => document.getElementById(id);
let token = null, role = null, lastReport = [];
const inr = n => '₹' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 2 });
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function api(path, method = 'GET', body) {
  const r = await fetch('/api' + path, { method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) }, body: body ? JSON.stringify(body) : undefined });
  const data = await r.json().catch(() => ({}));
  if (r.status === 401 && token) { logout(); }
  if (!r.ok) throw new Error(data.error || 'Request failed');
  return data;
}
function flash(text, bad) { const m = $('msg'); m.textContent = text; m.className = 'msg' + (bad ? ' bad' : ''); m.hidden = false; setTimeout(() => m.hidden = true, 5000); }
const guard = fn => async (...a) => { try { await fn(...a); } catch (e) { flash(e.message, true); } };

function table(el, rows, opts = {}) {
  if (!rows.length) { el.innerHTML = '<tr><td class="muted">No data</td></tr>'; return; }
  const cols = Object.keys(rows[0]).filter(c => !(opts.hide || []).includes(c));
  el.innerHTML = '<thead><tr>' + cols.map(c => `<th>${esc(c.replace(/_/g, ' '))}</th>`).join('') + '</tr></thead><tbody>' +
    rows.map((r, i) => `<tr class="${opts.click ? 'click' : ''}" data-i="${i}">` + cols.map(c => {
      const v = r[c], money = /balance|amount|deposit|value|turnover|principal|outstanding|sanctioned|debit|credit|exposure|risk$/i.test(c) && typeof v === 'number';
      const cls = money ? 'num' : '', badge = /status|risk_category|entry_type/.test(c) ? `<span class="badge ${/VERIFIED|ACTIVE|CR|LOW|BALANCED/.test(v) ? 'b-ok' : /PENDING|MEDIUM|DORMANT/.test(v) ? 'b-warn' : 'b-bad'}">${esc(v)}</span>` : null;
      return `<td class="${cls}">${badge ?? (money ? inr(v) : esc(v))}</td>`; }).join('') + '</tr>').join('') + '</tbody>';
  if (opts.click) el.querySelectorAll('tr.click').forEach(tr => tr.onclick = () => opts.click(rows[tr.dataset.i]));
}

// ----- auth -----
$('loginBtn').onclick = async () => {
  try {
    const d = await api('/login', 'POST', { username: $('u').value, password: $('p').value });
    token = d.token; role = d.role; $('who').textContent = `${d.name} (${d.role})`;
    $('login').hidden = true; $('app').hidden = false; $('p').value = ''; applyRole(); show('dashboard');
  } catch (e) { $('loginErr').textContent = e.message; }
};
$('p').onkeydown = e => { if (e.key === 'Enter') $('loginBtn').click(); };
function logout() { token = null; $('app').hidden = true; $('login').hidden = false; }
$('logout').onclick = logout;
function applyRole() {
  const canPost = ['TELLER', 'MANAGER', 'ADMIN'].includes(role), canRep = ['MANAGER', 'AUDITOR', 'ADMIN'].includes(role);
  document.querySelector('[data-tab=txn]').hidden = !canPost;
  document.querySelector('[data-tab=reports]').hidden = !canRep;
}

// ----- navigation -----
document.querySelectorAll('#nav button').forEach(b => b.onclick = () => show(b.dataset.tab));
const loaders = { dashboard: loadDash, customers: loadCust, accounts: loadAcc, txn: loadTxn, reports: loadReps };
function show(tab) {
  document.querySelectorAll('#nav button').forEach(b => b.classList.toggle('active', b.dataset.tab === tab));
  document.querySelectorAll('main > section').forEach(s => s.hidden = s.id !== 'tab-' + tab);
  guard(loaders[tab])();
}

// ----- dashboard -----
function bars(el, items, fmt) {
  const max = Math.max(...items.map(i => i.v), 1);
  el.innerHTML = items.map(i => `<div class="bar"><span>${esc(i.k)}</span><i style="width:${Math.round(i.v / max * 60)}%"></i><em>${fmt(i.v)}</em></div>`).join('');
}
async function loadDash() {
  const d = await api('/dashboard'), k = d.kpi;
  const cards = [['Customers', k.customers], ['Active accounts', k.active_accounts], ['Total deposits', inr(k.total_deposits)], ['Loan book', inr(k.loan_book)], ['Postings', k.transactions], ['KYC pending', k.kyc_pending]];
  $('kpis').innerHTML = cards.map(c => `<div class="kpi"><b>${c[1]}</b><span>${c[0]}</span></div>`).join('');
  bars($('chartBranch'), d.branches.map(b => ({ k: b.branch_name, v: b.deposits })), inr);
  bars($('chartMonth'), d.monthly.map(m => ({ k: m.month, v: m.txns })), v => v);
}

// ----- customers -----
let customers = [];
async function loadCust() {
  customers = await api('/customers?q=' + encodeURIComponent($('custSearch').value));
  table($('custTable'), customers, { hide: ['customer_id'], click: ['MANAGER', 'ADMIN'].includes(role) ? async c => {
    if (c.kyc_status === 'PENDING' && confirm(`Mark KYC VERIFIED for ${c.full_name}?`)) { await guard(async () => { await api(`/customers/${c.customer_id}/kyc`, 'PATCH', { status: 'VERIFIED' }); flash('KYC verified'); loadCust(); })(); } } : null });
  const br = await api('/branches'); $('c_branch').innerHTML = br.map(b => `<option value="${b.branch_id}">${esc(b.branch_name)}</option>`).join('');
}
$('custSearchBtn').onclick = guard(loadCust);
$('addCust').onclick = guard(async () => {
  const r = await api('/customers', 'POST', { full_name: $('c_name').value.trim(), dob: $('c_dob').value, gender: $('c_gender').value, pan: $('c_pan').value.toUpperCase(), phone: $('c_phone').value, email: $('c_email').value, address: $('c_addr').value, city: $('c_city').value, branch_id: $('c_branch').value });
  flash('Customer created: ' + r.cif_no); loadCust();
});

// ----- accounts -----
async function loadAcc() {
  const [accs, cust, types] = await Promise.all([api('/accounts'), api('/customers'), api('/account-types')]);
  table($('accTable'), accs, { click: a => guard(async () => { $('stmtTitle').textContent = 'Statement – ' + a.account_no + ' (' + a.full_name + ')'; table($('stmtTable'), await api(`/accounts/${a.account_no}/statement`), { hide: ['account_no'] }); })() });
  $('a_cust').innerHTML = cust.map(c => `<option value="${c.customer_id}">${esc(c.cif_no)} – ${esc(c.full_name)} [${c.kyc_status}]</option>`).join('');
  $('a_type').innerHTML = types.map(t => `<option value="${t.type_id}">${esc(t.type_name)} (min ₹${t.min_balance})</option>`).join('');
}
$('addAcc').onclick = guard(async () => {
  const r = await api('/accounts', 'POST', { customer_id: +$('a_cust').value, type_id: +$('a_type').value, opening_deposit: +$('a_dep').value || 0 });
  flash('Account opened: ' + r.account_no); loadAcc();
});

// ----- transactions -----
async function loadTxn() {
  const accs = await api('/accounts');
  const opts = accs.filter(a => a.status === 'ACTIVE').map(a => `<option value="${a.account_no}">${a.account_no} – ${esc(a.full_name)} (${inr(a.balance)})</option>`).join('');
  document.querySelectorAll('.accsel').forEach(s => s.innerHTML = opts);
  table($('txnTable'), await api('/transactions'));
}
const post = (kind, body) => guard(async () => { const r = await api('/transactions/' + kind, 'POST', body()); flash(`Posted ${r.txn_ref}. New balance: ${inr(r.new_balance)}`); loadTxn(); });
$('doDep').onclick = post('deposit', () => ({ account: $('d_acc').value, amount: +$('d_amt').value, narration: $('d_nar').value }));
$('doWd').onclick = post('withdraw', () => ({ account: $('w_acc').value, amount: +$('w_amt').value, narration: $('w_nar').value }));
$('doTr').onclick = post('transfer', () => ({ from: $('t_from').value, to: $('t_to').value, amount: +$('t_amt').value, channel: $('t_ch').value, narration: 'Transfer via ' + $('t_ch').value }));

// ----- DSS reports -----
async function loadReps() { const l = await api('/reports'); $('repSel').innerHTML = l.map(n => `<option>${n}</option>`).join(''); }
$('repRun').onclick = guard(async () => { lastReport = await api('/reports/' + $('repSel').value); table($('repTable'), lastReport); });
$('repCsv').onclick = () => {
  if (!lastReport.length) return flash('Run a report first', true);
  const cols = Object.keys(lastReport[0]);
  const csv = [cols.join(','), ...lastReport.map(r => cols.map(c => `"${String(r[c] ?? '').replace(/"/g, '""')}"`).join(','))].join('\n');
  const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv' })); a.download = $('repSel').value + '.csv'; a.click();
};
