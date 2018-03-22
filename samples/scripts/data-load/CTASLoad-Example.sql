-- STEP 1: Create a master key. Only necessary if one does not already exist.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MyUltraSecurePassword!12345!'; 
GO

-- STEP 2: Create a database scoped credential
-- Azure Data Lake Credential
CREATE DATABASE SCOPED CREDENTIAL AzureCredential
WITH IDENTITY = '<AAD AppID>@https://login.microsoftonline.com/<subscriptionid>/oauth2/token',
     SECRET = '<secret key>';

/* Blob Storage Credential
CREATE DATABASE SCOPED CREDENTIAL AzureCredential 
WITH IDENTITY = 'SHARED ACCESS SIGNATURE', 
	 SECRET = 'your key here';
*/

-- STEP 3: Create an external data source - type HADOOP for ADLS
CREATE EXTERNAL DATA SOURCE AzureStorage
WITH (TYPE = HADOOP, LOCATION = 'adl://<adls name>.azuredatalakestore.net', CREDENTIAL = AzureCredential);
GO

/* Blob Storage Data Source - wabs syntax with Hadoop type
CREATE EXTERNAL DATA SOURCE AzureStorage
WITH (TYPE = HADOOP, LOCATION = 'wasbs://container@storageacct.blob.core.windows.net',
      CREDENTIAL = AzureCredential);
*/	

-- STEP 4: Create an external file format 
CREATE EXTERNAL FILE FORMAT TextFileFormat 
WITH	(FORMAT_TYPE = DELIMITEDTEXT, FORMAT_OPTIONS
			(FIELD_TERMINATOR = ',', STRING_DELIMITER = '"', -- DATE_FORMAT = 'yyyy-MM-dd HH:mm:ss.fff', 
			USE_TYPE_DEFAULT = FALSE), 
			DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
		);
GO

-- STEP 5: Create external table pointing to blob storage files
CREATE EXTERNAL TABLE [ext_ACCOUNT_FACT]
(
   [ACCT_PK_ID] bigint NOT NULL,
   [PERSON_PK_ID] bigint NOT NULL,
   [SALES_PERSON_PK_ID] int NOT NULL,
   [BATCH_ID] bigint  NULL,
   [START_TMSP] datetime  NULL,
   [END_TMSP] datetime  NULL,
   [ACCT_NAME] varchar(50)  NULL,
   [ACCT_FLAG] varchar(2)  NULL,
   [ACCT_STATUS] varchar(24)  NULL,
   [ACCT_STATUS_CHG_DATE] datetime  NULL,
   [ACCT_TYPE_CODE] varchar(30)  NULL
)
WITH ( LOCATION='/data/test/', DATA_SOURCE = AzureStorage, FILE_FORMAT = TextFileFormat, REJECT_TYPE = VALUE, REJECT_VALUE = 0 );
GO

-- STEP 6: Create Table As Select (CTAS) operation - invokes Polybase to pull information out of one or more text files in ADLS into DW tables
-- note you need to split the input text files to take advantage of parallel load on the compute nodes
CREATE TABLE [POC_DM].[ACCOUNT_FACT]
WITH (DISTRIBUTION = HASH([ACCT_PK_ID])) 
AS SELECT * FROM ext_ACCOUNT_FACT
OPTION (LABEL = 'CTAS : Load ACCOUNT_FACT');
GO

