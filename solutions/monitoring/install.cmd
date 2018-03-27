@echo off

setlocal

set _server=usher2.database.windows.net
set _database=demodw
set _username=cloudsa
set _password=Brenda99

@echo.
@echo ============================================================
@echo Installing the Microsoft Toolkit for SQL Data Warehouse
@echo.
@echo Server:    %_server%
@echo Database:  %_database%
@echo User:      %_username%
@echo Password:  **********
@echo ============================================================
@echo.

echo Removing any previous installations
echo.

REM Cleaning any previous installations
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\clean.sql

echo.
echo Starting the installations
echo.

REM Installing the schema
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\schema\microsoft.sql

REM Installing the views
REM Query Views
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_queue.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_slots.sql

REM Security Views
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_security_role_members.sql

REM Statistic Views
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_statistics_age.sql

REM Table Views
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_table_sizes.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_table_space_by_distribution.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_table_space_by_distribution_type.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_table_space_by_index_type.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_table_space_summary.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_tables_with_skew.sql

REM Statistic Procedures
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\procs\microsoft.sp_create_statistics.sql