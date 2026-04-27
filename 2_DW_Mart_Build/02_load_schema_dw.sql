-- Step 2: DW - Load data from CSV files into tables

SELECT '=== Loading company_dim TABLE ===' AS info;

INSERT INTO dw_marts.main.company_dim(
    company_id, 
    name
)
    SELECT
        company_id,
        name
    FROM
        read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', AUTO_DETECT=TRUE)
;

SELECT '=== Loading skills_dim TABLE ===' AS info;

INSERT INTO dw_marts.main.skills_dim(
    skill_id, 
    skills, 
    type
)
    SELECT
        skill_id, 
        skills, 
        type
    FROM
        read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv', AUTO_DETECT=TRUE)
;

SELECT '=== Loading job_postings_fact TABLE ===' AS info;

INSERT INTO dw_marts.main.job_postings_fact(
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
)
    SELECT
        job_id,
        company_id,
        job_title_short,
        job_title,
        job_location,
        job_via,
        job_schedule_type,
        job_work_from_home,
        search_location,
        job_posted_date,
        job_no_degree_mention,
        job_health_insurance,
        job_country,
        salary_rate,
        salary_year_avg,
        salary_hour_avg
    FROM
        read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv', AUTO_DETECT=TRUE)
;

SELECT '=== Loading skills_job_dim TABLE ===' AS info;

INSERT INTO dw_marts.main.skills_job_dim(
    job_id,
    skill_id
)
    SELECT
        job_id,
        skill_id
    FROM
        read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', AUTO_DETECT=TRUE)
;

SELECT '=== Validation ===' AS info;
SELECT 'company_dim' AS name, format('{:,}', COUNT(*)) AS total_rows FROM dw_marts.main.company_dim
UNION ALL
SELECT 'skills_dim', format('{:,}', COUNT(*)) FROM dw_marts.main.skills_dim
UNION ALL
SELECT 'job_postings_fact', format('{:,}', COUNT(*)) FROM dw_marts.main.job_postings_fact
UNION ALL
SELECT 'skills_job_dim', format('{:,}', COUNT(*)) FROM dw_marts.main.skills_job_dim;

SELECT * FROM dw_marts.main.company_dim LIMIT 5;
SELECT * FROM dw_marts.main.skills_dim LIMIT 5;
SELECT * FROM dw_marts.main.job_postings_fact LIMIT 5;
SELECT * FROM dw_marts.main.skills_job_dim LIMIT 5;