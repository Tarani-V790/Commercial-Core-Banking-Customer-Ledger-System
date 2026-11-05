-- =====================================================================
-- Module 6 : Decision Support (DSS) queries for management / executive reporting
-- Covers: JOIN, GROUP BY, HAVING, subqueries, window functions, views
-- =====================================================================
USE core_banking;

-- Q1. Branch-wise deposit position (executive summary)
SELECT b.branch_name, COUNT(DISTINCT a.customer_id) AS customers, COUNT(a.account_id) AS accounts,
       SUM(a.balance) AS total_deposits, ROUND(AVG(a.balance),2) AS avg_balance
FROM branches b JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_deposits DESC;

-- Q2. Customer wealth segmentation (HAVING): customers whose combined balance exceeds Rs 10 lakh
SELECT c.cif_no, c.full_name, COUNT(a.account_id) AS accounts, SUM(a.balance) AS total_balance
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.cif_no, c.full_name
HAVING SUM(a.balance) > 1000000
ORDER BY total_balance DESC;

-- Q3. Monthly transaction volume and value by channel
SELECT DATE_FORMAT(t.txn_date,'%Y-%m') AS month, ch.channel_name,
       COUNT(*) AS txn_count, SUM(le.amount) AS value_cr
FROM transactions t
JOIN channels ch ON ch.channel_id = t.channel_id
JOIN ledger_entries le ON le.txn_id = t.txn_id AND le.entry_type = 'CR'
GROUP BY month, ch.channel_name
ORDER BY month, value_cr DESC;

-- Q4. Top 5 customers by turnover (total debits + credits)
SELECT c.full_name, SUM(le.amount) AS turnover, COUNT(*) AS postings
FROM ledger_entries le
JOIN accounts a ON a.account_id = le.account_id
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY turnover DESC LIMIT 5;

-- Q5. Dormancy watch (subquery): active accounts with no transaction in last 90 days
SELECT a.account_no, c.full_name, a.balance, a.status,
       (SELECT MAX(t.txn_date) FROM ledger_entries le JOIN transactions t ON t.txn_id = le.txn_id
         WHERE le.account_id = a.account_id) AS last_activity
FROM accounts a JOIN customers c ON c.customer_id = a.customer_id
WHERE a.account_id NOT IN (SELECT le.account_id FROM ledger_entries le JOIN transactions t ON t.txn_id = le.txn_id
                           WHERE le.account_id IS NOT NULL AND t.txn_date >= DATE_SUB('2026-11-05', INTERVAL 90 DAY))
ORDER BY last_activity;

-- Q6. Trial balance check: total debits must equal total credits
SELECT SUM(total_debit) AS total_debit, SUM(total_credit) AS total_credit,
       IF(SUM(total_debit)=SUM(total_credit),'BALANCED','OUT OF BALANCE') AS status
FROM v_trial_balance;

-- Q7. Unusual large transactions (subquery): amount > 3 x average transfer amount (AML screening)
SELECT t.txn_ref, t.txn_date, ch.channel_name, le.amount, t.narration
FROM transactions t
JOIN ledger_entries le ON le.txn_id = t.txn_id AND le.entry_type = 'DR' AND le.account_id IS NOT NULL
JOIN channels ch ON ch.channel_id = t.channel_id
WHERE le.amount > 3 * (SELECT AVG(amount) FROM ledger_entries WHERE account_id IS NOT NULL AND entry_type='DR')
ORDER BY le.amount DESC;

-- Q8. Loan portfolio quality by status with NPA ratio
SELECT status, COUNT(*) AS loans, SUM(principal) AS sanctioned, SUM(outstanding) AS outstanding,
       ROUND(100*SUM(outstanding)/(SELECT SUM(outstanding) FROM loans),2) AS pct_of_book
FROM loans GROUP BY status;

-- Q9. KYC compliance exposure (customers with pending KYC and their balances)
SELECT c.kyc_status, c.risk_category, COUNT(DISTINCT c.customer_id) AS customers, COALESCE(SUM(a.balance),0) AS balance_at_risk
FROM customers c LEFT JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.kyc_status, c.risk_category
ORDER BY c.kyc_status, c.risk_category;

-- Q10. Running balance for one account (window function)
SELECT txn_date, txn_ref, entry_type, amount,
       SUM(CASE WHEN entry_type='CR' THEN amount ELSE -amount END)
         OVER (ORDER BY txn_date, txn_ref ROWS UNBOUNDED PRECEDING) AS running_balance, balance_after
FROM v_ledger_statement WHERE account_no = (SELECT account_no FROM accounts ORDER BY account_id LIMIT 1)
ORDER BY txn_date;

-- Q11. Rank customers within each branch by balance (window function)
SELECT * FROM (
  SELECT b.branch_name, c.full_name, SUM(a.balance) AS total_balance,
         RANK() OVER (PARTITION BY b.branch_id ORDER BY SUM(a.balance) DESC) AS branch_rank
  FROM accounts a JOIN customers c ON c.customer_id=a.customer_id JOIN branches b ON b.branch_id=a.branch_id
  GROUP BY b.branch_id, b.branch_name, c.customer_id, c.full_name) r
WHERE branch_rank <= 2;

-- Q12. Executive dashboard KPI row
SELECT (SELECT COUNT(*) FROM customers) AS customers,
       (SELECT COUNT(*) FROM accounts WHERE status='ACTIVE') AS active_accounts,
       (SELECT SUM(balance) FROM accounts) AS total_deposits,
       (SELECT SUM(outstanding) FROM loans WHERE status<>'CLOSED') AS loan_book,
       (SELECT COUNT(*) FROM transactions) AS transactions,
       (SELECT COUNT(*) FROM customers WHERE kyc_status='PENDING') AS kyc_pending;
