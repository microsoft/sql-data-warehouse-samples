
/*
IF EXISTS ( SELECT * FROM sys.views WHERE name = 'vStorageSize' )
	DROP VIEW [dbo].[vStorageSize];
GO
CREATE VIEW vStorageSize
AS 
SELECT 
    SUM(reserved_space_GB)        as reserved_space_GB
,    SUM(data_space_GB)            as data_space_GB
,    SUM(index_space_GB)           as index_space_GB
,    SUM(unused_space_GB)          as unused_space_GB
FROM dbo.vTableSizes
;

GO
*/
--select 'reserved_space_GB', reserved_space_GB from vStorageSize
--union all
select 'data_space_GB', data_space_GB from vStorageSize
union all
select 'index_space_GB', index_space_GB from vStorageSize
union all
select 'unused_space_GB', unused_space_GB from vStorageSize

