-- Step 3: Mart - Create and load data from DW to FM
DROP SCHEMA IF EXISTS flat_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS flat_mart;

SELECT '=== Creating flat_table TABLE ===' AS info;
CREATE OR REPLACE TABLE dw_marts.flat_mart.flat_table AS
    SELECT
        jpf.* EXCLUDE(company_id),
        cd.*,
        LIST(
            STRUCT_PACK(
                skill_name := sd.skills,
                skill_type := sd.type
            )
        ) AS skills_and_type
    FROM
        job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd
        ON cd.company_id = jpf.company_id
    LEFT JOIN skills_job_dim AS sjd
        ON sjd.job_id = jpf.job_id
    LEFT JOIN skills_dim AS sd
        ON sd.skill_id = sjd.skill_id
    GROUP BY ALL;

SELECT 'Flat Table' AS name, format('{:,}', COUNT(*)) AS total_rows FROM dw_marts.flat_mart.flat_table;

SELECT * FROM dw_marts.flat_mart.flat_table LIMIT 5;