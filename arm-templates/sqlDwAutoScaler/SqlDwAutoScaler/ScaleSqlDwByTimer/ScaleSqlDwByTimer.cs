using System;
using System.Configuration;
using Microsoft.Azure.WebJobs.Host;
using Newtonsoft.Json;
using SqlDwAutoScaler.Shared;
using Microsoft.Azure.WebJobs;

namespace SqlDwAutoScaler
{
    public class ScaleSqlDwByTimer
    {
        public static void Run(TimerInfo myTimer, TraceWriter log)
        {
            log.Info($"ScaleSqlDwByTimer triggered!");

            try
            {
                var sqlServer = ConfigurationManager.AppSettings["SqlServerName"];
                var sqlDw = ConfigurationManager.AppSettings["SqlDwName"];
                var subscriptionId = ConfigurationManager.AppSettings["SubscriptionId"];
                var resourceGroup = ConfigurationManager.AppSettings["SqlDwResourceGroup"];
                var resourceId = $"/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Sql/servers/{sqlServer}/databases/{sqlDw}";
                var dwLocation = ConfigurationManager.AppSettings["SqlDwLocation"];
                var dwuConfigFile = ConfigurationManager.AppSettings["DwuConfigFile"];
                var dwuConfigManager = new DwuConfigManager(dwuConfigFile);

                // Create a DataWarehouseManagementClient
                var dwClient = DwClientFactory.Create(resourceId);
                // Get database information
                var dbInfo = dwClient.GetDatabase();
                dynamic dbInfoObject = JsonConvert.DeserializeObject(dbInfo);
                var currentDwu = dbInfoObject.properties.requestedServiceObjectiveName.ToString();
                log.Info($"Current DWU is {currentDwu}");

                // If current dwu is smaller than default dwu, then scale up to default dwu
                if (dwuConfigManager.CompareDwus(currentDwu, dwuConfigManager.DwuConfigs.DefaultDwu) < 0)
                {
                    log.Info($"Scale up to default {dwuConfigManager.DwuConfigs.DefaultDwu}");
                    dwClient.ScaleWarehouse(dwuConfigManager.DwuConfigs.DefaultDwu, dwLocation);
                }
                else
                {
                    log.Info($"No need to scale up. Current dwu is same or higher than default dwu {dwuConfigManager.DwuConfigs.DefaultDwu}");
                }
            }
            catch (Exception e)
            {
                log.Info($"ScaleSqlDwByTimer threw exception: {e.Message}");
            }
        }
    }
}