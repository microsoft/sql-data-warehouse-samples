using Microsoft.Azure.Management.DataFactories.Models;
using Microsoft.Azure.Management.DataFactories.Runtime;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Newtonsoft.Json.Linq;
using RestSharp;
using RestSharp.Authenticators;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace Microsoft.Azure.SqlDataWarehouse.Management
{
    public class ManagementActivity : IDotNetActivity
    {
        private const string AZURE_MANAGEMENT_URL = "https://management.azure.com";

        private const string AZURE_DATAWAREHOUSE_PAUSE_URL_PART = @"subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Sql/servers/{2}/databases/{3}/pause?api-version=2014-04-01-preview";
        private const string AZURE_DATAWAREHOUSE_RESUME_URL_PART = @"subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Sql/servers/{2}/databases/{3}/resume?api-version=2014-04-01-preview";
        private const string AZURE_DATAWAREHOUSE_SCALE_URL_PART = @"subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Sql/servers/{2}/databases/{3}?api-version=2014-04-01-preview";
        private const string AZURE_DATAWAREHOUSE_STATUS_URL_PART = @"subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Sql/servers/{2}/databases/{3}?api-version=2014-04-01-preview";

        private const string EXTENDED_PROPERTY_LOCATION = "Location";
        private const string EXTENDED_PROPERTY_RESOURCE_GROUP = "ResourceGroup";
        private const string EXTENDED_PROPERTY_SUBSCRIPTION_ID = "SubscriptionId";

        private const string STATUS_PROPERTY = "properties.status";

        private const string USER_AGENT = "ManagementActivityADF";

        private string BuildUrl(string baseUrl, Instance instance)
        {
            // Validate the input
            baseUrl.ThrowIfNullOrEmpty();
            instance.ThrowIfNull();

            // Build the URL part
            var url = string.Format(baseUrl, instance.SubscriptionId, instance.ResourceGroup, instance.Server, instance.Database);

            // return
            return url;
        }

        /// <summary>
        /// Execute method is the only method of IDotNetActivity interface you must implement.
        /// In this sample, the method invokes the Calculate method to perform the core logic.  
        /// </summary>
        public IDictionary<string, string> Execute(IEnumerable<LinkedService> linkedServices, IEnumerable<Dataset> datasets, Activity activity, IActivityLogger logger)
        {
            // Validate all input
            linkedServices.ThrowIfNull();
            datasets.ThrowIfNull();
            activity.ThrowIfNull();
            logger.ThrowIfNull();

            try
            {
                // Set the local logger
                Logger = logger;

                // Grab the extended properties defined in the activity JSON
                var dotNetActivity = (DotNetActivity)activity.TypeProperties;

                // Log all of the extended properties
                IDictionary<string, string> extendedProperties = dotNetActivity.ExtendedProperties;

                // Log the extended properties
                LogExtendedProperties(extendedProperties);

                // Iterate the linked services
                LogLinkedServices(linkedServices);

                // Iterate through the datasets
                LogDatasets(datasets);

                // Determine the ActionType
                var actionType = GetActionType(extendedProperties["ActionType"]);
                
                // Get the database details
                var instance = GetInstance(linkedServices, extendedProperties);

                ProcessAction(actionType, instance);
            }
            catch(Exception ex)
            {
                throw ex;
            }

            // Default output - this activity does not pass on variables to chain the activity.
            return new Dictionary<string, string>();
        }

        private string ExecuteRequest(string url, Method method)
        {
            // Validate the input
            url.ThrowIfNullOrEmpty();
            method.ThrowIfNull();

            // Get a client to execute the request
            var client = GetRequestClient();

            // Create a new request
            var request = new RestRequest(url, method);

            // Execute the call and get the response
            var response = client.Execute(request);

            // return the response
            return response.Content;
        }

        private string GetAccessToken()
        {
            string AdfClientId = "7e2843e6-9700-43a7-82e8-cbb01cb0fb82";
            string AdfClientSecret = "DsAjgWbnF+RK/1e6V7yEODWgqLShcuDrgZ6BbDcUlUE=";
            AuthenticationResult result = null;

            var context = new AuthenticationContext("https://login.windows.net/microsoft.onmicrosoft.com");
            ClientCredential cc = new ClientCredential(AdfClientId, AdfClientSecret);

            result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;

            if (result == null)
            {
                throw new InvalidOperationException("Failed to obtain the JWT token");
            }

            return result.AccessToken;
        }

        private ActionType GetActionType(string value)
        {
            value.ThrowIfNull();

            if (!Enum.IsDefined(typeof(ActionType), value))
            {
                throw new ArgumentException(string.Format("ActionType {0} is invalid.", value));
            }

            return (ActionType)Enum.Parse(typeof(ActionType), value, true);            
        }

        private Instance GetInstance(IEnumerable<LinkedService> linkedServices, IDictionary<string, string> extendedProperties)
        {
            // Valiate input
            linkedServices.ThrowIfNull();

            // Get the details on the datastore-sqldw instance
            LinkedService linkedService = linkedServices
                .Where(ls => ls.Name == "datastore-sqldw")
                .First();

            // Get the extended properties for the data store
            var properties = linkedService.Properties.TypeProperties as AzureSqlDataWarehouseLinkedService;

            // Get the connection string
            SqlConnectionStringBuilder scsb = new SqlConnectionStringBuilder(properties.ConnectionString);

            var instance = new Instance();

            // Get the server and database
            instance.Server = scsb.DataSource;
            instance.Database = scsb.InitialCatalog;

            instance.Location = extendedProperties[EXTENDED_PROPERTY_LOCATION];
            instance.ResourceGroup = extendedProperties[EXTENDED_PROPERTY_RESOURCE_GROUP];
            instance.SubscriptionId = new Guid(extendedProperties[EXTENDED_PROPERTY_SUBSCRIPTION_ID]);

            return instance;
        }

        private RestClient GetRequestClient()
        {
            // Initialize a new RestClient
            var client = new RestClient(AZURE_MANAGEMENT_URL);

            // Authenticate the user
            client.Authenticator = new JwtAuthenticator(GetAccessToken());

            // Set a UserAgent
            client.UserAgent = USER_AGENT;

            return client;
        }

        public StateType GetState(Instance instance)
        {
            // Validate the input
            instance.ThrowIfNull();

            // Build out the URL
            var url = BuildUrl(AZURE_DATAWAREHOUSE_STATUS_URL_PART, instance);

            // Execute the call and get the response
            var response = ExecuteRequest(url, Method.GET);

            // Return the state of the instance
            return ParseState(response);
        }

        private void LogDatasets(IEnumerable<Dataset> datasets)
        {
            // Validate input
            datasets.ThrowIfNull();

            Logger.Write("Logging Datasets");
            foreach (Dataset dataset in datasets)
            {
                Logger.Write("\tDataset: {0}", dataset.Name);
            }
        }

        private void LogExtendedProperties(IDictionary<string, string> extendedProperties)
        {
            // Validate the input
            extendedProperties.ThrowIfNull();

            Logger.Write("Logging Extended Properties");

            foreach (KeyValuePair<string, string> entry in extendedProperties)
            {
                Logger.Write("\t{0}: {1}", entry.Key, entry.Value);
            }
        }

        private void LogLinkedServices(IEnumerable<LinkedService> linkedServices)
        {
            // Validate input
            linkedServices.ThrowIfNull();
            Logger.ThrowIfNull();

            Logger.Write("Logging Linked Services");
            foreach (LinkedService linkedService in linkedServices)
            {
                Logger.Write("\tLinked Service: {0}", linkedService.Name);
            }
        }

        private IActivityLogger Logger { get; set; }

        private StateType ParseState(string response)
        {
            // Validate the input
            response.ThrowIfNullOrEmpty();

            // Get the state token
            var responseObject = JObject.Parse(response);

            // Get the state token
            var stateToken = responseObject.SelectToken(STATUS_PROPERTY);

            // Return the StateType
            return (StateType)Enum.Parse(typeof(StateType), stateToken.ToString());
        }

        public void ProcessAction(ActionType actionType, Instance instance)
        {
            // Validate input
            actionType.ThrowIfNull();
            instance.ThrowIfNull();

            // Business Rules
            switch(actionType)
            {
                case ActionType.Pause:
                    Pause(instance);
                    break;
                case ActionType.Resume:
                    Resume(instance);
                    break;

                case ActionType.Scale:
                    Scale(instance);
                    break;
                default:
                    throw new ArgumentException(string.Format("Unknown ActionType: {0}", actionType.ToString()));
            }
        }

        public StateType Pause(Instance instance)
        {
            // Validate the input
            instance.ThrowIfNull();

            // Build out the URL
            var url = BuildUrl(AZURE_DATAWAREHOUSE_PAUSE_URL_PART, instance);

            // Execute the call and get the response
            var response = ExecuteRequest(url, Method.POST);

            return StateType.Pausing;
        }

        public StateType Resume(Instance instance)
        {
            // Validate the input
            instance.ThrowIfNull();

            // Build out the URL
            var url = BuildUrl(AZURE_DATAWAREHOUSE_RESUME_URL_PART, instance);

            // Execute the call and get the response
            var response = ExecuteRequest(url, Method.POST);

            return StateType.Resuming;
        }

        public StateType Scale(Instance instance)
        {
            // Validate the input
            instance.ThrowIfNull();

            // Build out the URL
            var url = BuildUrl(AZURE_DATAWAREHOUSE_SCALE_URL_PART, instance);

            // Execute the call and get the response
            var response = ExecuteRequest(url, Method.POST);

            return StateType.Scaling;
        }
    }
}