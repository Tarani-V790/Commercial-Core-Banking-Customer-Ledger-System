import random, hashlib, datetime as dt
random.seed(2026)
out=[]
w=out.append
w("-- Seed data (generated with fixed random seed). All balances are produced by calling the posting procedures,\n-- so the ledger and account balances are consistent by construction.\nUSE core_banking;\n")
w("INSERT INTO branches(branch_code,branch_name,city,ifsc_code) VALUES\n('CCB001','T. Nagar Main','Chennai','CCBN0000001'),\n('CCB002','Anna Nagar','Chennai','CCBN0000002'),\n('CCB003','Adyar','Chennai','CCBN0000003'),\n('CCB004','RS Puram','Coimbatore','CCBN0000004');")
w("INSERT INTO account_types(type_name,interest_pct,min_balance) VALUES\n('SAVINGS',3.50,1000),('CURRENT',0.00,5000),('SALARY',3.00,0),('RECURRING',6.00,500);")
w("INSERT INTO channels(channel_name) VALUES ('BRANCH'),('ATM'),('UPI'),('NEFT'),('IMPS'),('RTGS'),('NETBANKING'),('SYSTEM');")
w("INSERT INTO transaction_types(type_code,description) VALUES\n('DEPOSIT','Cash or cheque deposit'),('WITHDRAWAL','Cash withdrawal'),('TRANSFER','Account to account transfer'),('INTEREST','Interest credit');")
w("INSERT INTO gl_accounts(gl_code,gl_name,category) VALUES\n('1001','Cash in Hand','ASSET'),('2001','Customer Deposits Control','LIABILITY'),('4001','Fee & Commission Income','INCOME'),('5001','Interest Expense on Deposits','EXPENSE');")
h=lambda p:hashlib.sha256(p.encode()).hexdigest()
w("INSERT INTO users(username,password_hash,full_name,role,branch_id) VALUES\n"
  f"('admin','{h('admin123')}','System Administrator','ADMIN',NULL),\n"
  f"('teller1','{h('teller123')}','Priya Raman','TELLER',1),\n"
  f"('manager1','{h('manager123')}','Karthik Subramanian','MANAGER',1),\n"
  f"('auditor1','{h('auditor123')}','Meena Iyer','AUDITOR',NULL);")
cust=[("Arjun Venkatesh","1985-03-14","M","Chennai",1,"VERIFIED","LOW"),
("Lakshmi Narayanan","1979-11-02","F","Chennai",1,"VERIFIED","LOW"),
("Mohammed Faizal","1990-07-21","M","Chennai",2,"VERIFIED","MEDIUM"),
("Divya Krishnan","1995-01-30","F","Chennai",2,"VERIFIED","LOW"),
("Suresh Babu","1972-05-09","M","Chennai",3,"VERIFIED","LOW"),
("Anitha Rajan","1988-09-17","F","Chennai",3,"VERIFIED","MEDIUM"),
("Ramesh Kumar","1969-12-25","M","Coimbatore",4,"VERIFIED","LOW"),
("Sangeetha Pillai","1992-04-04","F","Coimbatore",4,"VERIFIED","LOW"),
("Vignesh Murugan","1998-08-12","M","Chennai",1,"PENDING","LOW"),
("Fathima Begum","1983-06-27","F","Chennai",2,"VERIFIED","HIGH"),
("Harish Chandran","1976-02-18","M","Chennai",3,"VERIFIED","LOW"),
("Nandhini Sekar","1994-10-05","F","Chennai",1,"PENDING","LOW"),
("Gokul Prasad","1987-12-11","M","Coimbatore",4,"VERIFIED","MEDIUM"),
("Tamil Selvi Traders (Prop. K. Selvam)","1974-03-03","M","Chennai",1,"VERIFIED","HIGH")]
rows=[]
for i,(n,d,g,c,b,k,r) in enumerate(cust,1):
    pan="ABCDE%04d%s"%(1000+i*37,"FGHJKLMNPQRST"[i%13])
    first=n.split()[0].lower().replace('.','')
    rows.append(f"('CIF{100000+i}','{n}','{d}','{g}','{pan}','9{840000000+i*7919:09d}'[:15],'{first}{i}@example.in','{10+i}, Gandhi Road, {c}','{c}','{k}','{r}',{b},'2026-0{1+i%6}-1{i%9} 10:00:00')")
