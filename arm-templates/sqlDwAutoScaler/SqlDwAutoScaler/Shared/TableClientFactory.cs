using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;

namespace SqlDwAutoScaler.Shared
{
    public class TableClientFactory
    {
        /// <summary>
        /// Create cloud table client for the storage account
        /// </summary>
        /// <param name="storageConnStr">Storage connection string</param>
        /// <returns>Cloud table client</returns>
        public static CloudTableClient CreateCloudTableClient(string storageConnStr)
        {
            // Retrieve the storage account from the connection string.
            var storageAccount = CloudStorageAccount.Parse(storageConnStr);

            var tableClient = storageAccount.CreateCloudTableClient();

            return tableClient;
        }

        /// <summary>
        /// Create a table reference for the given table
        /// </summary>
        /// <param name="storageConnStr">Storage connection string</param>
        /// <param name="tableName">Table name</param>
        /// <returns>Cloud table</returns>
        public static CloudTable CreateTableIfNotExists(string storageConnStr, string tableName)
        {
            var tableClient = CreateCloudTableClient(storageConnStr);

            // Retrieve a reference to the table.
            var table = tableClient.GetTableReference(tableName);

            table.CreateIfNotExists();

            return table;
        }
    }
}