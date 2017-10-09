var request = require('request');

// Returns environment variables which can be found and set in each Function's 
// application settings
GetEnvironmentVariable = function(name) {
    return process.env[name]
};

// Returns an error or an auth_token from the response body to be used by 
// REST api functions
GetAuthToken = function(context, callback, callbackArgs){
    context.log("Retrieving authorization token for REST command")
    tenantId = GetEnvironmentVariable('TenantId');
    path = (`https://login.microsoftonline.com/${tenantId}/oauth2/token`)
    request.post(
        {
            url: path,
            form: {
                grant_type: "client_credentials",
                client_id: GetEnvironmentVariable('ClientId'),
                client_secret: GetEnvironmentVariable('ClientKey'),
                resource: "https://management.azure.com/"
                }
        },
        function(err,response,body){ 
            if (!err && response.statusCode == 200) {
                context.log("Request for authorization token succeeded")
                callback(context, JSON.parse(body)['access_token'], callbackArgs)
            }else {
                context.log("Request for authorization token failed")
                context.log("Error: ", err)
                context.log("Response: ", response)
                context.done()
                }
            }
        );
};

module.exports.GetEnvironmentVariable = GetEnvironmentVariable;
module.exports.GetAuthToken = GetAuthToken;
