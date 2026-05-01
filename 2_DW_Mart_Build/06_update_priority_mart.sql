-- Step 6: Mart - Batch pdate priority mart
SELECT '=== Creating source temporary table ===' AS info;
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS
    SELECT
        jpf.job_id,
        jpf.job_title_short,
        cd.name AS company_name,
        jpf.job_posted_date,
        jpf.salary_year_avg,
        pr.priority_lvl,
        current_timestamp AS updated_at
    FROM
        job_postings_fact AS jpf
    LEFT JOIN company_dim AS cd
        ON cd.company_id = jpf.company_id
    INNER JOIN dw_marts.priority_mart.priority_roles AS pr
        ON pr.role_name = jpf.job_title_short;


SELECT '=== Batch updating priority_jobs_snapshot for priority mart ===' AS info;
MERGE INTO dw_marts.priority_mart.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
    ON src.job_id = tgt.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT(
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )
    VALUES(
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_lvl,
        src.updated_at
    )

WHEN NOT MATCHED BY SOURCE THEN DELETE;

SELECT 'Priority Jobs Snapshot' AS name, format('{:,}', COUNT(*)) AS total_rows FROM dw_marts.priority_mart.priority_jobs_snapshot;

SELECT * FROM dw_marts.priority_mart.priority_jobs_snapshot LIMIT 5;