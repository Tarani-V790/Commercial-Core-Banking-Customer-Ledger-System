# Commercial Core Banking Customer & Ledger System
MBA Semester 2 – Technology for Management (2.1) project. Covers all six syllabus modules.

## Folder structure
| Path | Contents | Module |
|---|---|---|
| `database/01_schema.sql` | Tables (3NF), constraints, triggers, stored procedures, views, app user | 2, 6 |
| `database/02_seed_data.sql` | Branches, customers, accounts, 224 postings, loans | 6 |
| `database/03_dss_queries.sql` | 12 DSS queries (JOIN, GROUP BY, HAVING, subqueries, window functions) | 6 |
| `backend/` | Node.js + Express REST API (login, RBAC, customers, accounts, postings, DSS reports) | 4, 5, 6 |
| `frontend/` | Browser UI: dashboard, customers, accounts, transactions, DSS reports (CSV export) | 6 |
| `excel/Core_Banking_Reports.xlsx` | Data sheets + live-formula DSS dashboard, trial balance, risk matrix, adoption plan | 1, 4, 5, 6 |
| `docs/Project_Report.docx` | Full report: classification, 3NF, SDLC, Context & Level-1 DFD, BPR, adoption, security, ethics, viva prep | 1–6 |
| `docs/diagrams/` | PNG + Graphviz sources of all diagrams (editable) | 1–4 |

## Run it
1. Install **MySQL 8** (or MariaDB 10.5+) and **Node.js 18+**.
2. Load the database:
   ```
   mysql -u root -p < database/01_schema.sql
   mysql -u root -p < database/02_seed_data.sql
   mysql -u root -p < database/03_dss_queries.sql      # optional: shows all reports
   ```
3. Start the app:
   ```
   cd backend
   npm install
   npm start
   ```
4. Open http://localhost:3000

The app connects as the least-privilege user `bank_app` (created by `01_schema.sql`). Override with `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `PORT` (see `backend/.env.example`).

## Demo logins
| User | Password | Role | Can do |
|---|---|---|---|
| manager1 | manager123 | MANAGER | everything, approve KYC, see unmasked PAN/phone |
| teller1 | teller123 | TELLER | onboard customers, open accounts, post transactions |
| auditor1 | auditor123 | AUDITOR | read-only, DSS reports, audit log |
| admin | admin123 | ADMIN | everything |

## Before you submit
- Fill in names, roll numbers and contributions in `Project_Report.docx` (cover and Appendix B) and the `README_Attribution` sheet in the workbook. Individual attribution is mandatory.
- Each member should be able to explain and run the files they own (individual viva).
- All data is fictitious. Passwords use SHA-256 for demo simplicity; the report explains the production alternative.
