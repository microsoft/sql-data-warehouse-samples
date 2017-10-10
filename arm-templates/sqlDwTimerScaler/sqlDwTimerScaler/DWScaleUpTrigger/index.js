module.exports = function (context, scaleUpTimer) {
    var timeStamp = new Date().toISOString();
    
    if(scaleUpTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }
    context.log('JavaScript timer trigger function ran!', timeStamp);   
    var operation = {
        "operationType": "ScaleDw",
        "ServiceLevelObjective": "DW400"
    }
    context.bindings.operationRequest = operation;
    context.done();
};