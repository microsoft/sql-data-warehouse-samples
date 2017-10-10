module.exports = function (context, pauseTimer) {
    var timeStamp = new Date().toISOString();
    
    if(pauseTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }
    context.log('JavaScript timer trigger function ran!', timeStamp);   
    var operation = {
        "operationType": "PauseDw"
    }
    context.bindings.operationRequest = operation;
    context.done();
};