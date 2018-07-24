@echo off

setlocal

REM Parameter validation
if "%~1"=="" goto blank
if "%~2"=="" goto blank
if "%~3"=="" goto blank
if "%~4"=="" goto blank

set _server=%1
set _database=%2
set _username=%3
set _password=%4

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

echo Removing any previous installation
echo.

REM Cleaning any previous installations
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\clean.sql

echo.
echo Starting the installation
echo.

REM Installing the schema
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\schema\microsoft.sql

REM Installing the views
REM Query Views
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_active_queries.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_queue.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_slots.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_steps.sql
sqlcmd -S %_server% -d %_database% -U %_username% -P %_password% -I -i .\scripts\views\microsoft.vw_query_step_details.sql

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

@echo.
@echo Installation is complete.

goto EOF


:blank
@echo.
@echo ============================================================
@echo Microsoft Toolkit for SQL Data Warehouse
@echo.
@echo Usage:
@echo.
@echo install.cmd ^<server^> ^<database^> ^<username^> ^<password^>
@echo ============================================================
@echo.

:EOF