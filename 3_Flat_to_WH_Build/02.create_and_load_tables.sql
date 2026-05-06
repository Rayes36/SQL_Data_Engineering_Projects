DROP TABLE IF EXISTS company_dim;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS skills_job_dim;

CREATE TABLE IF NOT EXISTS company_dim(
    company_id INTEGER PRIMARY KEY,
    name VARCHAR,
);
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
    skills INTEGER,
    type VARCHAR
);
INSERT INTO company_dim(
    skill_id,
    skills,
    type
)
SELECT
    STRING_SPLIT(job_skills, ','),
    job_skills
FROM
    job_postings_flat
LIMIT 1
;


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

CREATE TABLE IF NOT EXISTS skills_job_dim(
    job_id INTEGER,
    skill_id INTEGER,
    PRIMARY KEY(job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);