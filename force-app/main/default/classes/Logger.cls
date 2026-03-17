public with sharing class Logger {
    public static void error(Exception e, String context, Id jobId) {
        if (e == null){
             return;
        }
        publish(e.getMessage(), e.getStackTraceString(), context, jobId);
    }

    public static void error(String message, String trace, String context, Id jobId) {
        publish(message, trace, context, jobId);
    }

    private static void publish(String msg, String trace, String ctx, Id jobId) {
        EventBus.publish(new Log_Event__e(
            Message__c = msg,
            Trace__c = trace,
            Context__c = ctx,
            Job_Id__c = jobId
        ));
    }
}