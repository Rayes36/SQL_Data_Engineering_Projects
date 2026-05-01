-- .read build_dw_marts.sql
-- duckdb md:dw_marts -c ".read build_dw_marts.sql"

-- Step 1: DW - Create star schema tables
.read 01_create_tables_dw.sql

-- Step 2: DW - Load data from CSV files into tables
.read 02_load_schema_dw.sql

-- Step 3: Flat Mart - Create and load data from DW to Mart
.read 03_create_flat_mart.sql

-- Step 4: Skills Mart - Create and load data from DW to SM
.read 04_create_skils_mart.sql

-- Step 5: Priority Mart - Create priority roles mart
.read 05_create_priority_mart.sql
-- step 5,5: Priority Mart - Run only to update the priority roles TABLE
-- .read 05,5_update_priority_roles_table.sql

-- Step 6: Priority Mart - Update priority mart
.read 06_update_priority_mart.sql

SELECT '=== All processes are done ===' AS info;
