trigger LogEventTrigger on Log_Event__e (after insert) {
    List<Error_Log__c> logs = new List<Error_Log__c>();
    for (Log_Event__e e : Trigger.new) {
        logs.add(new Error_Log__c(
            Message__c = e.Message__c,
            Trace__c = e.Trace__c
        ));
    }
    insert logs;
}