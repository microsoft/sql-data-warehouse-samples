var util = require('./util.js');
var request = require('request');

ScaleDw = function (context, access_token, slo) {
    // Passed context object from caller
    context.log(access_token);
    context.log(slo);
    subscriptionId = GetEnvironmentVariable('SubscriptionId');
    context.log(subscriptionId);
    
    resourceGroup = GetEnvironmentVariable('ResourceGroup');
    context.log(resourceGroup);
    
    serverName = GetEnvironmentVariable('ServerName');
    context.log(serverName);
    
    databaseName = GetEnvironmentVariable('DatabaseName');
    context.log(databaseName);
    

    path = (`https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Sql/servers/${serverName}/databases/${databaseName}?api-version=2014-04-01-preview`);
    context.log(path);
    request.patch({
            url: path,
            json: {
                "properties": {
                    "requestedServiceObjectiveName": slo
                }
            },
            headers: {
                Authorization: 'Bearer ' + access_token,
                'Content-Type': 'application/json'
            }

        },
        function (err, response, body) {
            if (!err && (response.statusCode == 200 || response.statusCode == 201 || response.statusCode==202)) {
                context.log('Accepted scale request')
                context.log(JSON.parse(response.body)) 
                context.done()
            } else {
                context.log('Scale request could not be completed')
                context.log(response.body)
                context.log(err) 
                context.done()
            }
        }
    );

}

module.exports.ScaleDw = ScaleDw