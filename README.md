#  Commercial Core Banking Customer & Ledger System

A Commercial Core Banking Customer & Ledger Management System designed to manage customer onboarding, KYC verification, account opening, banking transactions, and double-entry ledger operations.

The application integrates a MySQL database, Node.js and Express REST API, and a web-based frontend to support core banking operations, role-based access control, and decision-support reporting.

##  Project Information

- **Project Title:** Commercial Core Banking Customer & Ledger System
- **Developed By:** 1.Harinishreya C     2.Joel saji george     3.Lalit padihar
- **Project Domain:** Banking and Financial Management
- **Project Type:** Full-Stack Web Application
- **Database:** MySQL
- **Backend:** Node.js, Express.js
- **Frontend:** HTML, CSS, JavaScript

##  Project Objectives

- Manage customer registration and KYC verification.
- Facilitate bank account creation and management.
- Support deposits, withdrawals, and fund transfers.
- Maintain a double-entry accounting ledger.
- Implement role-based access control for banking users.
- Generate decision-support reports for banking operations.
- Provide customer, account, transaction, and financial dashboards.
- Maintain data integrity using database constraints, triggers, and stored procedures.

##  Key Features

### Customer Management
- Customer onboarding and registration.
- Unique Customer Information File (CIF) generation.
- PAN and mobile number validation.
- KYC verification and status management.
- Customer search and data privacy masking.

### Account Management
- Bank account creation.
- Account type and branch management.
- Account balance overview.
- Account statement generation.
- KYC-based account opening validation.

### Banking Transactions
- Deposits
- Withdrawals
- Fund transfers
- Transaction narration and channel tracking
- Double-entry ledger posting
- Transaction history

### Security and Access Control
- Role-based access control (RBAC).
- User authentication.
- Session token management.
- Temporary account lockout after repeated failed login attempts.
- Sensitive customer information masking.
- Audit log support.

### Decision Support System (DSS)
- SQL-based financial reporting.
- JOIN, GROUP BY, HAVING, subqueries, and window functions.
- Trial balance reporting.
- Branch-wise deposit analysis.
- Transaction analytics.
- Risk analysis and management reports.

##  Technology Stack

| Component | Technology |
|---|---|
| Frontend | HTML5, CSS3, JavaScript |
| Backend | Node.js |
| API Framework | Express.js |
| Database | MySQL 8 |
| Database Driver | mysql2 |
| Authentication | Token-based authentication |
| Data Analysis | SQL DSS Queries |
| Reporting | Microsoft Excel |
| Documentation | Microsoft Word |
| Version Control | Git and GitHub |

##  Project Structure

```text
Commercial-Core-Banking-Customer-Ledger-System/
│
└── proj/
    ├── backend/
    │   ├── src/
    │   │   └── server.js
    │   ├── package.json
    │   ├── package-lock.json
    │   └── .env.example
    │
    ├── frontend/
    │   ├── index.html
    │   ├── style.css
    │   └── app.js
    │
    ├── database/
    │   ├── 01_schema.sql
    │   ├── 02_seed_data.sql
    │   ├── 03_dss_queries.sql
    │   └── _seed_generator.py
    │
    ├── docs/
    │   ├── Project_Report.docx
    │   └── diagrams/
    │
    ├── excel/
    │   └── Core_Banking_Reports.xlsx
    │
    └── README.md
```

##  Installation and Setup

### Prerequisites

Ensure the following software is installed:

- Node.js 18 or above
- MySQL 8 or compatible MariaDB
- MySQL Workbench
- Visual Studio Code
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/Tarani-V790/Commercial-Core-Banking-Customer-Ledger-System.git
```

Navigate to the project directory:

```bash
cd Commercial-Core-Banking-Customer-Ledger-System/proj
```

### Step 2: Configure the Database

Open MySQL Workbench and execute the SQL scripts in the following order:

1. `database/01_schema.sql`
2. `database/02_seed_data.sql`

The first script creates the database schema, tables, constraints, triggers, stored procedures, views, and application user.

The second script inserts sample banking data.

To execute the DSS reports:

```sql
SOURCE database/03_dss_queries.sql;
```

Alternatively, execute the SQL file directly through MySQL Workbench.

### Step 3: Configure the Backend

Navigate to the backend directory:

```bash
cd backend
```

Install the required dependencies:

```bash
npm install
```

Configure database connection settings using the environment variables described in `.env.example`.

Example configuration:

```env
DB_HOST=localhost
DB_USER=bank_app
DB_PASSWORD=your_database_password
DB_NAME=core_banking
PORT=3000
```

### Step 4: Start the Application

Run the backend server:

```bash
npm start
```

The application will be available at:

http://localhost:3000

Open the application in your browser.

##  Demo User Roles

The project includes demonstration accounts for different banking roles.

| Username | Password | Role |
|---|---|---|
| manager1 | manager123 | MANAGER |
| teller1 | teller123 | TELLER |
| auditor1 | auditor123 | AUDITOR |
| admin | admin123 | ADMIN |

**Note:** These are demonstration credentials intended for local testing only. Do not use them in a production banking environment.

##  Project Deliverables

- Full-stack core banking application.
- MySQL database schema and sample data.
- REST API implementation.
- Banking transaction and ledger management.
- Decision-support SQL queries.
- Excel-based banking reports and dashboard.
- Project documentation and system diagrams.

##  Future Enhancements

- Integration with real-time payment gateways.
- Enhanced multi-factor authentication.
- JWT-based authentication with secure refresh tokens.
- Advanced fraud detection mechanisms.
- Automated reconciliation.
- Cloud deployment.
- Comprehensive automated testing.
- Improved audit and compliance monitoring.

##  Security Disclaimer

This application is developed for academic and demonstration purposes.

The application uses simplified authentication and session management mechanisms. Production banking systems require stronger password hashing, secure session handling, encryption, transaction monitoring, regulatory compliance, and comprehensive security testing.

All sample banking data is fictitious.

##  Author

**Harinishreya C      Joel saji george       Lalit padihar**

Commercial Core Banking Customer & Ledger System

Developed as an academic project exploring core banking operations, database management, full-stack application development, and decision-support systems.

---

 If you find this project useful, consider starring the repository.