rows=[x.replace("'[:15]","'").replace("'9","'9") for x in rows]
w("INSERT INTO customers(cif_no,full_name,dob,gender,pan,phone,email,address,city,kyc_status,risk_category,branch_id,created_at) VALUES\n"+",\n".join(rows)+";")
# accounts: (cust_idx, type_id, status)
accs=[(1,1),(1,3),(2,1),(3,1),(3,2),(4,3),(5,1),(6,1),(7,2),(7,1),(8,1),(10,2),(11,1),(12,1),(13,3),(14,2),(14,1),(5,4)]
status={14:'DORMANT',12:'FROZEN'}  # index in accs (1-based) -> status
arows=[];accno=[]
for j,(ci,t) in enumerate(accs,1):
    b=cust[ci-1][4]; no="%02d%02d%08d"%(b,t,10000000+j*13579)[:12]; accno.append(no)
    arows.append(f"('{no}',{ci},{t},{b},'2026-0{1+j%5}-0{1+j%8}','ACTIVE',0)")
w("INSERT INTO accounts(account_no,customer_id,type_id,branch_id,open_date,status,balance) VALUES\n"+",\n".join(arows)+";")
# simulate
bal={n:0 for n in accno}; minb={1:1000,2:5000,3:0,4:500}
atype={accno[j]:accs[j][1] for j in range(len(accs))}
ev=[]
d0=dt.datetime(2026,7,1,10,0)
for j,n in enumerate(accno):
    amt=random.choice([25000,40000,75000,120000,250000,500000,900000])
    ev.append((d0+dt.timedelta(hours=j),'D',n,None,amt,'BRANCH','Account opening deposit'))
dormant=[accno[13]]; frozen=[accno[11]]
active=[n for n in accno if n not in dormant+frozen]
narr_d=['Cash deposit','Cheque deposit','Salary credit','Business receipts']
narr_w=['ATM withdrawal','Cash withdrawal','Rent payment','Utility bills']
for k in range(210):
    t=dt.datetime(2026,7,3)+dt.timedelta(days=random.random()*120,hours=random.randint(0,6))
    t=t.replace(minute=random.randint(0,59),second=0,microsecond=0)
    r=random.random()
    if r<.35: ev.append((t,'D',random.choice(active),None,random.choice([2000,5000,8000,15000,30000,60000,150000]),random.choice(['BRANCH','NETBANKING']),random.choice(narr_d)))
    elif r<.6: ev.append((t,'W',random.choice(active),None,random.choice([1000,2000,5000,10000,20000,40000]),random.choice(['ATM','BRANCH']),random.choice(narr_w)))
    else:
        a,b=random.sample(active,2); ev.append((t,'T',a,b,random.choice([1500,4000,9000,22000,50000,95000,200000]),random.choice(['UPI','NEFT','IMPS','RTGS']),random.choice(['Invoice payment','Family support','Fund transfer','Loan EMI','Supplier payment'])))
# dormant account: nothing after July. enforce by never choosing.
ev.sort(key=lambda e:e[0])
w("\n-- Transactions posted through stored procedures (chronological)")
for t,k,a,b,amt,ch,nr in ev:
    ts=t.strftime('%Y-%m-%d %H:%M:%S')
    if k=='D': bal[a]+=amt; w(f"CALL sp_deposit('{a}',{amt},'{ch}','{nr}','{ts}');")
    elif k=='W':
        if bal[a]-amt<minb[atype[a]]: continue
        bal[a]-=amt; w(f"CALL sp_withdraw('{a}',{amt},'{ch}','{nr}','{ts}');")
    else:
        if bal[a]-amt<minb[atype[a]]: continue
        bal[a]-=amt; bal[b]+=amt; w(f"CALL sp_transfer('{a}','{b}',{amt},'{ch}','{nr}','{ts}');")
for n in active[:8]:
    w(f"CALL sp_post_interest('{n}',{round(bal[n]*0.0875/4*0.4,2)},'2026-09-30 23:00:00');")
w("UPDATE accounts SET status='DORMANT' WHERE account_no='%s';"%dormant[0])
w("UPDATE accounts SET status='FROZEN'  WHERE account_no='%s';"%frozen[0])
loans=[(2,3,500000,10.5,36,310000,'ACTIVE','2026-01-15'),(3,4,1500000,9.75,120,1480000,'ACTIVE','2026-03-01'),(7,9,800000,11.0,48,0,'CLOSED','2025-08-10'),
(10,12,300000,13.5,24,300000,'NPA','2025-12-01'),(14,16,2500000,12.25,60,2300000,'ACTIVE','2026-02-20'),(13,15,400000,10.9,36,380000,'ACTIVE','2026-05-05')]
w("INSERT INTO loans(customer_id,account_id,principal,interest_pct,tenure_months,outstanding,status,disbursed_on) VALUES\n"+",\n".join(f"({a},{b},{c},{d},{e},{f},'{g}','{h_}')" for a,b,c,d,e,f,g,h_ in loans)+";")
open('02_seed_data.sql','w').write("\n".join(out)+"\n")
print(len(ev),"events")
