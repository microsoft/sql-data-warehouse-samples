var operations = require('./operations.js');
var util = require('./util.js');
var request = require('request');

module.exports = function (context, operationRequest) {
    context.log('JavaScript queue trigger function processed work item', operationRequest);
    var operation = context.bindings.operationRequest["operationType"]
    var scaleValue = context.bindings.operationRequest["ServiceLevelObjective"];
    
    context.log('Operation request for: '+operation+' with scale value: '+scaleValue);
    GetAuthToken(context, operation, scaleValue);
    context.done();
};