/*
Question: What are the most optimal skills for data related jobs in Indonesia, balancing both demand and salary
- rank skills that combines both demand count and median salary to identify the overall most valuable skills
- Identifies the top 20 most optimal skills for data related jobs
- queries are focused on jobs in Indonesia

Why? The approach highlights skills that balance the market demand and financial incentives, weighting core skills appropriately.
*/

WITH base AS(
SELECT
    s.skills AS Skill_Name,
    s.type AS Skill_Type,
    COUNT(*) AS Postings_Count,
    ROUND(MEDIAN(CASE
        WHEN p.salary_year_avg IS NOT NULL THEN p.salary_year_avg
        -- 2080 is the total work hours in a week, assuming 40 hours × 52 weeks
        WHEN p.salary_hour_avg IS NOT NULL THEN p.salary_hour_avg * 2080
    END)) AS Median_Yearly_Salary
FROM
    data_jobs.main.job_postings_fact AS p
INNER JOIN data_jobs.main.skills_job_dim AS sj
    ON p.job_id = sj.job_id
INNER JOIN data_jobs.main.skills_dim AS s
    ON sj.skill_id = s.skill_id
WHERE
    (p.salary_year_avg IS NOT NULL 
    OR p.salary_hour_avg IS NOT NULL)
    AND p.job_title_short LIKE '%Data%'
    AND job_country = 'Indonesia'
GROUP BY
    s.skills,
    s.type
)

SELECT
    Skill_Name,
    Skill_Type,
    Postings_Count,
    Median_Yearly_Salary AS 'Median_Yearly_Salary_(Rp)',
    ROUND(
        /* 
        Used natural Log to compress skills with dominant job postings count.
        because before it was applied, the score was dominated by skills
        that has the most postings and the weightings from yearly salary
        was close to nonexistent.
        */
        (LN(Postings_Count) * Median_Yearly_Salary) / MAX(LN(Postings_Count) * Median_Yearly_Salary) OVER(),
    3) AS Composite_Score
FROM
    base
ORDER BY
    Composite_Score DESC
LIMIT 20;

/*
─────────────────────────────────────── Query Result ────────────────────────────────────────
Data analysis:

- AWS tops the composite_score despite not being the highest-paying skill. 
it balances solid median salary (Rp147.5k) with the strongest posting count (12) among higher tier skills. 

- SQL and Python score mid-table despite dominating in raw posting counts. 
They're still widely demanded but at lower salary levels (Rp.71k and Rp.70k), 
reflecting that they're prominent in entry level positions.

- The bottom half of the list are skills like Tableau, GCP, R.
they score lower due to the combination of modest salaries and limited postings,
suggesting these are supporting skills in the Indonesian market rather than primary hiring drivers.

┌────────────┬───────────────┬────────────────┬───────────────────────────┬─────────────────┐
│ Skill_Name │  Skill_Type   │ Postings_Count │ Median_Yearly_Salary_(Rp) │ Composite_Score │
│  varchar   │    varchar    │     int64      │          double           │     double      │
├────────────┼───────────────┼────────────────┼───────────────────────────┼─────────────────┤
│ aws        │ cloud         │             12 │                  147500.0 │             1.0 │
│ java       │ programming   │              9 │                  147500.0 │           0.884 │
│ spark      │ libraries     │              9 │                  134241.0 │           0.805 │
│ airflow    │ libraries     │              6 │                  157710.0 │           0.771 │
│ sql        │ programming   │             38 │                   70981.0 │           0.704 │
│ python     │ programming   │             37 │                   69963.0 │           0.689 │
│ redshift   │ cloud         │              6 │                  140871.0 │           0.689 │
│ kubernetes │ other         │              4 │                  153250.0 │            0.58 │
│ postgresql │ databases     │              4 │                  147500.0 │           0.558 │
│ flow       │ other         │              4 │                  140871.0 │           0.533 │
│ hadoop     │ libraries     │              6 │                  103324.0 │           0.505 │
│ excel      │ analyst_tools │             12 │                   72515.0 │           0.492 │
│ r          │ programming   │             17 │                   62400.0 │           0.482 │
│ go         │ programming   │              3 │                  147500.0 │           0.442 │
│ mysql      │ databases     │              3 │                  147500.0 │           0.442 │
│ scala      │ programming   │              3 │                  147500.0 │           0.442 │
│ bigquery   │ cloud         │             10 │                   68400.0 │            0.43 │
│ tableau    │ analyst_tools │             18 │                   54166.0 │           0.427 │
│ jenkins    │ other         │              3 │                  134241.0 │           0.402 │
│ gcp        │ cloud         │              7 │                   63960.0 │            0.34 │
├────────────┴───────────────┴────────────────┴───────────────────────────┴─────────────────┤
│ 20 rows                                                                         5 columns │
└───────────────────────────────────────────────────────────────────────────────────────────┘
*/