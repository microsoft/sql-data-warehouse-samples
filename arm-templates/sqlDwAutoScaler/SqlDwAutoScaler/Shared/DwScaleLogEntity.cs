using Microsoft.WindowsAzure.Storage.Table;

namespace SqlDwAutoScaler.Shared
{
    public class DwScaleLogEntity : TableEntity
    {
        public DwScaleLogEntity(string resourceName, string alertTimeStamp)
        {
            // Have to set PartitionKey and RowKey
            PartitionKey = resourceName;
            RowKey = alertTimeStamp;
        }

        // TableQuery Generic Type must provide a default parameterless constructor.
        public DwScaleLogEntity() { }

        // Can't leave properties as null, it will throw exception when inserting to table
        public string AlertName { get; set; } = "";

        public string AlertCondition { get; set; } = "";

        // The action taken for the alert, e.g. "Scale Up" or "Scale Down"
        public string Action { get; set; } = "";

        // The DWU config before action
        public string DwuBefore { get; set; } = "";

        // The DWU config after action is taken on the alert
        public string DwuAfter { get; set; } = "";

        public string Error { get; set; } = "";
    }
}