using System;
using System.Configuration;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.WindowsAzure;

namespace SqlDwAutoScaler.Shared
{
    public class DwClientFactory
    {
        public static string ActiveDirectoryEndpoint { get; set; } = "https://login.windows.net/";
        public static string ResourceManagerEndpoint { get; set; } = "https://management.azure.com/";
        public static string WindowsManagementUri { get; set; } = "https://management.core.windows.net/";

        // Leave the following Ids and keys unassigned so that they won't be checked in Git. They are assigned in Azure portal.
        public static string SubscriptionId { get; set; } = ConfigurationManager.AppSettings["SubscriptionId"];
        public static string TenantId { get; set; } = ConfigurationManager.AppSettings["TenantId"];
        public static string ClientId { get; set; } = ConfigurationManager.AppSettings["ClientId"];
        public static string ClientKey { get; set; } = ConfigurationManager.AppSettings["ClientKey"];

        public static DwManagementClient Create(string resourceId)
        {
            var authenticationContext = new AuthenticationContext(ActiveDirectoryEndpoint + TenantId);
            var credential = new ClientCredential(clientId: ClientId, clientSecret: ClientKey);
            var result = authenticationContext.AcquireTokenAsync(resource: WindowsManagementUri, clientCredential: credential).Result;

            if (result == null) throw new InvalidOperationException("Failed to obtain the token!");

            var token = result.AccessToken;

            var aadTokenCredentials = new TokenCloudCredentials(SubscriptionId, token);

            var client = new DwManagementClient(aadTokenCredentials, resourceId);
            return client;
        }

    }
}