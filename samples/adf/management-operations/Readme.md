# Management Operations

This sample demonstrates a custom .NET activity that can be used in an [Azure Data Factory](https://azure.microsoft.com/services/data-factory) pipeline. The 
sample allows setting the action by using extended properties within the pipeline activity.

```"ActionType": "Pause|Resume|Scale",
	"AdfClientId": "",
	"AdfClientSecret":  "",
	"Location": "<Location e.g., West US, Central US>",
	"ResourceGroup": "<Resource Group Name>",
	"SubscriptionId": "00000000-0000-0000-0000-000000000000",
	"ServiceObjective": "DW1000"
```

For example, you could create a pipeline that scales your database to a higher DWU setting, run a data load and transformation, then scales 
your instance back down. You could also Resume, execute your workload, and then pause your instance. 