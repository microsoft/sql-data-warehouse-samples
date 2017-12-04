## Introduction

The following scripts is leveraged to create custom dashboard widgets in SQL Operations Studio for Azure SQL Data Warehouse. 

## Current Widgets

###
* **Table Health Count** - Lists the number of tables which may be suffering form low quality segments and number tables with statistics which have not been updates in the last 7 days
* **User Activities** - Lists the number of active sessions, queries, and queries which are queued
* **Storage Size** - Shows the total database size excluding the unallocated space
* **Data Distribution** - Shows the storage distribution across all distribution databases to help detect skew
* **Memory consumption percentage** - Shows the SQL Server memory consumption across all compute nodes
* **Tempdb space utilization** - Shows the tempdb memory consumption across all compute nodes

## Future Enhancements
* Specify Compute vs Control node
* Add details view for each widget



