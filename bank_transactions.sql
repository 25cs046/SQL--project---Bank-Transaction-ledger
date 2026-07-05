-- =============================================
-- Project 4: Bank Transaction Ledger
-- =============================================

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS beneficiaries;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS banks;

CREATE TABLE banks (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL,
    branch  TEXT
);

CREATE TABLE accounts (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    account_no  TEXT NOT NULL,
    acc_type    TEXT,
    bank_id     INTEGER,
    balance     REAL
);

CREATE TABLE beneficiaries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    account_no  TEXT NOT NULL,
    bank_name   TEXT
);

CREATE TABLE transactions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id      INTEGER,
    type            TEXT,
    amount          REAL,
    date            TEXT,
    description     TEXT,
    beneficiary_id  INTEGER
);

INSERT INTO banks VALUES (1, 'State Bank of India', 'Chennai Main');
INSERT INTO banks VALUES (2, 'HDFC Bank', 'Anna Nagar');
INSERT INTO banks VALUES (3, 'ICICI Bank', 'T Nagar');

INSERT INTO accounts VALUES (1, 'Ravi Kumar', 'ACC001', 'SAVINGS', 1, 15000);
INSERT INTO accounts VALUES (2, 'Priya Sharma', 'ACC002', 'CURRENT', 2, 50000);
INSERT INTO accounts VALUES (3, 'Karthik Raja', 'ACC003', 'SAVINGS', 1, 8000);

INSERT INTO beneficiaries VALUES (1, 'Anita Rao', 'BEN001', 'HDFC Bank');
INSERT INTO beneficiaries VALUES (2, 'Suresh Nair', 'BEN002', 'Axis Bank');

INSERT INTO transactions VALUES (1, 1, 'DEPOSIT', 5000, '2024-01-05', 'Salary credited', NULL);
INSERT INTO transactions VALUES (2, 1, 'WITHDRAWAL', 1500, '2024-01-08', 'ATM withdrawal', NULL);
INSERT INTO transactions VALUES (3, 1, 'TRANSFER', 2000, '2024-01-10', 'Sent to Anita', 1);
INSERT INTO transactions VALUES (4, 2, 'DEPOSIT', 20000, '2024-01-12', 'Client payment', NULL);
INSERT INTO transactions VALUES (5, 2, 'WITHDRAWAL', 5000, '2024-01-15', 'Office supplies', NULL);
INSERT INTO transactions VALUES (6, 1, 'DEPOSIT', 3000, '2024-02-01', 'Freelance payment', NULL);
INSERT INTO transactions VALUES (7, 3, 'DEPOSIT', 10000, '2024-02-05', 'Salary', NULL);
INSERT INTO transactions VALUES (8, 3, 'WITHDRAWAL', 500, '2024-02-06', 'Coffee shop', NULL);
INSERT INTO transactions VALUES (9, 1, 'WITHDRAWAL', 8000, '2024-02-10', 'Rent payment', NULL);
INSERT INTO transactions VALUES (10, 2, 'TRANSFER', 15000, '2024-02-15', 'Sent to Suresh', 2);
INSERT INTO transactions VALUES (11, 1, 'DEPOSIT', 50000, '2024-02-20', 'Bonus received', NULL);
INSERT INTO transactions VALUES (12, 3, 'WITHDRAWAL', 200, '2024-02-28', 'Bus ticket', NULL);

-- =============================================
-- FEATURE 1: All Transactions Per Account
-- =============================================
SELECT 
    accounts.name AS account_holder,
    accounts.account_no,
    banks.name AS bank,
    transactions.date,
    transactions.type,
    transactions.amount,
    transactions.description
FROM transactions
JOIN accounts ON transactions.account_id = accounts.id
JOIN banks ON accounts.bank_id = banks.id
ORDER BY accounts.name, transactions.date;

