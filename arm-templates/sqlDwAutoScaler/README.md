
# SQL Data Warehouse Automatic Scaling Template

This code was developed by the Microsoft Education Data Services team under [Eldad Hagashi](https://www.linkedin.com/in/eldad-hagashi/) and [Feng Tan](https://www.linkedin.com/in/feng-tan-0b1311154/) and was given to the team to host publicly. 

## Table of Contents

- [Installation](https://github.com/fraction/readme-boilerplate#installation)
- [Usage](https://github.com/fraction/readme-boilerplate#usage)
- [Support](https://github.com/fraction/readme-boilerplate#support)
- [Contributing](https://github.com/fraction/readme-boilerplate#contributing)

## Installation

This package of Azure functions can be implemented either through the template listed above or via deployment. In both cases, you will need the following information:

- Name of the resource group your SQL DW instance is in
- Name of the logical server your SQL DW instance is in
- Name of your SQL DW instance
- Tenant ID (Directory ID) of your Azure Active Directory
- Subscription ID
- [Service Principal Application ID](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-integrating-applications#adding-an-application)
- Service Principal Secret Key

Information on how to get some of this information is listed in the manual steps.

#### Template

In order to deploy through a template, click on the following deploy template button and follow the steps provided. If the link does not work, copy the URL and paste it manually in your browser.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoft%2Fsql-data-warehouse-samples%2Fmaster%2Farm-templates%2FsqlDwAutoScaler%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

#### Manual

If you choose to deploy the solution manually, download this repository and open up the corresponding Visual Studio solution. 

1. Create an Azure Function App Service in the Azure portal. During this stage, we advise choosing a Consumption plan for pricing. This has a limitation of 5 minutes for runtime, but the Autoscaler will complete under this time frame. The template uses the Consumption plan by default. You should create a storage account with App Service.
2. [Create an Azure Active Directory App](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal) (Service Principal). You'll want to ensure you retrieve your Service Principal Application (SPA) Id and Secret Key during this step. Assign the SPA to your resource groups where your SQL Data Warehouse is located with at least contributor privilege.
3. Get the Directory ID of your Azure Active Directory Tenant located in the porta.azure.com > Azure Active Directory > Properties.
4. Edit the dwuconfigs.json file. This file determines the level and order of scaling up/down. You can remove/add dwu config string in the file to skip/add some scaling levels. “**DefaultDwu**” is used by **ScaleSqlDwByTimer** function to scale SQL DW to a default level at certain time if current level is lower than default level. This file is unchanged by default in the template. 
5. Deploy to your Azure function app. Follow the instructions [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs#publish-to-azure) to publish the code package to your Azure account. You may have to install certain NuGet packages to publish Azure functions.
6. Add appropriate application settings for the function app in the portal. Azure functions does not use the local.settings.json or appsettings.json file. You must manually set up function application settings through the portal.

   - Navigate to the Azure function app in the portal > Platform features > General Settings > Application Settings
   - Fill in correct details
     - IsEncrypted": false
     - AzureWebJobsDashboard": ""
     - AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=<YourFunctionAppStorageAccount>;AccountKey=<YourAccountKey>;"
     - SqlDwLocation: "<SQL DW Location>
     - DwuConfigFile: "D:\\home\\site\\wwwroot\\dwuconfigs.json"
     - DwScaleLogsTable: "DwScaleLogs"
     - ScaleUpScheduleStartTime: "<form of hh:mm:ss>"
     - ScaleUpScheduleEndTime: "<form of hh:mm:ss>"
     - SubscriptionId: "<Your subscription id>"
     - TenantId: "<Your tenant id>"
     - ClientId: "<Your Azure Active Directory App Id>"
     - ClientKey: "<Your Azure Active Directory App Key>"
     - WEBSITE_TIME_ZONE: ""
7. Get function URL. Click on the **ScaleSqlDw** function from the list of functions in the left side *Functions* panel. Click on **Get  function URL** from the top right panel area and copy the URL. 
8. Create two Azure alerts in the SQL DW DWU [usage monitoring page](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-insights-alerts-portal). Create one alert for scale down action, the other for scale up action. **Make sure alert names contains key words "Scale Down" or "Scale Up".** The function relies on the two keywords to perform scale down or scale up. When you edit rule, paste the **function URL** you copied from previous step to "**Webhook**" text box.




## Contributing

Please feel free to support this sample or others by opening a pull request.