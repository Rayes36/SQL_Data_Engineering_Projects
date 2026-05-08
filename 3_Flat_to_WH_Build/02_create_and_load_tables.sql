-- Step 2: Create and load DW tables from flat data
DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS company_dim;
DROP TABLE IF EXISTS skills_dim;

CREATE TABLE IF NOT EXISTS company_dim(
    company_id INTEGER PRIMARY KEY,
    name VARCHAR
);
SELECT '=== Loading company_dim ===' AS info;
INSERT INTO company_dim(
    company_id,
    name
)
SELECT
    ROW_NUMBER() OVER(ORDER BY company_name ASC),
    company_name
FROM
    job_postings_flat
GROUP BY
    company_name;


CREATE TABLE IF NOT EXISTS skills_dim(
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);
SELECT '=== Loading skills_dim ===' AS info;
INSERT INTO skills_dim(
    skill_id,
    skills,
    type
)
WITH formatted_skills AS (
    SELECT DISTINCT
        unnest(json_extract_string(entry.value, '$[*]')) AS skill_name,
        entry.key AS skill_type
    FROM job_postings_flat,
        json_each(replace(job_type_skills, '''', '"')::JSON) AS entry
    WHERE
        job_type_skills IS NOT NULL
)
SELECT
    ROW_NUMBER() OVER (ORDER BY skill_name ASC),
    skill_name,
    skill_type
FROM
    formatted_skills;


CREATE TABLE IF NOT EXISTS job_postings_fact(
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER,
    job_title_short VARCHAR,
    job_title VARCHAR,
    job_location VARCHAR,
    job_via VARCHAR,
    job_schedule_type VARCHAR,
    job_work_from_home BOOLEAN,
    search_location VARCHAR,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country VARCHAR,
    salary_rate VARCHAR,
    salary_year_avg DOUBLE,
    salary_hour_avg DOUBLE,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);
SELECT '=== Loading job_postings_fact ===' AS info;
INSERT INTO job_postings_fact(
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
    ROW_NUMBER() OVER (ORDER BY jpf.job_posted_date, jpf.job_title),
    company_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg
FROM
    job_postings_flat AS jpf
LEFT JOIN company_dim AS cd
    ON cd.name = jpf.company_name;


CREATE TABLE IF NOT EXISTS skills_job_dim(
    job_id INTEGER,
    skill_id INTEGER,
    PRIMARY KEY(job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);
SELECT '=== Loading skills_job_dim ===' AS info;
INSERT INTO skills_job_dim(
    job_id,
    skill_id
)
WITH postings_flat_with_skills AS (
    SELECT
        *,
        unnest(json_extract_string(entry.value, '$[*]')) AS skill_name
    FROM job_postings_flat,
        json_each(replace(job_type_skills, '''', '"')::JSON) AS entry
    WHERE
        job_type_skills IS NOT NULL
)
SELECT DISTINCT
    jpc.job_id,
    sd.skill_id
FROM
    postings_flat_with_skills AS jps
INNER JOIN job_postings_fact AS jpc
    ON jpc.job_title = jps.job_title
    AND jpc.job_posted_date = jps.job_posted_date
    AND jpc.company_id = (
        SELECT 
            company_id
        FROM
            company_dim
        WHERE
            name = jps.company_name
    )
INNER JOIN skills_dim AS sd
    ON sd.skills = jps.skill_name;