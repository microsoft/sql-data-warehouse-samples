var operations = require('./operations.js');
var util = require('./util.js');
var request = require('request');

module.exports = function (context, operationRequest) {
    context.log('JavaScript queue trigger function processed work item', operationRequest);
    
    context.log('Scale Request for: ', context.bindings.operationRequest["ServiceLevelObjective"]);
    var scaleValue = context.bindings.operationRequest["ServiceLevelObjective"];
    GetAuthToken(context, ScaleDw, scaleValue);
    context.done();
};