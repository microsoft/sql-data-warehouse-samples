# DBLoader Utility

The DBLoader can be used to load data from delimited text files into SQL Server. This Windows console utility uses the SQL Server native client bulk load interface, which works on all versions of SQL Server, including Azure SQL DB, Azure SQL MI and Azure SQL DW. 

The files that DBLoader imports can be located on a windows file system, Azure Blob Storage or Azure Data Lake Storage. The files can be uncompressed or gzip compressed. The utility only supports the specification of a single destination table, so loading multiple tables will require multiple executions. Wildcards are supported, to enable the utility to load all the files in a folder to the same table. The schema of the file is inferred from the schema of the SQL Server table.

The DBLoader utility is not meant as a replacement for Polybase for loading data into Azure SQL DW. If optimized properly, Polybase will load files on all of the compute nodes in the DW cluster, while DBLoader uses the bulk load interface, which must first traverse the single control node. 

Additional documentation on utility usage can be found in the [DBLoader word document](https://github.com/Microsoft/sql-data-warehouse-samples/samples/utility/DBLoader/DBLoader.docx).

Any comments or questions can be directed to the utility author: Mitch van Huuksloot, Solution Architect, Data Migration Jumpstart Engineering Team (email is name with periods @ Microsoft.com).
