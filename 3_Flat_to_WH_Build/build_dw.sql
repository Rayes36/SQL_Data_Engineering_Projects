-- .read build_dw.sql
-- duckdb md:dw_marts -c ".read build_dw.sql"

-- Step 1: Load flat data from CSV
.read 01_load_flat_data.sql

-- Step 2: Create and load DW tables from flat data
.read 02_create_and_load_tables.sql

-- Step 3: Verify schema and data integrity
.read 03_verify_schema.sql

SELECT '=== All processes are done ===' AS info;