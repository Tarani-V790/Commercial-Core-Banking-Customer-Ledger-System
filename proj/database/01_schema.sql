-- =====================================================================
-- Commercial Core Banking Customer & Ledger System
-- Module 2 (RDBMS, 3NF) + Module 6 (Application Software: MySQL)
-- Compatible with MySQL 8.x / MariaDB 10.5+
-- Run order: 01_schema.sql -> 02_seed_data.sql -> 03_dss_queries.sql
-- =====================================================================
DROP DATABASE IF EXISTS core_banking;
CREATE DATABASE core_banking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE core_banking;

-- ---------- Reference (lookup) tables : removes transitive dependencies (3NF) ----------
CREATE TABLE branches (
  branch_id    INT AUTO_INCREMENT PRIMARY KEY,
  branch_code  VARCHAR(10)  NOT NULL UNIQUE,
  branch_name  VARCHAR(80)  NOT NULL,
  city         VARCHAR(50)  NOT NULL,
  ifsc_code    CHAR(11)     NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE account_types (
  type_id      INT AUTO_INCREMENT PRIMARY KEY,
  type_name    VARCHAR(40)  NOT NULL UNIQUE,
  interest_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
  min_balance  DECIMAL(14,2) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE channels (
  channel_id   INT AUTO_INCREMENT PRIMARY KEY,
  channel_name VARCHAR(30) NOT NULL UNIQUE      -- BRANCH, ATM, UPI, NEFT, IMPS, RTGS, NETBANKING, SYSTEM
) ENGINE=InnoDB;

CREATE TABLE transaction_types (
  txn_type_id  INT AUTO_INCREMENT PRIMARY KEY,
  type_code    VARCHAR(15) NOT NULL UNIQUE,     -- DEPOSIT, WITHDRAWAL, TRANSFER, INTEREST
  description  VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE gl_accounts (                       -- General-ledger (bank's own books)
  gl_id        INT AUTO_INCREMENT PRIMARY KEY,
  gl_code      VARCHAR(10) NOT NULL UNIQUE,
  gl_name      VARCHAR(60) NOT NULL,
  category     ENUM('ASSET','LIABILITY','INCOME','EXPENSE') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE users (                             -- system users (staff)
  user_id      INT AUTO_INCREMENT PRIMARY KEY,
  username     VARCHAR(30) NOT NULL UNIQUE,
  password_hash CHAR(64)   NOT NULL,             -- SHA-256 hex (demo); use bcrypt/argon2 in production
  full_name    VARCHAR(60) NOT NULL,
  role         ENUM('TELLER','MANAGER','AUDITOR','ADMIN') NOT NULL,
  branch_id    INT NULL,
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
) ENGINE=InnoDB;

-- ---------- Core entities ----------
CREATE TABLE customers (
  customer_id  INT AUTO_INCREMENT PRIMARY KEY,
  cif_no       VARCHAR(12) NOT NULL UNIQUE,      -- Customer Information File number
  full_name    VARCHAR(80) NOT NULL,
  dob          DATE        NOT NULL,
  gender       ENUM('M','F','O') NOT NULL,
  pan          CHAR(10)    NOT NULL UNIQUE,
  phone        VARCHAR(15) NOT NULL,
  email        VARCHAR(80) NOT NULL,
  address      VARCHAR(150) NOT NULL,
  city         VARCHAR(50) NOT NULL,
  kyc_status   ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING',
  risk_category ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'LOW',
  branch_id    INT NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  CHECK (email LIKE '%_@_%._%')
) ENGINE=InnoDB;

CREATE TABLE accounts (
  account_id   INT AUTO_INCREMENT PRIMARY KEY,
  account_no   CHAR(12) NOT NULL UNIQUE,
  customer_id  INT NOT NULL,
  type_id      INT NOT NULL,
  branch_id    INT NOT NULL,
  open_date    DATE NOT NULL,
  status       ENUM('ACTIVE','DORMANT','FROZEN','CLOSED') NOT NULL DEFAULT 'ACTIVE',
  balance      DECIMAL(16,2) NOT NULL DEFAULT 0,   -- running balance, maintained by procedures
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (type_id)     REFERENCES account_types(type_id),
  FOREIGN KEY (branch_id)   REFERENCES branches(branch_id),
  CHECK (balance >= 0)
) ENGINE=InnoDB;

CREATE TABLE loans (
  loan_id      INT AUTO_INCREMENT PRIMARY KEY,
  customer_id  INT NOT NULL,
  account_id   INT NOT NULL,                       -- servicing account
  principal    DECIMAL(14,2) NOT NULL,
  interest_pct DECIMAL(5,2)  NOT NULL,
  tenure_months INT NOT NULL,
  outstanding  DECIMAL(14,2) NOT NULL,
  status       ENUM('ACTIVE','CLOSED','NPA') NOT NULL DEFAULT 'ACTIVE',
  disbursed_on DATE NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (account_id)  REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- ---------- Ledger (double-entry) ----------
CREATE TABLE transactions (                        -- one business event = one header row
  txn_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  txn_ref      VARCHAR(20) NOT NULL UNIQUE,
  txn_date     DATETIME NOT NULL,
  txn_type_id  INT NOT NULL,
  channel_id   INT NOT NULL,
  narration    VARCHAR(120),
  status       ENUM('POSTED','REVERSED') NOT NULL DEFAULT 'POSTED',
  FOREIGN KEY (txn_type_id) REFERENCES transaction_types(txn_type_id),
  FOREIGN KEY (channel_id)  REFERENCES channels(channel_id)
) ENGINE=InnoDB;

CREATE TABLE ledger_entries (                      -- each event posts >= 2 lines: sum(DR) = sum(CR)
  entry_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  txn_id       BIGINT NOT NULL,
  account_id   INT NULL,                           -- customer account side ...
  gl_id        INT NULL,                           -- ... or bank GL side (exactly one)
  entry_type   ENUM('DR','CR') NOT NULL,
  amount       DECIMAL(16,2) NOT NULL CHECK (amount > 0),
  balance_after DECIMAL(16,2) NULL,                -- customer account balance after posting
  FOREIGN KEY (txn_id)     REFERENCES transactions(txn_id),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  FOREIGN KEY (gl_id)      REFERENCES gl_accounts(gl_id),
  CHECK ((account_id IS NULL) <> (gl_id IS NULL)),
  INDEX idx_le_acc (account_id), INDEX idx_le_txn (txn_id)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
  log_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_name   VARCHAR(40) NOT NULL,
  record_id    VARCHAR(40) NOT NULL,
  action       VARCHAR(20) NOT NULL,
  details      VARCHAR(255),
  logged_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- Triggers : integrity & audit ----------
DELIMITER $$
CREATE TRIGGER trg_ledger_no_update BEFORE UPDATE ON ledger_entries
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger entries are immutable. Post a reversal instead.';
END$$
CREATE TRIGGER trg_ledger_no_delete BEFORE DELETE ON ledger_entries
FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger entries cannot be deleted.';
END$$
CREATE TRIGGER trg_customer_audit AFTER UPDATE ON customers
FOR EACH ROW BEGIN
  IF OLD.kyc_status <> NEW.kyc_status OR OLD.phone <> NEW.phone OR OLD.email <> NEW.email THEN
    INSERT INTO audit_log(table_name, record_id, action, details)
    VALUES ('customers', NEW.cif_no, 'UPDATE',
            CONCAT('KYC ', OLD.kyc_status, '->', NEW.kyc_status, '; contact changed=',
                   IF(OLD.phone<>NEW.phone OR OLD.email<>NEW.email,'Y','N')));
  END IF;
END$$
DELIMITER ;

-- ---------- Stored procedures : atomic posting ----------
DELIMITER $$
CREATE PROCEDURE sp_deposit(IN p_acc CHAR(12), IN p_amt DECIMAL(16,2), IN p_channel VARCHAR(30),
                            IN p_narr VARCHAR(120), IN p_date DATETIME)
BEGIN
  DECLARE v_id INT; DECLARE v_status VARCHAR(10); DECLARE v_bal DECIMAL(16,2);
  DECLARE v_txn BIGINT; DECLARE v_ref VARCHAR(20);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_amt <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive'; END IF;
  START TRANSACTION;
  SELECT account_id, status, balance INTO v_id, v_status, v_bal FROM accounts WHERE account_no = p_acc FOR UPDATE;
  IF v_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found'; END IF;
  IF v_status <> 'ACTIVE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not active'; END IF;
  SET v_ref = CONCAT('T', DATE_FORMAT(p_date,'%y%m%d'), LPAD(FLOOR(RAND()*1000000),6,'0'));
  INSERT INTO transactions(txn_ref, txn_date, txn_type_id, channel_id, narration)
    VALUES (v_ref, p_date, (SELECT txn_type_id FROM transaction_types WHERE type_code='DEPOSIT'),
            (SELECT channel_id FROM channels WHERE channel_name=p_channel), p_narr);
  SET v_txn = LAST_INSERT_ID();
  UPDATE accounts SET balance = balance + p_amt WHERE account_id = v_id;
  INSERT INTO ledger_entries(txn_id, gl_id, entry_type, amount)
    VALUES (v_txn, (SELECT gl_id FROM gl_accounts WHERE gl_code='1001'), 'DR', p_amt);
  INSERT INTO ledger_entries(txn_id, account_id, entry_type, amount, balance_after)
    VALUES (v_txn, v_id, 'CR', p_amt, v_bal + p_amt);
  COMMIT;
  SELECT v_ref AS txn_ref, v_bal + p_amt AS new_balance;
END$$

CREATE PROCEDURE sp_withdraw(IN p_acc CHAR(12), IN p_amt DECIMAL(16,2), IN p_channel VARCHAR(30),
                             IN p_narr VARCHAR(120), IN p_date DATETIME)
BEGIN
  DECLARE v_id INT; DECLARE v_status VARCHAR(10); DECLARE v_bal DECIMAL(16,2); DECLARE v_min DECIMAL(14,2);
  DECLARE v_txn BIGINT; DECLARE v_ref VARCHAR(20);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_amt <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive'; END IF;
  START TRANSACTION;
  SELECT a.account_id, a.status, a.balance, t.min_balance INTO v_id, v_status, v_bal, v_min
    FROM accounts a JOIN account_types t ON t.type_id = a.type_id WHERE a.account_no = p_acc FOR UPDATE;
  IF v_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found'; END IF;
  IF v_status <> 'ACTIVE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not active'; END IF;
  IF v_bal - p_amt < v_min THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds (minimum balance rule)'; END IF;
  SET v_ref = CONCAT('T', DATE_FORMAT(p_date,'%y%m%d'), LPAD(FLOOR(RAND()*1000000),6,'0'));
  INSERT INTO transactions(txn_ref, txn_date, txn_type_id, channel_id, narration)
    VALUES (v_ref, p_date, (SELECT txn_type_id FROM transaction_types WHERE type_code='WITHDRAWAL'),
            (SELECT channel_id FROM channels WHERE channel_name=p_channel), p_narr);
  SET v_txn = LAST_INSERT_ID();
  UPDATE accounts SET balance = balance - p_amt WHERE account_id = v_id;
  INSERT INTO ledger_entries(txn_id, account_id, entry_type, amount, balance_after)
    VALUES (v_txn, v_id, 'DR', p_amt, v_bal - p_amt);
  INSERT INTO ledger_entries(txn_id, gl_id, entry_type, amount)
    VALUES (v_txn, (SELECT gl_id FROM gl_accounts WHERE gl_code='1001'), 'CR', p_amt);
  COMMIT;
  SELECT v_ref AS txn_ref, v_bal - p_amt AS new_balance;
END$$

CREATE PROCEDURE sp_transfer(IN p_from CHAR(12), IN p_to CHAR(12), IN p_amt DECIMAL(16,2),
                             IN p_channel VARCHAR(30), IN p_narr VARCHAR(120), IN p_date DATETIME)
BEGIN
  DECLARE v_f INT; DECLARE v_t INT; DECLARE v_fb DECIMAL(16,2); DECLARE v_tb DECIMAL(16,2);
  DECLARE v_fs VARCHAR(10); DECLARE v_ts VARCHAR(10); DECLARE v_min DECIMAL(14,2);
  DECLARE v_txn BIGINT; DECLARE v_ref VARCHAR(20);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  IF p_amt <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive'; END IF;
  IF p_from = p_to THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination must differ'; END IF;
  START TRANSACTION;
  -- lock rows in a fixed order (by account_no) to avoid deadlocks
  IF p_from < p_to THEN
    SELECT account_id INTO v_f FROM accounts WHERE account_no = p_from FOR UPDATE;
    SELECT account_id INTO v_t FROM accounts WHERE account_no = p_to   FOR UPDATE;
  ELSE
    SELECT account_id INTO v_t FROM accounts WHERE account_no = p_to   FOR UPDATE;
    SELECT account_id INTO v_f FROM accounts WHERE account_no = p_from FOR UPDATE;
  END IF;
  IF v_f IS NULL OR v_t IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found'; END IF;
  SELECT a.balance, a.status, t.min_balance INTO v_fb, v_fs, v_min
    FROM accounts a JOIN account_types t ON t.type_id=a.type_id WHERE a.account_id = v_f;
  SELECT balance, status INTO v_tb, v_ts FROM accounts WHERE account_id = v_t;
  IF v_fs <> 'ACTIVE' OR v_ts <> 'ACTIVE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Both accounts must be active'; END IF;
  IF v_fb - p_amt < v_min THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds (minimum balance rule)'; END IF;
  SET v_ref = CONCAT('T', DATE_FORMAT(p_date,'%y%m%d'), LPAD(FLOOR(RAND()*1000000),6,'0'));
  INSERT INTO transactions(txn_ref, txn_date, txn_type_id, channel_id, narration)
    VALUES (v_ref, p_date, (SELECT txn_type_id FROM transaction_types WHERE type_code='TRANSFER'),
            (SELECT channel_id FROM channels WHERE channel_name=p_channel), p_narr);
  SET v_txn = LAST_INSERT_ID();
  UPDATE accounts SET balance = balance - p_amt WHERE account_id = v_f;
  UPDATE accounts SET balance = balance + p_amt WHERE account_id = v_t;
  INSERT INTO ledger_entries(txn_id, account_id, entry_type, amount, balance_after) VALUES (v_txn, v_f, 'DR', p_amt, v_fb - p_amt);
  INSERT INTO ledger_entries(txn_id, account_id, entry_type, amount, balance_after) VALUES (v_txn, v_t, 'CR', p_amt, v_tb + p_amt);
  COMMIT;
  SELECT v_ref AS txn_ref, v_fb - p_amt AS new_balance;
END$$

CREATE PROCEDURE sp_post_interest(IN p_acc CHAR(12), IN p_amt DECIMAL(16,2), IN p_date DATETIME)
BEGIN
  DECLARE v_id INT; DECLARE v_bal DECIMAL(16,2); DECLARE v_txn BIGINT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
  START TRANSACTION;
  SELECT account_id, balance INTO v_id, v_bal FROM accounts WHERE account_no = p_acc FOR UPDATE;
  INSERT INTO transactions(txn_ref, txn_date, txn_type_id, channel_id, narration)
    VALUES (CONCAT('I', DATE_FORMAT(p_date,'%y%m%d'), LPAD(FLOOR(RAND()*1000000),6,'0')), p_date,
            (SELECT txn_type_id FROM transaction_types WHERE type_code='INTEREST'),
            (SELECT channel_id FROM channels WHERE channel_name='SYSTEM'), 'Quarterly interest credit');
  SET v_txn = LAST_INSERT_ID();
  UPDATE accounts SET balance = balance + p_amt WHERE account_id = v_id;
  INSERT INTO ledger_entries(txn_id, gl_id, entry_type, amount)
    VALUES (v_txn, (SELECT gl_id FROM gl_accounts WHERE gl_code='5001'), 'DR', p_amt);
  INSERT INTO ledger_entries(txn_id, account_id, entry_type, amount, balance_after)
    VALUES (v_txn, v_id, 'CR', p_amt, v_bal + p_amt);
  COMMIT;
END$$
DELIMITER ;

-- ---------- Views ----------
CREATE VIEW v_account_overview AS
SELECT a.account_no, c.cif_no, c.full_name, t.type_name, b.branch_name, a.status, a.balance, a.open_date
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id
JOIN account_types t ON t.type_id = a.type_id
JOIN branches b ON b.branch_id = a.branch_id;

CREATE VIEW v_ledger_statement AS
SELECT a.account_no, tr.txn_date, tr.txn_ref, tt.type_code, ch.channel_name, tr.narration,
       le.entry_type, le.amount, le.balance_after
FROM ledger_entries le
JOIN accounts a ON a.account_id = le.account_id
JOIN transactions tr ON tr.txn_id = le.txn_id
JOIN transaction_types tt ON tt.txn_type_id = tr.txn_type_id
JOIN channels ch ON ch.channel_id = tr.channel_id;

CREATE VIEW v_trial_balance AS
SELECT 'GL' AS ledger, g.gl_code AS code, g.gl_name AS name,
       COALESCE(SUM(CASE WHEN le.entry_type='DR' THEN le.amount END),0) AS total_debit,
       COALESCE(SUM(CASE WHEN le.entry_type='CR' THEN le.amount END),0) AS total_credit
FROM gl_accounts g LEFT JOIN ledger_entries le ON le.gl_id = g.gl_id GROUP BY g.gl_id, g.gl_code, g.gl_name
UNION ALL
SELECT 'CUSTOMER', 'ALL-ACCOUNTS', 'Customer deposit accounts (aggregate)',
       COALESCE(SUM(CASE WHEN entry_type='DR' THEN amount END),0),
       COALESCE(SUM(CASE WHEN entry_type='CR' THEN amount END),0)
FROM ledger_entries WHERE account_id IS NOT NULL;

-- ---------- Least-privilege application account (used by the Node.js backend) ----------
-- No DELETE / DROP / ALTER rights: the app can never erase ledger history.
CREATE USER IF NOT EXISTS 'bank_app'@'localhost' IDENTIFIED BY 'BankApp#2026';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON core_banking.* TO 'bank_app'@'localhost';
FLUSH PRIVILEGES;
