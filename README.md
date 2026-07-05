# SQL--project---Bank-Transaction-ledger
SQL projects for internship
Name:Deivanai K
Intern ID:CITS4176

## Project Overview
An advanced banking database system that tracks accounts, transactions, transfers, and provides 
fraud detection, monthly summaries, and real-time running balance calculations.

## Tables
- **banks** — stores bank and branch details
- **accounts** — stores customer account information linked to banks
- **beneficiaries** — stores transfer recipient details
- **transactions** — stores all financial transactions

## Features
1. All transactions per account with bank details (3-table JOIN)
2. Account balance summary with net balance (CASE WHEN + SUM)
3. Transaction type summary — deposits, withdrawals, transfers
4. Fraud detection system with HIGH/MEDIUM/LOW risk levels (CASE WHEN)
5. Monthly transaction summary using date extraction (STRFTIME)
6. Account statement with separate credit/debit columns
7. Transfer tracking — sender to receiver with bank details
8. Running balance per account (self JOIN)

## Advanced Concepts Used
- Self JOIN (joining a table to itself)
- CASE WHEN with multiple conditions
- STRFTIME for date extraction and grouping
- COUNT(DISTINCT ...) for unique counts
- Subquery-style SUM for running calculations
- Multi-table JOIN (3 tables)
- Fraud detection logic using threshold values
- IN operator for multiple value matching

## Tool Used
SQLite
