DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS company_mart;

CREATE TABLE IF NOT EXISTS dw_marts.company_mart.dim_job_title_short(
    job_title_short_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR
);
INSERT INTO dw_marts.company_mart.dim_job_title_short(
    job_title_short_id,
    job_title_short
)
SELECT
    ROW_NUMBER() OVER (ORDER BY job_title_short ASC),
    job_title_short
FROM
    dw_marts.main.job_postings_fact
WHERE 
    job_title_short IS NOT NULL
GROUP BY 
    job_title_short;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.dim_job_title(
    job_title_id INTEGER PRIMARY KEY,
    job_title VARCHAR
);
INSERT INTO dw_marts.company_mart.dim_job_title(
    job_title_id,
    job_title
)
SELECT
    ROW_NUMBER() OVER (ORDER BY job_title ASC),
    job_title
FROM
    dw_marts.main.job_postings_fact
WHERE 
    job_title IS NOT NULL
GROUP BY 
    job_title;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.bridge_job_title(
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY(job_title_short_id, job_title_id),
    FOREIGN KEY(job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY(job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);
INSERT INTO dw_marts.company_mart.bridge_job_title(
    job_title_short_id,
    job_title_id
)
SELECT DISTINCT
    job_title_short_id,
    job_title_id
FROM
    dw_marts.main.job_postings_fact AS jpf
INNER JOIN dw_marts.company_mart.dim_job_title_short AS djts
    ON djts.job_title_short = jpf.job_title_short
INNER JOIN dw_marts.company_mart.dim_job_title AS djt
    ON djt.job_title = jpf.job_title
WHERE jpf.job_title_short IS NOT NULL
    AND jpf.job_title IS NOT NULL;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.dim_company(
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR
);
INSERT INTO dw_marts.company_mart.dim_company(
    company_id,
    company_name
)
SELECT DISTINCT
    company_id,
    name
FROM
    dw_marts.main.company_dim
WHERE
    name IS NOT NULL;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.dim_location(
    location_id INTEGER PRIMARY KEY,
    job_country VARCHAR,
    job_location VARCHAR
);
INSERT INTO dw_marts.company_mart.dim_location(
    location_id,
    job_country,
    job_location
)
SELECT
    ROW_NUMBER() OVER(ORDER BY job_country ASC, job_location ASC),
    job_country,
    job_location
FROM
    dw_marts.main.job_postings_fact
WHERE
    job_country IS NOT NULL
    AND job_location IS NOT NULL
GROUP BY
    job_country,
    job_location
ORDER BY
    job_country,
    job_location;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.bridge_company_location(
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY(company_id, location_id),
    FOREIGN KEY(company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY(location_id) REFERENCES company_mart.dim_location(location_id)
);
INSERT INTO dw_marts.company_mart.bridge_company_location(
    company_id,
    location_id
)
SELECT DISTINCT
    dc.company_id,
    dl.location_id
FROM
    dw_marts.main.job_postings_fact AS jpf
INNER JOIN dw_marts.company_mart.dim_company AS dc
    ON dc.company_id = jpf.company_id
INNER JOIN dw_marts.company_mart.dim_location AS dl
    ON dl.job_location = jpf.job_location
    AND dl.job_country = jpf.job_country;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.dim_date_month(
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER
);
INSERT INTO dw_marts.company_mart.dim_date_month(
    month_start_date,
    year,
    month
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT('YEAR' FROM job_posted_date),
    EXTRACT('MONTH' FROM job_posted_date)
FROM
    dw_marts.main.job_postings_fact
ORDER BY month_start_date ASC;


CREATE TABLE IF NOT EXISTS dw_marts.company_mart.fact_company_hiring_monthly(
    company_id INTEGER,
    job_title_short_id INTEGER,
    month_start_date DATE,
    job_country VARCHAR,
    postings_count INTEGER,
    median_salary_year DOUBLE,
    min_salary_year DOUBLE,
    max_salary_year DOUBLE,
    remote_share DOUBLE,
    health_insurance_share DOUBLE,
    no_degree_mention_share DOUBLE,
    PRIMARY KEY(company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY(company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY(job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY(month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);
INSERT INTO dw_marts.company_mart.fact_company_hiring_monthly(
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH jpf_year_month AS(
    SELECT
        *,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
            ELSE NULL
        END AS combined_salary,
        EXTRACT('YEAR' FROM job_posted_date) AS year,
        EXTRACT('MONTH' FROM job_posted_date) AS month
    FROM dw_marts.main.job_postings_fact
    WHERE job_country IS NOT NULL
)
SELECT
    dc.company_id,
    djs.job_title_short_id,
    ddm.month_start_date,
    jpf.job_country,
    COUNT(jpf.*) AS postings_count,
    MEDIAN(jpf.combined_salary),
    MIN(jpf.combined_salary),
    MAX(jpf.combined_salary),
    AVG(CASE WHEN job_work_from_home = TRUE THEN 1 ELSE 0 END) AS remote_share,
    AVG(CASE WHEN job_health_insurance = TRUE THEN 1 ELSE 0 END) AS health_insurance_share,
    AVG(CASE WHEN job_no_degree_mention = TRUE THEN 1 ELSE 0 END) AS no_degree_mention_share
FROM
    jpf_year_month AS jpf
INNER JOIN dw_marts.company_mart.dim_company AS dc
    ON dc.company_id = jpf.company_id
INNER JOIN dw_marts.company_mart.dim_job_title_short AS djs
    ON djs.job_title_short = jpf.job_title_short
INNER JOIN dw_marts.company_mart.dim_date_month AS ddm
    ON ddm.year = jpf.year
    AND ddm.month = jpf.month
WHERE jpf.salary_year_avg IS NOT NULL
GROUP BY
    dc.company_id,
    djs.job_title_short_id,
    ddm.month_start_date,
    jpf.job_country;