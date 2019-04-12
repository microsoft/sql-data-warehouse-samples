-- Remove the procedures
PRINT 'Info: Removing the ''microsoft.sp_create_statistics'' procedure';
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'sp_create_statistics')
    DROP PROCEDURE microsoft.sp_create_statistics;
GO

-- Remove the views
PRINT 'Info: Removing the ''microsoft.vw_sql_requests'' view';
GO
IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_sql_requests')
    DROP VIEW microsoft.vw_sql_requests;
GO

PRINT 'Info: Removing the ''microsoft.vw_query_step_details'' view';
GO
IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_query_step_details')
    DROP VIEW microsoft.vw_query_step_details;
GO

PRINT 'Info: Removing the ''microsoft.vw_query_steps'' view';
GO
IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_query_steps')
    DROP VIEW microsoft.vw_query_steps;
GO

PRINT 'Info: Removing the ''microsoft.vw_active_queries'' view';
GO
IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_active_queries')
    DROP VIEW microsoft.vw_active_queries;
GO

PRINT 'Info: Removing the ''microsoft.vw_query_queue'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_query_queue')
    DROP VIEW microsoft.vw_query_queue;
GO

PRINT 'Info: Removing the ''microsoft.vw_query_slots'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_query_slots')
    DROP VIEW microsoft.vw_query_slots;
GO

PRINT 'Info: Removing the ''microsoft.vw_security_role_members'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_security_role_members')
    DROP VIEW microsoft.vw_security_role_members;
GO

PRINT 'Info: Removing the ''microsoft.vw_statistics_age'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_statistics_age')
    DROP VIEW microsoft.vw_statistics_age;
GO

PRINT 'Info: Removing the ''microsoft.vw_table_sizes'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_table_sizes')
    DROP VIEW microsoft.vw_table_sizes;
GO

PRINT 'Info: Removing the ''microsoft.vw_table_space_by_distribution'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_table_space_by_distribution')
    DROP VIEW microsoft.vw_table_space_by_distribution;
GO

PRINT 'Info: Removing the ''microsoft.vw_table_space_by_distribution_type'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_table_space_by_distribution_type')
    DROP VIEW microsoft.vw_table_space_by_distribution_type;
GO

PRINT 'Info: Removing the ''microsoft.vw_table_space_by_index_type'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_table_space_by_index_type')
    DROP VIEW microsoft.vw_table_space_by_index_type;
GO

PRINT 'Info: Removing the ''microsoft.vw_table_space_summary'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_table_space_summary')
    DROP VIEW microsoft.vw_table_space_summary;
GO

PRINT 'Info: Removing the ''microsoft.vw_tables_with_skew'' view';
GO

IF EXISTS (SELECT * FROM sys.views WHERE SCHEMA_NAME(schema_id) = N'microsoft' AND name = N'vw_tables_with_skew')
    DROP VIEW microsoft.vw_tables_with_skew;
GO

-- Remove the schema as the last step
PRINT 'Info: Removing the ''microsoft'' schema';
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = N'microsoft')
    DROP SCHEMA microsoft;
GO