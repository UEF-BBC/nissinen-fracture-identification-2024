# nissinen-fracture-identification-2024

An algorithmic approach for automated identification of fragility fractures from administrative data.

**Project description:**

This project provides an example implementation for algorithmic identification of humerus and wrist fractures from a database containing register and radiological visits data (from a PACS system). The method is described in detail in two open-access publications (links below). The main code is in R language, and the database queries are SQLite compatible SQL. The complete register or radiological visits data is first fetched using the SQL queries and then further filtered according to the different rule-based algorithms.

**Original papers:**

[Nissinen T, Sund R, Suoranta S, Kröger H, Väänänen SP. Combining Register and Radiological Visits Data Allows to Reliably Identify Incident Wrist Fractures. Clinical Epidemiology 2023, 15:1001-1008](https://www.dovepress.com/combining-register-and-radiological-visits-data-allows-to-reliably-ide-peer-reviewed-fulltext-article-CLEP)

Nissinen T, Sund R, Suoranta S, Kröger H, Väänänen SP. Identifying proximal humerus fractures: an algorithmic approach using registers and radiological visits data (submitted for publication)


**Project structure:**

/project-root

├── fracture_identification.R (entry point R script)

├── sql_queries/

│   ├── query_humerus_pacs.sql (query for fetching humerus fracture pacs data)

│   ├── query_humerus_register.sql (query for fetching humerus fracture register data)

│   ├── query_wrist_pacs.sql (query for fetching wrist fracture pacs data)

│   └── query_wrist_register.sql (query for fetching wrist fracture register data)

└── README.md

