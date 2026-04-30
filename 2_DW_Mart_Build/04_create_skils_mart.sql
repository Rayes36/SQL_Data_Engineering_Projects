-- Step 4: Mart - Create and load data from DW to SM
DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS skills_mart;

CREATE TABLE IF NOT EXISTS dw_marts.skills_mart.dim_skill (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

CREATE TABLE IF NOT EXISTS dw_marts.skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

CREATE TABLE IF NOT EXISTS dw_marts.skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    job_postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill (skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month (month_start_date)
);

SELECT '=== Loading dim_skill TABLE ===' AS info;
INSERT INTO dw_marts.skills_mart.dim_skill(
    skill_id,
    skills,
    type
)
    SELECT
        *
    FROM
        dw_marts.main.skills_dim;

SELECT '=== Loading dim_date_month TABLE ===' AS info;
INSERT INTO dw_marts.skills_mart.dim_date_month(
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
    SELECT DISTINCT
        DATE_TRUNC('month', job_posted_date) AS month_start_date,
        EXTRACT(YEAR FROM job_posted_date),
        EXTRACT(MONTH FROM job_posted_date),
        EXTRACT(QUARTER FROM job_posted_date),
        CASE
            WHEN EXTRACT(QUARTER FROM job_posted_date) = 1 THEN 'Q1'
            WHEN EXTRACT(QUARTER FROM job_posted_date) = 2 THEN 'Q2'
            WHEN EXTRACT(QUARTER FROM job_posted_date) = 3 THEN 'Q3'
            WHEN EXTRACT(QUARTER FROM job_posted_date) = 4 THEN 'Q4'
        END,
        EXTRACT(YEAR FROM job_posted_date) || '-Q' || EXTRACT(QUARTER FROM job_posted_date)
    FROM 
        dw_marts.main.job_postings_fact
    ORDER BY month_start_date ASC;

SELECT '=== Loading fact_skill_demand_monthly TABLE ===' AS info;
INSERT INTO dw_marts.skills_mart.fact_skill_demand_monthly(
    skill_id,
    month_start_date,
    job_title_short,
    job_postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_postings_count
)
    SELECT
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short,
        COUNT(jpf.*),
        COUNT(jpf.*) FILTER (WHERE jpf.job_work_from_home = TRUE),
        COUNT(jpf.*) FILTER (WHERE jpf.job_health_insurance = TRUE),
        COUNT(jpf.*) FILTER (WHERE jpf.job_no_degree_mention = TRUE)
    FROM
        dw_marts.main.job_postings_fact AS jpf
    INNER JOIN dw_marts.main.skills_job_dim AS sjd
        ON sjd.job_id = jpf.job_id
    GROUP BY 
        sjd.skill_id, month_start_date, jpf.job_title_short
    ORDER BY month_start_date ASC;

SELECT 'Skill Dimension' AS name, format('{:,}', COUNT(*)) AS total_rows FROM dw_marts.skills_mart.dim_skill
UNION ALL
SELECT 'Date Month Dimension', format('{:,}', COUNT(*)) FROM dw_marts.skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact', format('{:,}', COUNT(*)) FROM dw_marts.skills_mart.fact_skill_demand_monthly;

SELECT * FROM dw_marts.skills_mart.dim_skill LIMIT 5;
SELECT * FROM dw_marts.skills_mart.dim_date_month LIMIT 5;
SELECT * FROM dw_marts.skills_mart.fact_skill_demand_monthly LIMIT 5;