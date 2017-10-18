using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using Microsoft.WindowsAzure;

namespace SqlDwAutoScaler.Shared
{
    public class DwManagementClient
    {
        // Actual rest end point url for the Azure Data Warehouse. this 
        // is created from the resource names etc.
        private string restEndPointUrl;

        // Rest End Point base Url pattern that will be used to construct the actual url.
        private string restEndPointBaseUrl = @"https://management.azure.com/{0}";

        private string apiVersion = @"api-version=2015-01-01";

        // Azure TokenCloudCredentials instance to store the access token.
        private TokenCloudCredentials cloudCredentials;

        // http client (one per instance) to send the http requests efficiently.
        private HttpClient httpClient;

        /// <summary>
        /// Creates the datewarehouse management client object based on the parameters
        /// specified.
        /// </summary>
        /// <param name="cloudCredentials">Cloud token credentials</param>
        /// <param name="resourceId">Resource Id in this format: /subscriptions/subscriptionId/resourceGroups/resourceGroupName/providers/Microsoft.Sql/servers/serverName/databases/dbName
        /// </param>
        public DwManagementClient(TokenCloudCredentials cloudCredentials, string resourceId)
        {
            if (string.IsNullOrEmpty(resourceId))
                throw new ArgumentNullException(nameof(resourceId));

            this.restEndPointUrl = string.Format(restEndPointBaseUrl, resourceId);
            this.cloudCredentials = cloudCredentials;
            this.httpClient = new HttpClient();
        }

        /// <summary>
        /// Get information for the database
        /// </summary>
        public string GetDatabase()
        {
            string getRestEndPoint = $"{restEndPointUrl}?{apiVersion}";
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, getRestEndPoint);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", cloudCredentials.Token);

            HttpResponseMessage response = httpClient.SendAsync(request).Result;

            if (!response.IsSuccessStatusCode)
                throw new WebException($"Get Database operation failed with response from server {response.StatusCode}: {response.ReasonPhrase}");

            string content = response.Content.ReadAsStringAsync().Result;
            return content;
        }

        /// <summary>
        /// Pauses the DataWarehouse instance. Pause implies that datawarehouse cannot run any queries
        /// or do any ingestion. The compute cost will be zero if the datawarehouse is paused for a full hour.
        /// 
        /// Please note that this API invokes the Pause Async API on Azure service. Service does not let
        /// the API know if the operation is complete. Typically the pausing operation takes a minute
        /// or two for completion. It is upto the caller to ensure to add wait in their code. There 
        /// is no programmatic way to query DWH status as of now. 
        /// </summary>
        public void Pause()
        {
            string pauseRestEndPoint = $"{restEndPointUrl}/pause?{apiVersion}";
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, pauseRestEndPoint);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", cloudCredentials.Token);
            HttpResponseMessage response = httpClient.SendAsync(request).Result;

            if (!response.IsSuccessStatusCode)
                throw new WebException($"Pause Database operation failed with response from server {response.StatusCode}: {response.ReasonPhrase}");

            string content = response.Content.ReadAsStringAsync().Result;
        }

        /// <summary>
        /// Resumes the DataWarehouse instance. Resume implies that datawarehouse can run any queries
        /// or do any ingestion. The compute cost will be charged as per DWH config.
        /// 
        /// Please note that this API invokes the Resume Async API on Azure service. Service does not let
        /// the API know if the operation is complete. Typically the resume operation takes 2 to 3
        /// minutes for completion. It is upto the caller to ensure to add wait in their code. There 
        /// is no programmatic way to query DWH status as of now. 
        /// </summary>
        public void Resume()
        {
            string resumeRestEndPoint = $"{restEndPointUrl}/resume?{apiVersion}";
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, resumeRestEndPoint);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", cloudCredentials.Token);
            HttpResponseMessage response = httpClient.SendAsync(request).Result;

            if (!response.IsSuccessStatusCode)
                throw new WebException($"Resume Database operation failed with response from server {response.StatusCode}: {response.ReasonPhrase}");

            string content = response.Content.ReadAsStringAsync().Result;
        }

        /// <summary>
        /// Scales the DataWarehouse instance to the specified config. This would allow to scale
        /// the DWH up or down dynamically based on demand.
        /// 
        /// Please note that this API invokes the Scale Async API on Azure service. Service does not let
        /// the API know if the operation is complete. Typically the scale operation takes 2 to 3 minutes
        /// for completion. It is up to the caller to ensure to add wait in their code. There 
        /// is no programmatic way to query DWH status or config as of now.
        /// </summary>
        /// <param name="config">The DWU config string. e.g. "DW1000"</param>
        /// <param name="location">The location of the SQL DW, e.g. "westus2"</param>
        public void ScaleWarehouse(string config, string location)
        {
            // The location property is required for this definition.
            string json = $"{{'location': '{location}','properties':{{'requestedServiceObjectiveName':'{config}'}}}}";
            json = json.Replace("'", @"""");

            string scaleRestEndPoint = $"{restEndPointUrl}?{apiVersion}";
            HttpRequestMessage request = new HttpRequestMessage
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json"),
                Method = HttpMethod.Put,
                RequestUri = new Uri(scaleRestEndPoint)
            };
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", cloudCredentials.Token);

            HttpResponseMessage response = httpClient.SendAsync(request).Result;

            if (!response.IsSuccessStatusCode)
                throw new WebException($"ScaleWarehouse Database operation failed with response from server {response.StatusCode}: {response.ReasonPhrase}");

            string content = response.Content.ReadAsStringAsync().Result;
        }
    }
}