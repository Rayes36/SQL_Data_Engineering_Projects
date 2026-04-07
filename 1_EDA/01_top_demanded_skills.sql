/*
Question: What are the most in-demand skills for data related jobs in Indonesia
- Identifies the top 20 in-demand skills for data related jobs
- queries are focused on jobs in Indonesia

Why? The query provides insights into the most valuable skills for data related fields
located in Indonesia, useful for Indonesians job-seekers seeking data related jobs
*/

SELECT
    s.skills AS Skill_Name,
    COUNT(*) AS Total_Postings,
    s.type AS Skill_type
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
    Total_Postings >= 100
ORDER BY
    Total_Postings DESC
LIMIT 20;

/*
────────────────────── Query Result ───────────────────────
Data Analysis: 
- SQL and Python are the essential programming language, 
appearing in ~2,500 and ~2,200 postings respectively.

- For frameworks Spark and Hadoop dominates, 
reflecting strong demand for big data engineering roles.

- Not surprisingly AWS leads in cloud, 
the market is notably split across GCP, Azure, and BigQuery.

- On the BI side, Tableau edges out Power BI and Excel. 
though all three remains relevant and widely used.

- Databases are an even split between MySQL and PostgreSQL
with NoSQL surprisingly outranking both.

- Data pipeline tools like Airflow, Snowflake, 
and Databricks are showing growing demans.

- Popular skills like Java and R still remains in top 10

┌────────────┬────────────────┬───────────────┐
│ Skill_Name │ Total_Postings │  Skill_type   │
│  varchar   │     int64      │    varchar    │
├────────────┼────────────────┼───────────────┤
│ sql        │           2486 │ programming   │
│ python     │           2160 │ programming   │
│ spark      │            857 │ libraries     │
│ r          │            792 │ programming   │
│ hadoop     │            750 │ libraries     │
│ aws        │            707 │ cloud         │
│ tableau    │            676 │ analyst_tools │
│ java       │            588 │ programming   │
│ gcp        │            520 │ cloud         │
│ kafka      │            499 │ libraries     │
│ nosql      │            480 │ programming   │
│ azure      │            451 │ cloud         │
│ power bi   │            435 │ analyst_tools │
│ excel      │            423 │ analyst_tools │
│ airflow    │            405 │ libraries     │
│ bigquery   │            402 │ cloud         │
│ mysql      │            384 │ databases     │
│ postgresql │            318 │ databases     │
│ scala      │            312 │ programming   │
│ ssis       │            242 │ analyst_tools │
├────────────┴────────────────┴───────────────┤
│ 20 rows                           3 columns │
└─────────────────────────────────────────────┘
*/