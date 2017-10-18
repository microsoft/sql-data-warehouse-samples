using System;
using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Microsoft.WindowsAzure.Storage.Table;
using Microsoft.Azure.WebJobs.Host;
using SqlDwAutoScaler.Shared;

namespace SqlDwAutoScaler
{
    public class ScaleSqlDw
    {
        private static TraceWriter _logger;

        public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
        {
            log.Info($"ScaleSqlDW triggered!");
            DwScaleLogEntity logEntity = null;
            CloudTable dwuScaleLogsTable = null;
            _logger = log;

            try
            {
                var storageConnStr = ConfigurationManager.AppSettings["AzureWebJobsStorage"];
                var dwLocation = ConfigurationManager.AppSettings["SqlDwLocation"];
                var tableName = ConfigurationManager.AppSettings["DwScaleLogsTable"];
                var dwuConfigFile = ConfigurationManager.AppSettings["DwuConfigFile"];
                var dwuConfigManager = new DwuConfigManager(dwuConfigFile);

                string jsonContent = await req.Content.ReadAsStringAsync();
                dynamic alert = JsonConvert.DeserializeObject(jsonContent);

                if (alert == null || alert.status == null || alert.context == null)
                {
                    return req.CreateResponse(HttpStatusCode.BadRequest, new
                    {
                        error = "Request didn't have required data in it!"
                    });
                }

                // The function will be called both when the alert is Activated (that is, triggered) and when it is Resolved.
                // We only respond to Activated alert
                if (alert.status != "Activated")
                {
                    var message = $"Alert status is not activated! No scaling triggered!";
                    log.Info(message);
                    return req.CreateResponse(HttpStatusCode.OK, new
                    {
                        status = message
                    });
                }

                string alertName = alert.context.name;
                // Resource name in the alert looks like this: edudatawh/educationdatawh
                string dwName = alert.context.resourceName.ToString().Split('/')[1];
                string alertTimeStamp = alert.context.timestamp.ToString("yyyy-MM-ddTHH:mm:ssZ");

                // Get or create DW Scale logs table
                log.Info($"Get or create {tableName} table if it doesn't exist");
                dwuScaleLogsTable = TableClientFactory.CreateTableIfNotExists(storageConnStr, tableName);

                // Create log entity
                logEntity = new DwScaleLogEntity(dwName, alertTimeStamp)
                {
                    AlertName = alertName,
                    AlertCondition = alert.context.condition.ToString()
                };

                // Create a DataWarehouseManagementClient
                var dwClient = DwClientFactory.Create(alert.context.resourceId.ToString());
                // Get database information
                var dbInfo = dwClient.GetDatabase();
                dynamic dbInfoObject = JsonConvert.DeserializeObject(dbInfo);
                var currentDwu = dbInfoObject.properties.requestedServiceObjectiveName.ToString();
                logEntity.DwuBefore = currentDwu;
                log.Info($"Current DWU is {currentDwu}");

                if (alertName.IndexOf("scale up", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    var upLevelDwu = dwuConfigManager.GetUpLevelDwu(currentDwu);
                    if (upLevelDwu != currentDwu)
                    {
                        log.Info($"scale up to {upLevelDwu}");
                        logEntity.Action = "Scale Up";
                        dwClient.ScaleWarehouse(upLevelDwu, dwLocation);
                    }
                    else
                    {
                        log.Info($"Can't scale up. It's at MAX level {currentDwu} already");
                    }

                    logEntity.DwuAfter = upLevelDwu;
                }
                else if (alertName.IndexOf("scale down", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    if (IsInsideScaleUpScheduleTime())
                    {
                        var message = $"Can't scale down. It's inside scheduled scale up hours";
                        logEntity.Error = message;
                        log.Info(message);
                    }
                    else
                    {
                        var downLevelDwu = dwuConfigManager.GetDownLevelDwu(currentDwu);
                        if (downLevelDwu != currentDwu)
                        {
                            log.Info($"scale down to {downLevelDwu}");
                            logEntity.Action = "Scale Down";
                            dwClient.ScaleWarehouse(downLevelDwu, dwLocation);
                        }
                        else
                        {
                            log.Info($"Can't scale down. It's at MIN level {currentDwu} already");
                        }

                        logEntity.DwuAfter = downLevelDwu;
                    }
                }

                log.Info($"Insert log entity to DwScaleLogs table");
                TableOperation insertOperation = TableOperation.Insert(logEntity);
                dwuScaleLogsTable.Execute(insertOperation);

                return req.CreateResponse(HttpStatusCode.OK, new
                {
                    status = $"Done!"
                });
            }
            catch (Exception e)
            {
                log.Info($"ScaleSqlDW threw exception: {e.Message}");
                if (logEntity != null && dwuScaleLogsTable != null)
                {
                    logEntity.Error = e.Message;
                    TableOperation insertOperation = TableOperation.Insert(logEntity);
                    dwuScaleLogsTable.Execute(insertOperation);
                }

                return req.CreateResponse(HttpStatusCode.InternalServerError, new
                {
                    error = $"{e.Message}"
                });
            }
        }

        /// <summary>
        /// To determine if current time is within the scheduled scale up hours
        /// </summary>
        /// <returns>true if current time is within the scheduled scale up hours</returns>
        public static bool IsInsideScaleUpScheduleTime()
        {
            var scheduleStartTimeString = ConfigurationManager.AppSettings["ScaleUpScheduleStartTime"];
            var scheduleEndTimeString = ConfigurationManager.AppSettings["ScaleUpScheduleEndTime"];

            // If they are not found in app settings, return false
            if (string.IsNullOrEmpty(scheduleStartTimeString) || string.IsNullOrEmpty(scheduleEndTimeString))
            {
                return false;
            }

            string[] startTime = scheduleStartTimeString.Split(':');
            string[] endTime = scheduleEndTimeString.Split(':');

            // This is the time in Azure relative to the WEBSITE_TIME_ZONE setting
            var current = DateTime.Now;
            var scheduleStartTime = new DateTime(current.Year, current.Month, current.Day, Convert.ToInt32(startTime[0]), Convert.ToInt32(startTime[1]), Convert.ToInt32(startTime[2]), DateTimeKind.Utc);
            var scheduleEndTime = new DateTime(current.Year, current.Month, current.Day, Convert.ToInt32(endTime[0]), Convert.ToInt32(endTime[1]), Convert.ToInt32(endTime[2]), DateTimeKind.Utc);

            _logger.Info($"Scale up schedule start time is {scheduleStartTime}");
            _logger.Info($"Scale up schedule end time is {scheduleEndTime}");
            _logger.Info($"Current time is {current}");

            // If current time is between schedule start time and schedule end time
            if (DateTime.Compare(current, scheduleStartTime) >= 0 && DateTime.Compare(current, scheduleEndTime) <= 0)
            {
                return true;
            }
            return false;
        }
    }
}