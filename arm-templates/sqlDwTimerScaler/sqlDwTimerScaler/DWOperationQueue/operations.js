var util = require('./util.js');
var request = require('request');

ScaleDw = function (context, access_token, slo) {
    // Passed context object from caller
    context.log(access_token);
    context.log(slo);

    subscriptionId = GetEnvironmentVariable('SubscriptionId');
    resourceGroup = GetEnvironmentVariable('ResourceGroup');
    serverName = GetEnvironmentVariable('ServerName');
    databaseName = GetEnvironmentVariable('DatabaseName');
    
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

PauseDw = function (context, access_token, slo) {
    // Passed context object from caller
    context.log(access_token);

    subscriptionId = GetEnvironmentVariable('SubscriptionId');
    resourceGroup = GetEnvironmentVariable('ResourceGroup');
    serverName = GetEnvironmentVariable('ServerName');
    databaseName = GetEnvironmentVariable('DatabaseName');
    
    path = (`https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Sql/servers/${serverName}/databases/${databaseName}/pause?api-version=2014-04-01-preview`);
    context.log(path);
    request.post({
            url: path,
            headers: {
                Authorization: 'Bearer ' + access_token,
                'Content-Type': 'application/json'
            }

        },
        function (err, response, body) {
            if (!err && (response.statusCode == 200 || response.statusCode == 201 || response.statusCode==202)) {
                context.log('Accepted pause request')
                context.log(JSON.parse(response.body)) 
                context.done()
            } else {
                context.log('pause request could not be completed')
                context.log(response.body)
                context.log(err) 
                context.done()
            }
        }
    );

}

ResumeDw = function (context, access_token, slo) {
    // Passed context object from caller
    context.log(access_token);

    subscriptionId = GetEnvironmentVariable('SubscriptionId');
    resourceGroup = GetEnvironmentVariable('ResourceGroup');
    serverName = GetEnvironmentVariable('ServerName');
    databaseName = GetEnvironmentVariable('DatabaseName');
    
    path = (`https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Sql/servers/${serverName}/databases/${databaseName}/resume?api-version=2014-04-01-preview`);
    context.log(path);
    request.post({
            url: path,
            headers: {
                Authorization: 'Bearer ' + access_token,
                'Content-Type': 'application/json'
            }

        },
        function (err, response, body) {
            if (!err && (response.statusCode == 200 || response.statusCode == 201 || response.statusCode==202)) {
                context.log('Accepted resume request')
                context.log(JSON.parse(response.body)) 
                context.done()
            } else {
                context.log('Resume request could not be completed')
                context.log(response.body)
                context.log(err) 
                context.done()
            }
        }
    );

}

module.exports.ScaleDw = ScaleDw
module.exports.PauseDw = PauseDw
module.exports.ResumeDw = ResumeDw