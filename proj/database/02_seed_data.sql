-- Seed data (generated with fixed random seed). All balances are produced by calling the posting procedures,
-- so the ledger and account balances are consistent by construction.
USE core_banking;

INSERT INTO branches(branch_code,branch_name,city,ifsc_code) VALUES
('CCB001','T. Nagar Main','Chennai','CCBN0000001'),
('CCB002','Anna Nagar','Chennai','CCBN0000002'),
('CCB003','Adyar','Chennai','CCBN0000003'),
('CCB004','RS Puram','Coimbatore','CCBN0000004');
INSERT INTO account_types(type_name,interest_pct,min_balance) VALUES
('SAVINGS',3.50,1000),('CURRENT',0.00,5000),('SALARY',3.00,0),('RECURRING',6.00,500);
INSERT INTO channels(channel_name) VALUES ('BRANCH'),('ATM'),('UPI'),('NEFT'),('IMPS'),('RTGS'),('NETBANKING'),('SYSTEM');
INSERT INTO transaction_types(type_code,description) VALUES
('DEPOSIT','Cash or cheque deposit'),('WITHDRAWAL','Cash withdrawal'),('TRANSFER','Account to account transfer'),('INTEREST','Interest credit');
INSERT INTO gl_accounts(gl_code,gl_name,category) VALUES
('1001','Cash in Hand','ASSET'),('2001','Customer Deposits Control','LIABILITY'),('4001','Fee & Commission Income','INCOME'),('5001','Interest Expense on Deposits','EXPENSE');
INSERT INTO users(username,password_hash,full_name,role,branch_id) VALUES
('admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','System Administrator','ADMIN',NULL),
('teller1','d277f25b136e402488431a226b652b2bff919188028af250d9dab860e2c436fd','Priya Raman','TELLER',1),
('manager1','866485796cfa8d7c0cf7111640205b83076433547577511d81f8030ae99ecea5','Karthik Subramanian','MANAGER',1),
('auditor1','5b92db4dfb561dc69c949f34d36f5db0f8b30811be3a2949d85c5001279e9b1a','Meena Iyer','AUDITOR',NULL);
INSERT INTO customers(cif_no,full_name,dob,gender,pan,phone,email,address,city,kyc_status,risk_category,branch_id,created_at) VALUES
('CIF100001','Arjun Venkatesh','1985-03-14','M','ABCDE1037G','9840007919','arjun1@example.in','11, Gandhi Road, Chennai','Chennai','VERIFIED','LOW',1,'2026-02-11 10:00:00'),
('CIF100002','Lakshmi Narayanan','1979-11-02','F','ABCDE1074H','9840015838','lakshmi2@example.in','12, Gandhi Road, Chennai','Chennai','VERIFIED','LOW',1,'2026-03-12 10:00:00'),
('CIF100003','Mohammed Faizal','1990-07-21','M','ABCDE1111J','9840023757','mohammed3@example.in','13, Gandhi Road, Chennai','Chennai','VERIFIED','MEDIUM',2,'2026-04-13 10:00:00'),
('CIF100004','Divya Krishnan','1995-01-30','F','ABCDE1148K','9840031676','divya4@example.in','14, Gandhi Road, Chennai','Chennai','VERIFIED','LOW',2,'2026-05-14 10:00:00'),
('CIF100005','Suresh Babu','1972-05-09','M','ABCDE1185L','9840039595','suresh5@example.in','15, Gandhi Road, Chennai','Chennai','VERIFIED','LOW',3,'2026-06-15 10:00:00'),
('CIF100006','Anitha Rajan','1988-09-17','F','ABCDE1222M','9840047514','anitha6@example.in','16, Gandhi Road, Chennai','Chennai','VERIFIED','MEDIUM',3,'2026-01-16 10:00:00'),
('CIF100007','Ramesh Kumar','1969-12-25','M','ABCDE1259N','9840055433','ramesh7@example.in','17, Gandhi Road, Coimbatore','Coimbatore','VERIFIED','LOW',4,'2026-02-17 10:00:00'),
('CIF100008','Sangeetha Pillai','1992-04-04','F','ABCDE1296P','9840063352','sangeetha8@example.in','18, Gandhi Road, Coimbatore','Coimbatore','VERIFIED','LOW',4,'2026-03-18 10:00:00'),
('CIF100009','Vignesh Murugan','1998-08-12','M','ABCDE1333Q','9840071271','vignesh9@example.in','19, Gandhi Road, Chennai','Chennai','PENDING','LOW',1,'2026-04-10 10:00:00'),
('CIF100010','Fathima Begum','1983-06-27','F','ABCDE1370R','9840079190','fathima10@example.in','20, Gandhi Road, Chennai','Chennai','VERIFIED','HIGH',2,'2026-05-11 10:00:00'),
('CIF100011','Harish Chandran','1976-02-18','M','ABCDE1407S','9840087109','harish11@example.in','21, Gandhi Road, Chennai','Chennai','VERIFIED','LOW',3,'2026-06-12 10:00:00'),
('CIF100012','Nandhini Sekar','1994-10-05','F','ABCDE1444T','9840095028','nandhini12@example.in','22, Gandhi Road, Chennai','Chennai','PENDING','LOW',1,'2026-01-13 10:00:00'),
('CIF100013','Gokul Prasad','1987-12-11','M','ABCDE1481F','9840102947','gokul13@example.in','23, Gandhi Road, Coimbatore','Coimbatore','VERIFIED','MEDIUM',4,'2026-02-14 10:00:00'),
('CIF100014','Tamil Selvi Traders (Prop. K. Selvam)','1974-03-03','M','ABCDE1518G','9840110866','tamil14@example.in','24, Gandhi Road, Chennai','Chennai','VERIFIED','HIGH',1,'2026-03-15 10:00:00');
INSERT INTO accounts(account_no,customer_id,type_id,branch_id,open_date,status,balance) VALUES
('010110013579',1,1,1,'2026-02-02','ACTIVE',0),
('010310027158',1,3,1,'2026-03-03','ACTIVE',0),
('010110040737',2,1,1,'2026-04-04','ACTIVE',0),
('020110054316',3,1,2,'2026-05-05','ACTIVE',0),
('020210067895',3,2,2,'2026-01-06','ACTIVE',0),
('020310081474',4,3,2,'2026-02-07','ACTIVE',0),
('030110095053',5,1,3,'2026-03-08','ACTIVE',0),
('030110108632',6,1,3,'2026-04-01','ACTIVE',0),
('040210122211',7,2,4,'2026-05-02','ACTIVE',0),
('040110135790',7,1,4,'2026-01-03','ACTIVE',0),
('040110149369',8,1,4,'2026-02-04','ACTIVE',0),
('020210162948',10,2,2,'2026-03-05','ACTIVE',0),
('030110176527',11,1,3,'2026-04-06','ACTIVE',0),
('010110190106',12,1,1,'2026-05-07','ACTIVE',0),
('040310203685',13,3,4,'2026-01-08','ACTIVE',0),
('010210217264',14,2,1,'2026-02-01','ACTIVE',0),
('010110230843',14,1,1,'2026-03-02','ACTIVE',0),
('030410244422',5,4,3,'2026-04-03','ACTIVE',0);

