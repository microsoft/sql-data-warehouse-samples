var operations = require('./operations.js');
var util = require('./util.js');
var request = require('request');

module.exports = function (context, operationRequest) {
    context.log('JavaScript queue trigger function processed work item', operationRequest);
    var operation = context.bindings.operationRequest["operationType"]
    var scaleValue = context.bindings.operationRequest["ServiceLevelObjective"];
    
    context.log('Operation request for: '+operation+' with scale value: '+scaleValue);
    // Functions cannot be evaluated by name without using unsafe eval function so a switch
    // statement is used here to choose the appropriate function.
    switch(operation) {
        case "ScaleDw":
            GetAuthToken(context, ScaleDw, scaleValue);
            context.done();
            break;
        case "ResumeDw":
            GetAuthToken(context, ResumeDw, null);
            context.done();
            break;
        case "PauseDw":
            GetAuthToken(context, PauseDw, null);
            context.done();
            break;
        default:
            context.done();
            break;
    }   
};