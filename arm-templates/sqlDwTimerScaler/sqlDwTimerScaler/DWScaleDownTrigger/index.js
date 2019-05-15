module.exports = function (context, scaleDownTimer) {
    var timeStamp = new Date().toISOString();
    
    if(scaleDownTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }
    context.log('JavaScript timer trigger function ran!', timeStamp);   
    var operation = {
        "operationType": "ScaleDw",
        "ServiceLevelObjective": "DW100"
    }
    context.bindings.operationRequest = operation;
    context.done();
};