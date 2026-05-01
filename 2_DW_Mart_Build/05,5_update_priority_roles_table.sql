-- Step 5,5: Priority Mart - Run only to update the priority roles TABLE
DROP TABLE IF EXISTS dw_marts.priority_mart.priority_roles;

CREATE TABLE IF NOT EXISTS dw_marts.priority_mart.priority_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

SELECT '=== Loading priority_roles TABLE ===' AS info;
INSERT INTO dw_marts.priority_mart.priority_roles(
    role_id,
    role_name,
    priority_lvl
)
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Data Analyst', 1),
    (3, 'Data Scientist', 3);