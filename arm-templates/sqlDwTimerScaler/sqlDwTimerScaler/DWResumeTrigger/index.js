module.exports = function (context, resumeTimer) {
    var timeStamp = new Date().toISOString();
    
    if(resumeTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }
    context.log('JavaScript timer trigger function ran!', timeStamp);   
    var operation = {
        "operationType": "ResumeDw"
    }
    context.bindings.operationRequest = operation;
    context.done();
};