-- =============================================
-- FEATURE 2: Account Balance Summary
-- =============================================
SELECT 
    accounts.name,
    accounts.account_no,
    accounts.acc_type,
    SUM(CASE WHEN transactions.type = 'DEPOSIT' THEN transactions.amount ELSE 0 END) AS total_deposited,
    SUM(CASE WHEN transactions.type IN ('WITHDRAWAL','TRANSFER') THEN transactions.amount ELSE 0 END) AS total_spent,
    SUM(CASE WHEN transactions.type = 'DEPOSIT' THEN transactions.amount
             WHEN transactions.type IN ('WITHDRAWAL','TRANSFER') THEN -transactions.amount
             ELSE 0 END) AS net_balance
FROM accounts
JOIN transactions ON transactions.account_id = accounts.id
GROUP BY accounts.id, accounts.name, accounts.account_no, accounts.acc_type;

-- =============================================
-- FEATURE 3: Transaction Type Summary
-- =============================================
SELECT 
    type,
    COUNT(*) AS total_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY type
ORDER BY total_amount DESC;

-- =============================================
-- FEATURE 4: Fraud Detection (Risk Levels)
-- =============================================
SELECT 
    accounts.name AS account_holder,
    transactions.date,
    transactions.type,
    transactions.amount,
    transactions.description,
    CASE 
        WHEN transactions.amount > 20000 THEN 'HIGH RISK'
        WHEN transactions.amount > 10000 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_level
FROM transactions
JOIN accounts ON transactions.account_id = accounts.id
ORDER BY transactions.amount DESC;

-- =============================================
-- FEATURE 5: Monthly Transaction Summary
-- =============================================
SELECT 
    STRFTIME('%Y-%m', transactions.date) AS month,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN transactions.type = 'DEPOSIT' THEN transactions.amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN transactions.type = 'WITHDRAWAL' THEN transactions.amount ELSE 0 END) AS total_withdrawals,
    SUM(CASE WHEN transactions.type = 'TRANSFER' THEN transactions.amount ELSE 0 END) AS total_transfers
FROM transactions
GROUP BY STRFTIME('%Y-%m', transactions.date)
ORDER BY month;

-- =============================================
-- FEATURE 6: Account Statement (ACC001)
-- =============================================
SELECT 
    transactions.date,
    transactions.type,
    transactions.description,
    CASE WHEN transactions.type = 'DEPOSIT' THEN transactions.amount ELSE NULL END AS credit,
    CASE WHEN transactions.type IN ('WITHDRAWAL','TRANSFER') THEN transactions.amount ELSE NULL END AS debit,
    transactions.amount
FROM transactions
JOIN accounts ON transactions.account_id = accounts.id
WHERE accounts.account_no = 'ACC001'
ORDER BY transactions.date ASC;

-- =============================================
-- FEATURE 7: Transfer Tracking
-- =============================================
SELECT 
    accounts.name AS sender,
    accounts.account_no AS sender_account,
    transactions.amount,
    transactions.date,
    beneficiaries.name AS receiver,
    beneficiaries.account_no AS receiver_account,
    beneficiaries.bank_name AS receiver_bank
FROM transactions
JOIN accounts ON transactions.account_id = accounts.id
JOIN beneficiaries ON transactions.beneficiary_id = beneficiaries.id
WHERE transactions.type = 'TRANSFER'
ORDER BY transactions.date ASC;

-- =============================================
-- FEATURE 8: Running Balance (Account 1)
-- =============================================
SELECT 
    t1.date,
    t1.type,
    t1.amount,
    t1.description,
    SUM(CASE WHEN t2.type = 'DEPOSIT' THEN t2.amount
             WHEN t2.type IN ('WITHDRAWAL','TRANSFER') THEN -t2.amount
             ELSE 0 END) AS running_balance
FROM transactions t1
JOIN transactions t2 
    ON t2.account_id = t1.account_id 
    AND t2.date <= t1.date
    AND t2.id <= t1.id
WHERE t1.account_id = 1
GROUP BY t1.id, t1.date, t1.type, t1.amount, t1.description
ORDER BY t1.date ASC, t1.id ASC;
