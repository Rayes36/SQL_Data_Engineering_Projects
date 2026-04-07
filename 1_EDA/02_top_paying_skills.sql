/*
Question: What are the highest-paying skills for data related jobs in Indonesia
- calculated the median salary for each skill required in data related jobs
- Identifies the top 20 highest-paying skills for data related jobs
- queries are focused on jobs in Indonesia

Why? The query provides insights into the skills that commands the highest compensation 
for data related fields located in Indonesia, useful for Indonesians job-seekers seeking data related jobs
*/

SELECT
    s.skills AS Skill_Name,
    s.type AS Skill_Type,
    ROUND(MEDIAN(CASE
        WHEN p.salary_year_avg IS NOT NULL THEN p.salary_year_avg
        -- 2080 is the total work hours in a week, assuming 40 hours × 52 weeks
        WHEN p.salary_hour_avg IS NOT NULL THEN p.salary_hour_avg * 2080
    END)) AS 'Median_Yearly_Salary_(Rp)'
FROM 
    data_jobs.main.job_postings_fact AS p
INNER JOIN data_jobs.main.skills_job_dim AS sj
    ON p.job_id = sj.job_id
INNER JOIN data_jobs.main.skills_dim AS s
    ON sj.skill_id = s.skill_id
WHERE
    p.job_country = 'Indonesia'
    AND p.job_title_short LIKE '%Data%'
GROUP BY
    s.skills,
    s.type
HAVING
-- 'COUNT(*) >= 100' is used to remove skills that are outliers
    COUNT(*) >= 100
ORDER BY
    "Median_Yearly_Salary_(Rp)" DESC
LIMIT 20;


/*
────────────────────── Query Result ───────────────────────
Data Analysis:

- Snowflake and Airflow is held as the highest salaries at Rp.176k and Rp.157k respectively, 
suggesting cloud data warehousing and pipeline orchestration are the most lucrative specializations. 

- Docker and Kubernetes are tied at Rp.153k, reflecting strong demand for containerization skills 
and likely tied to MLOps and data engineering roles. 

- Most of the middle tier clusters tightly around Rp.147.5k across
databases (MySQL, MongoDB, PostgreSQL), cloud (AWS, Oracle), and programming languages (Java, Scala). 
suggesting that once you're past the top tools, compensation levels out. 

Hadoop and Linux sit notably lower at Rp.103k and Rp.99k,
hinting that older big data and OS skills are becoming less premium.

┌────────────┬─────────────┬─────────────────────────────┐
│ Skill_Name │ Skill_Type  │ Median_Yearly_Salary_(Rp)   │
│  varchar   │   varchar   │           double            │
├────────────┼─────────────┼─────────────────────────────┤
│ snowflake  │ cloud       │                    176000.0 │
│ airflow    │ libraries   │                    157710.0 │
│ docker     │ other       │                    153250.0 │
│ kubernetes │ other       │                    153250.0 │
│ oracle     │ cloud       │                    147500.0 │
│ mysql      │ databases   │                    147500.0 │
│ mongodb    │ databases   │                    147500.0 │
│ java       │ programming │                    147500.0 │
│ mongodb    │ programming │                    147500.0 │
│ scala      │ programming │                    147500.0 │
│ postgresql │ databases   │                    147500.0 │
│ aws        │ cloud       │                    147500.0 │
│ redshift   │ cloud       │                    140871.0 │
│ flow       │ other       │                    140871.0 │
│ nosql      │ programming │                    139540.0 │
│ spark      │ libraries   │                    134241.0 │
│ pandas     │ libraries   │                    131580.0 │
│ git        │ other       │                    112121.0 │
│ hadoop     │ libraries   │                    103324.0 │
│ linux      │ os          │                     99521.0 │
├────────────┴─────────────┴─────────────────────────────┤
│ 20 rows                                      3 columns │
└────────────────────────────────────────────────────────┘
*/