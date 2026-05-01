-- Step 5: Priority Mart - Create priority roles mart & priority jobs snapshot
DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS priority_mart;

CREATE TABLE IF NOT EXISTS dw_marts.priority_mart.priority_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

SELECT '=== Loading priority_roles TABLE ===' AS info;
INSERT INTO dw_marts.priority_mart.priority_roles(
    role_id,
    role_name,
    priority_lvl
)
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Data Analyst', 1),
    (3, 'Data Scientist', 2),
    (4, 'Software Engineer', 3);

CREATE OR REPLACE TABLE dw_marts.priority_mart.priority_jobs_snapshot(
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

SELECT '=== Loading priority_jobs_snapshot TABLE ===' AS info;
INSERT INTO dw_marts.priority_mart.priority_jobs_snapshot(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    current_timestamp
FROM
    job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON cd.company_id = jpf.company_id
INNER JOIN dw_marts.priority_mart.priority_roles AS pr
    ON pr.role_name = jpf.job_title_short;