-- Transactions posted through stored procedures (chronological)
CALL sp_deposit('010110013579',25000,'BRANCH','Account opening deposit','2026-07-01 10:00:00');
CALL sp_deposit('010310027158',75000,'BRANCH','Account opening deposit','2026-07-01 11:00:00');
CALL sp_deposit('010110040737',250000,'BRANCH','Account opening deposit','2026-07-01 12:00:00');
CALL sp_deposit('020110054316',250000,'BRANCH','Account opening deposit','2026-07-01 13:00:00');
CALL sp_deposit('020210067895',500000,'BRANCH','Account opening deposit','2026-07-01 14:00:00');
CALL sp_deposit('020310081474',900000,'BRANCH','Account opening deposit','2026-07-01 15:00:00');
CALL sp_deposit('030110095053',25000,'BRANCH','Account opening deposit','2026-07-01 16:00:00');
CALL sp_deposit('030110108632',40000,'BRANCH','Account opening deposit','2026-07-01 17:00:00');
CALL sp_deposit('040210122211',250000,'BRANCH','Account opening deposit','2026-07-01 18:00:00');
CALL sp_deposit('040110135790',250000,'BRANCH','Account opening deposit','2026-07-01 19:00:00');
CALL sp_deposit('040110149369',250000,'BRANCH','Account opening deposit','2026-07-01 20:00:00');
CALL sp_deposit('020210162948',120000,'BRANCH','Account opening deposit','2026-07-01 21:00:00');
CALL sp_deposit('030110176527',900000,'BRANCH','Account opening deposit','2026-07-01 22:00:00');
CALL sp_deposit('010110190106',250000,'BRANCH','Account opening deposit','2026-07-01 23:00:00');
CALL sp_deposit('040310203685',250000,'BRANCH','Account opening deposit','2026-07-02 00:00:00');
CALL sp_deposit('010210217264',900000,'BRANCH','Account opening deposit','2026-07-02 01:00:00');
CALL sp_deposit('010110230843',500000,'BRANCH','Account opening deposit','2026-07-02 02:00:00');
CALL sp_deposit('030410244422',900000,'BRANCH','Account opening deposit','2026-07-02 03:00:00');
CALL sp_withdraw('030410244422',40000,'ATM','Cash withdrawal','2026-07-03 19:37:00');
CALL sp_transfer('010310027158','010210217264',9000,'IMPS','Invoice payment','2026-07-04 16:24:00');
CALL sp_deposit('040210122211',150000,'NETBANKING','Salary credit','2026-07-04 16:58:00');
CALL sp_deposit('030110108632',8000,'BRANCH','Salary credit','2026-07-05 14:15:00');
CALL sp_withdraw('040210122211',5000,'ATM','ATM withdrawal','2026-07-05 21:34:00');
CALL sp_transfer('010110230843','020310081474',1500,'RTGS','Loan EMI','2026-07-06 04:20:00');
CALL sp_withdraw('020110054316',20000,'BRANCH','Cash withdrawal','2026-07-06 07:55:00');
CALL sp_deposit('010110013579',2000,'BRANCH','Salary credit','2026-07-06 14:34:00');
CALL sp_deposit('040310203685',2000,'NETBANKING','Salary credit','2026-07-06 17:06:00');
CALL sp_withdraw('010110013579',5000,'BRANCH','Rent payment','2026-07-07 12:53:00');
CALL sp_transfer('040310203685','010310027158',95000,'IMPS','Invoice payment','2026-07-07 18:55:00');
CALL sp_withdraw('030410244422',40000,'BRANCH','Utility bills','2026-07-08 09:43:00');
CALL sp_withdraw('030110108632',10000,'BRANCH','Rent payment','2026-07-08 12:46:00');
CALL sp_transfer('010110230843','010210217264',200000,'NEFT','Loan EMI','2026-07-08 14:59:00');
CALL sp_transfer('010110013579','030410244422',9000,'NEFT','Loan EMI','2026-07-09 01:00:00');
CALL sp_transfer('030110095053','040210122211',9000,'IMPS','Loan EMI','2026-07-10 16:21:00');
CALL sp_withdraw('030110108632',2000,'ATM','Rent payment','2026-07-10 17:13:00');
CALL sp_withdraw('010110230843',20000,'ATM','Utility bills','2026-07-12 15:04:00');
CALL sp_transfer('040110135790','020210067895',200000,'NEFT','Family support','2026-07-13 03:05:00');
CALL sp_withdraw('020110054316',20000,'BRANCH','Cash withdrawal','2026-07-13 10:09:00');
CALL sp_deposit('020210067895',60000,'NETBANKING','Cash deposit','2026-07-13 22:18:00');
CALL sp_transfer('040110149369','040210122211',9000,'UPI','Supplier payment','2026-07-13 23:31:00');
CALL sp_withdraw('010110040737',10000,'BRANCH','ATM withdrawal','2026-07-14 03:29:00');
CALL sp_withdraw('040210122211',40000,'BRANCH','Cash withdrawal','2026-07-17 11:48:00');
CALL sp_deposit('020110054316',8000,'NETBANKING','Cash deposit','2026-07-17 22:55:00');
CALL sp_deposit('010110040737',2000,'BRANCH','Business receipts','2026-07-18 11:26:00');
CALL sp_transfer('010310027158','040310203685',95000,'UPI','Fund transfer','2026-07-19 00:51:00');
CALL sp_deposit('040210122211',2000,'BRANCH','Cash deposit','2026-07-19 02:25:00');
CALL sp_transfer('010110230843','040110149369',22000,'IMPS','Supplier payment','2026-07-20 03:54:00');
CALL sp_deposit('010110040737',30000,'BRANCH','Cheque deposit','2026-07-20 13:05:00');
CALL sp_transfer('020110054316','030410244422',9000,'UPI','Fund transfer','2026-07-21 08:25:00');
CALL sp_deposit('020310081474',60000,'NETBANKING','Cash deposit','2026-07-21 17:29:00');
CALL sp_withdraw('010110013579',5000,'BRANCH','ATM withdrawal','2026-07-22 02:09:00');
CALL sp_deposit('030110176527',30000,'NETBANKING','Cash deposit','2026-07-22 10:07:00');
CALL sp_withdraw('030110108632',10000,'ATM','Rent payment','2026-07-23 07:33:00');
CALL sp_withdraw('010110230843',10000,'BRANCH','ATM withdrawal','2026-07-23 12:42:00');
CALL sp_deposit('010210217264',2000,'BRANCH','Salary credit','2026-07-23 20:27:00');
CALL sp_deposit('020210067895',15000,'NETBANKING','Cash deposit','2026-07-25 09:48:00');
CALL sp_deposit('030110108632',8000,'NETBANKING','Business receipts','2026-07-25 12:11:00');
CALL sp_deposit('030410244422',60000,'BRANCH','Business receipts','2026-07-26 14:53:00');
CALL sp_transfer('030110176527','040310203685',200000,'IMPS','Loan EMI','2026-07-26 16:14:00');
CALL sp_transfer('030410244422','010310027158',9000,'IMPS','Family support','2026-07-26 17:05:00');
CALL sp_transfer('030410244422','010110230843',9000,'UPI','Supplier payment','2026-07-27 15:39:00');
CALL sp_withdraw('020310081474',5000,'BRANCH','Rent payment','2026-07-28 04:46:00');
CALL sp_withdraw('010210217264',40000,'BRANCH','Utility bills','2026-07-30 02:13:00');
CALL sp_deposit('020110054316',5000,'NETBANKING','Cheque deposit','2026-07-30 04:42:00');
CALL sp_withdraw('010110230843',1000,'ATM','Rent payment','2026-07-30 11:45:00');
CALL sp_deposit('010310027158',2000,'NETBANKING','Business receipts','2026-07-30 12:29:00');
CALL sp_transfer('040210122211','020210067895',50000,'RTGS','Loan EMI','2026-07-31 03:35:00');
CALL sp_deposit('030110176527',8000,'NETBANKING','Cash deposit','2026-07-31 07:07:00');
CALL sp_transfer('030410244422','010310027158',1500,'NEFT','Invoice payment','2026-08-01 05:48:00');
CALL sp_withdraw('030110108632',10000,'ATM','Rent payment','2026-08-01 05:57:00');
CALL sp_withdraw('040110149369',2000,'BRANCH','Rent payment','2026-08-01 17:51:00');
CALL sp_deposit('010110230843',8000,'NETBANKING','Salary credit','2026-08-02 12:39:00');
CALL sp_transfer('040210122211','030110095053',1500,'UPI','Invoice payment','2026-08-02 17:26:00');
CALL sp_deposit('030110095053',8000,'BRANCH','Business receipts','2026-08-03 17:27:00');
CALL sp_transfer('010310027158','030410244422',22000,'RTGS','Loan EMI','2026-08-04 06:10:00');
CALL sp_deposit('010110230843',8000,'BRANCH','Salary credit','2026-08-04 08:07:00');
CALL sp_deposit('030410244422',60000,'NETBANKING','Cheque deposit','2026-08-06 11:28:00');
CALL sp_deposit('010110230843',8000,'NETBANKING','Business receipts','2026-08-06 12:25:00');
CALL sp_deposit('010110230843',150000,'NETBANKING','Salary credit','2026-08-07 09:00:00');
CALL sp_transfer('010110040737','030110108632',95000,'RTGS','Family support','2026-08-08 05:23:00');
CALL sp_deposit('030110095053',5000,'BRANCH','Cash deposit','2026-08-08 06:45:00');
CALL sp_deposit('030410244422',150000,'NETBANKING','Salary credit','2026-08-08 16:11:00');
CALL sp_deposit('030110095053',30000,'NETBANKING','Salary credit','2026-08-09 14:38:00');
CALL sp_withdraw('040210122211',10000,'ATM','Utility bills','2026-08-10 05:06:00');
CALL sp_deposit('030110176527',15000,'NETBANKING','Salary credit','2026-08-11 01:22:00');
CALL sp_deposit('030410244422',15000,'NETBANKING','Cheque deposit','2026-08-11 04:35:00');
CALL sp_withdraw('030110108632',5000,'BRANCH','Rent payment','2026-08-13 20:07:00');
CALL sp_deposit('040110135790',2000,'BRANCH','Salary credit','2026-08-13 20:15:00');
CALL sp_deposit('040110149369',150000,'NETBANKING','Cash deposit','2026-08-13 20:30:00');
CALL sp_transfer('040210122211','020310081474',200000,'UPI','Family support','2026-08-14 14:45:00');
CALL sp_deposit('030110108632',30000,'BRANCH','Cash deposit','2026-08-14 15:00:00');
CALL sp_withdraw('030410244422',40000,'BRANCH','Cash withdrawal','2026-08-15 07:29:00');
CALL sp_transfer('040110135790','020110054316',50000,'UPI','Loan EMI','2026-08-16 06:53:00');
CALL sp_deposit('030410244422',15000,'BRANCH','Business receipts','2026-08-16 19:12:00');
CALL sp_transfer('010210217264','040310203685',95000,'RTGS','Supplier payment','2026-08-17 03:23:00');
CALL sp_withdraw('040310203685',40000,'ATM','Rent payment','2026-08-19 17:59:00');
CALL sp_deposit('010210217264',8000,'BRANCH','Business receipts','2026-08-20 02:45:00');
CALL sp_transfer('030410244422','040310203685',22000,'RTGS','Family support','2026-08-20 07:35:00');
CALL sp_withdraw('010110230843',2000,'ATM','Utility bills','2026-08-22 09:15:00');
CALL sp_deposit('040310203685',15000,'NETBANKING','Cheque deposit','2026-08-22 19:52:00');
CALL sp_withdraw('010110040737',10000,'BRANCH','Rent payment','2026-08-22 20:35:00');
CALL sp_withdraw('040310203685',2000,'BRANCH','Cash withdrawal','2026-08-23 00:22:00');
CALL sp_transfer('030410244422','030110095053',50000,'IMPS','Loan EMI','2026-08-23 07:48:00');
CALL sp_withdraw('020210067895',2000,'BRANCH','Cash withdrawal','2026-08-23 15:47:00');
CALL sp_transfer('020210067895','030110108632',4000,'NEFT','Invoice payment','2026-08-25 05:12:00');
CALL sp_deposit('010310027158',15000,'BRANCH','Business receipts','2026-08-25 22:47:00');
CALL sp_transfer('010110040737','040310203685',50000,'NEFT','Fund transfer','2026-08-27 08:48:00');
CALL sp_withdraw('020110054316',20000,'BRANCH','ATM withdrawal','2026-08-28 04:33:00');
CALL sp_transfer('020110054316','010210217264',9000,'IMPS','Invoice payment','2026-08-28 09:52:00');
CALL sp_transfer('040310203685','020210067895',50000,'IMPS','Invoice payment','2026-08-30 09:53:00');
CALL sp_transfer('020310081474','030110095053',50000,'NEFT','Fund transfer','2026-08-30 23:30:00');
CALL sp_deposit('010210217264',5000,'BRANCH','Cheque deposit','2026-09-01 15:52:00');
CALL sp_deposit('010110230843',15000,'BRANCH','Salary credit','2026-09-02 08:50:00');
CALL sp_withdraw('030110095053',20000,'ATM','ATM withdrawal','2026-09-02 23:40:00');
CALL sp_transfer('020310081474','040210122211',1500,'UPI','Family support','2026-09-05 20:51:00');
CALL sp_deposit('040110149369',15000,'NETBANKING','Business receipts','2026-09-06 00:50:00');
CALL sp_transfer('010110230843','010210217264',50000,'UPI','Family support','2026-09-06 23:22:00');
CALL sp_deposit('040110135790',30000,'BRANCH','Cash deposit','2026-09-07 08:21:00');
CALL sp_withdraw('030410244422',5000,'ATM','Cash withdrawal','2026-09-07 11:07:00');
CALL sp_transfer('020310081474','020110054316',4000,'NEFT','Supplier payment','2026-09-07 19:43:00');
CALL sp_withdraw('010310027158',10000,'BRANCH','Cash withdrawal','2026-09-08 01:50:00');
CALL sp_transfer('010110013579','010310027158',4000,'NEFT','Family support','2026-09-08 05:22:00');
CALL sp_withdraw('020110054316',20000,'BRANCH','Cash withdrawal','2026-09-08 14:50:00');
CALL sp_transfer('020210067895','010310027158',1500,'IMPS','Loan EMI','2026-09-09 07:33:00');
CALL sp_transfer('020210067895','010310027158',200000,'IMPS','Invoice payment','2026-09-09 13:17:00');
CALL sp_deposit('030110095053',15000,'NETBANKING','Business receipts','2026-09-09 20:10:00');
CALL sp_withdraw('020110054316',1000,'BRANCH','Utility bills','2026-09-11 13:10:00');
CALL sp_deposit('030110095053',15000,'BRANCH','Business receipts','2026-09-11 23:33:00');
CALL sp_deposit('040310203685',2000,'BRANCH','Cheque deposit','2026-09-12 23:45:00');
CALL sp_withdraw('040110135790',20000,'BRANCH','Rent payment','2026-09-13 09:34:00');
CALL sp_transfer('040110149369','040310203685',9000,'UPI','Loan EMI','2026-09-14 04:03:00');
CALL sp_transfer('040110149369','040210122211',9000,'RTGS','Family support','2026-09-14 15:02:00');
CALL sp_withdraw('040210122211',1000,'BRANCH','Rent payment','2026-09-14 15:09:00');
CALL sp_deposit('010210217264',60000,'NETBANKING','Cheque deposit','2026-09-16 05:06:00');
CALL sp_deposit('030410244422',2000,'BRANCH','Cash deposit','2026-09-16 08:08:00');
CALL sp_withdraw('040110149369',5000,'ATM','ATM withdrawal','2026-09-17 12:06:00');
CALL sp_transfer('040110149369','010110013579',200000,'NEFT','Loan EMI','2026-09-17 13:54:00');
CALL sp_withdraw('040210122211',2000,'ATM','ATM withdrawal','2026-09-17 16:19:00');
CALL sp_withdraw('030110108632',10000,'ATM','Rent payment','2026-09-17 22:45:00');
CALL sp_withdraw('030110176527',5000,'BRANCH','Cash withdrawal','2026-09-18 06:01:00');
CALL sp_deposit('020310081474',60000,'BRANCH','Salary credit','2026-09-19 04:03:00');
CALL sp_transfer('030410244422','010110013579',4000,'NEFT','Loan EMI','2026-09-19 22:40:00');
CALL sp_deposit('010210217264',150000,'BRANCH','Business receipts','2026-09-20 09:24:00');
CALL sp_deposit('040210122211',30000,'NETBANKING','Cash deposit','2026-09-20 22:52:00');
CALL sp_withdraw('020110054316',2000,'ATM','Utility bills','2026-09-23 11:11:00');
CALL sp_deposit('020210067895',5000,'BRANCH','Cheque deposit','2026-09-23 21:35:00');
CALL sp_transfer('010210217264','010110230843',95000,'UPI','Supplier payment','2026-09-24 11:59:00');
CALL sp_deposit('040210122211',8000,'BRANCH','Salary credit','2026-09-25 22:50:00');
CALL sp_transfer('030110095053','040310203685',50000,'NEFT','Family support','2026-09-26 07:08:00');
CALL sp_transfer('040310203685','040110149369',22000,'RTGS','Supplier payment','2026-09-28 13:07:00');
CALL sp_deposit('010210217264',15000,'NETBANKING','Salary credit','2026-09-28 14:19:00');
CALL sp_deposit('010310027158',60000,'BRANCH','Cheque deposit','2026-09-28 23:35:00');
CALL sp_transfer('040110149369','040210122211',1500,'NEFT','Fund transfer','2026-09-29 00:47:00');
CALL sp_deposit('040110149369',8000,'BRANCH','Salary credit','2026-09-29 08:56:00');
CALL sp_deposit('040210122211',2000,'BRANCH','Cheque deposit','2026-09-30 11:05:00');
CALL sp_deposit('020310081474',60000,'NETBANKING','Cash deposit','2026-09-30 13:01:00');
CALL sp_deposit('010210217264',15000,'NETBANKING','Cheque deposit','2026-10-01 07:14:00');
CALL sp_transfer('040110149369','030110176527',4000,'IMPS','Loan EMI','2026-10-01 11:07:00');
CALL sp_transfer('010110013579','010310027158',1500,'UPI','Invoice payment','2026-10-01 19:00:00');
CALL sp_transfer('020310081474','030110108632',1500,'UPI','Fund transfer','2026-10-01 21:17:00');
CALL sp_deposit('020210067895',30000,'NETBANKING','Cash deposit','2026-10-02 06:30:00');
CALL sp_deposit('020110054316',5000,'NETBANKING','Business receipts','2026-10-02 18:18:00');
CALL sp_transfer('040110149369','020110054316',50000,'UPI','Invoice payment','2026-10-03 05:37:00');
CALL sp_withdraw('040110135790',2000,'ATM','Utility bills','2026-10-03 06:20:00');
CALL sp_withdraw('030110108632',1000,'ATM','ATM withdrawal','2026-10-03 10:49:00');
CALL sp_deposit('040310203685',8000,'BRANCH','Cheque deposit','2026-10-04 00:34:00');
CALL sp_withdraw('010310027158',20000,'ATM','Rent payment','2026-10-04 21:23:00');
CALL sp_withdraw('040310203685',2000,'ATM','Utility bills','2026-10-05 04:19:00');
CALL sp_transfer('010110013579','020310081474',200000,'NEFT','Fund transfer','2026-10-05 05:54:00');
CALL sp_deposit('020310081474',5000,'BRANCH','Cheque deposit','2026-10-05 13:46:00');
CALL sp_deposit('030110176527',5000,'NETBANKING','Cheque deposit','2026-10-05 23:11:00');
CALL sp_transfer('030410244422','010110040737',50000,'IMPS','Fund transfer','2026-10-06 02:49:00');
CALL sp_transfer('030410244422','040210122211',1500,'NEFT','Fund transfer','2026-10-07 03:36:00');
CALL sp_deposit('010110040737',30000,'NETBANKING','Business receipts','2026-10-07 14:00:00');
CALL sp_deposit('020210067895',15000,'NETBANKING','Cash deposit','2026-10-08 17:58:00');
CALL sp_withdraw('030110095053',2000,'BRANCH','Utility bills','2026-10-09 04:39:00');
CALL sp_transfer('020110054316','030110176527',50000,'RTGS','Loan EMI','2026-10-09 09:33:00');
CALL sp_transfer('030410244422','020310081474',50000,'NEFT','Invoice payment','2026-10-10 05:55:00');
CALL sp_deposit('010110230843',60000,'BRANCH','Business receipts','2026-10-10 23:24:00');
CALL sp_deposit('040310203685',8000,'NETBANKING','Business receipts','2026-10-10 23:51:00');
CALL sp_transfer('030410244422','020310081474',1500,'UPI','Family support','2026-10-11 04:30:00');
CALL sp_deposit('010110040737',150000,'NETBANKING','Business receipts','2026-10-11 06:29:00');
CALL sp_transfer('040210122211','020310081474',95000,'IMPS','Invoice payment','2026-10-11 21:02:00');
CALL sp_transfer('040110135790','030110176527',1500,'UPI','Fund transfer','2026-10-12 00:17:00');
CALL sp_transfer('030410244422','020310081474',1500,'NEFT','Loan EMI','2026-10-12 05:04:00');
CALL sp_transfer('010110230843','040110149369',9000,'RTGS','Supplier payment','2026-10-12 18:00:00');
CALL sp_withdraw('010110040737',10000,'BRANCH','ATM withdrawal','2026-10-12 19:23:00');
CALL sp_transfer('030110176527','040310203685',200000,'NEFT','Supplier payment','2026-10-12 21:30:00');
CALL sp_transfer('010110230843','030410244422',50000,'RTGS','Invoice payment','2026-10-13 22:13:00');
CALL sp_deposit('040110135790',150000,'NETBANKING','Cash deposit','2026-10-14 13:59:00');
CALL sp_transfer('040110135790','030110108632',50000,'UPI','Supplier payment','2026-10-14 18:46:00');
CALL sp_transfer('030410244422','020210067895',200000,'IMPS','Family support','2026-10-16 01:34:00');
CALL sp_deposit('010110040737',8000,'BRANCH','Cash deposit','2026-10-16 11:47:00');
CALL sp_transfer('010110230843','040110149369',22000,'UPI','Invoice payment','2026-10-18 02:21:00');
CALL sp_deposit('020210067895',15000,'BRANCH','Cash deposit','2026-10-18 22:34:00');
CALL sp_withdraw('030410244422',1000,'ATM','ATM withdrawal','2026-10-19 01:45:00');
CALL sp_transfer('040110135790','010110040737',9000,'RTGS','Fund transfer','2026-10-19 11:08:00');
CALL sp_transfer('030110095053','030410244422',9000,'IMPS','Invoice payment','2026-10-20 06:40:00');
CALL sp_withdraw('030410244422',10000,'ATM','Rent payment','2026-10-21 15:44:00');
CALL sp_deposit('040210122211',5000,'NETBANKING','Business receipts','2026-10-21 22:11:00');
CALL sp_deposit('010110230843',15000,'BRANCH','Salary credit','2026-10-22 01:38:00');
CALL sp_withdraw('030110095053',10000,'ATM','Cash withdrawal','2026-10-22 02:01:00');
CALL sp_transfer('010110230843','040110135790',1500,'UPI','Family support','2026-10-24 22:40:00');
CALL sp_deposit('040110135790',8000,'NETBANKING','Cash deposit','2026-10-25 03:54:00');
CALL sp_deposit('030410244422',8000,'BRANCH','Business receipts','2026-10-25 14:07:00');
CALL sp_transfer('030110176527','030410244422',200000,'NEFT','Invoice payment','2026-10-25 15:06:00');
CALL sp_deposit('020110054316',8000,'NETBANKING','Cheque deposit','2026-10-27 02:54:00');
CALL sp_deposit('040110149369',8000,'NETBANKING','Cheque deposit','2026-10-27 08:26:00');
CALL sp_transfer('010110040737','020210067895',200000,'RTGS','Invoice payment','2026-10-27 18:58:00');
CALL sp_withdraw('040110149369',5000,'ATM','ATM withdrawal','2026-10-28 02:20:00');
CALL sp_deposit('020310081474',30000,'NETBANKING','Salary credit','2026-10-28 05:12:00');
CALL sp_deposit('030110108632',8000,'NETBANKING','Business receipts','2026-10-29 03:50:00');
CALL sp_withdraw('040110135790',40000,'BRANCH','Rent payment','2026-10-29 06:56:00');
CALL sp_withdraw('030110095053',5000,'ATM','Cash withdrawal','2026-10-29 17:20:00');
CALL sp_deposit('040210122211',150000,'NETBANKING','Cash deposit','2026-10-29 21:51:00');
CALL sp_transfer('030110095053','010110040737',50000,'NEFT','Family support','2026-10-30 18:34:00');
CALL sp_post_interest('010110013579',56.88,'2026-09-30 23:00:00');
CALL sp_post_interest('010310027158',2699.38,'2026-09-30 23:00:00');
CALL sp_post_interest('010110040737',1785.0,'2026-09-30 23:00:00');
CALL sp_post_interest('020110054316',2003.75,'2026-09-30 23:00:00');
CALL sp_post_interest('020210067895',9909.38,'2026-09-30 23:00:00');
CALL sp_post_interest('020310081474',14021.88,'2026-09-30 23:00:00');
CALL sp_post_interest('030110095053',389.38,'2026-09-30 23:00:00');
CALL sp_post_interest('030110108632',1719.38,'2026-09-30 23:00:00');
UPDATE accounts SET status='DORMANT' WHERE account_no='010110190106';
UPDATE accounts SET status='FROZEN'  WHERE account_no='020210162948';
INSERT INTO loans(customer_id,account_id,principal,interest_pct,tenure_months,outstanding,status,disbursed_on) VALUES
(2,3,500000,10.5,36,310000,'ACTIVE','2026-01-15'),
(3,4,1500000,9.75,120,1480000,'ACTIVE','2026-03-01'),
(7,9,800000,11.0,48,0,'CLOSED','2025-08-10'),
(10,12,300000,13.5,24,300000,'NPA','2025-12-01'),
(14,16,2500000,12.25,60,2300000,'ACTIVE','2026-02-20'),
(13,15,400000,10.9,36,380000,'ACTIVE','2026-05-05');
