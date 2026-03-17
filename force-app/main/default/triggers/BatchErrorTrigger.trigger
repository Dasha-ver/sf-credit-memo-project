trigger BatchErrorTrigger on BatchApexErrorEvent (after insert) {
    List<Error_Log__c> logsToInsert = new List<Error_Log__c>();

    for (BatchApexErrorEvent event : Trigger.new) {
        Error_Log__c log = new Error_Log__c();
        log.Job_Id__c = event.AsyncApexJobId;       
        log.Message__c = event.Message;           
        log.Trace__c = event.StackTrace;          
        
        System.debug('Error was on stage: ' + event.Phase); 
        
        logsToInsert.add(log);
    }

    if (!logsToInsert.isEmpty()) {
        insert logsToInsert;
    }
}