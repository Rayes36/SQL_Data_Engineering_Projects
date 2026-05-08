-- Step 3: Verify schema and data integrity

SELECT 'Job Postings Flat' AS table_name, format('{:,}', COUNT(*)) AS total_rows FROM job_postings_flat
UNION ALL
SELECT 'Company Dimension', format('{:,}', COUNT(*)) FROM company_dim
UNION ALL
SELECT 'Skills Dimension', format('{:,}', COUNT(*)) FROM skills_dim
UNION ALL
SELECT 'Job Postings Fact', format('{:,}', COUNT(*)) FROM job_postings_fact
UNION ALL
SELECT 'Skills Job Dimension', format('{:,}', COUNT(*)) FROM skills_job_dim;

SELECT '=== Job Postings Flat Sample ===' AS info;
SELECT * FROM job_postings_flat LIMIT 5;

SELECT '=== Company Dimension Sample ===' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT '=== Skills Dimension Sample ===' AS info;
SELECT * FROM skills_dim LIMIT 5;

SELECT '=== Job Postings Fact Sample ===' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '=== Skills Job Dimension Sample ===' AS info;
SELECT * FROM skills_job_dim LIMIT 5;