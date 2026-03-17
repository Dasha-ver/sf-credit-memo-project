public with sharing class QueueableMonitoringFinalizer implements System.Finalizer {
    private String className;

    public QueueableMonitoringFinalizer(String className) {
        this.className = className;
    }

    public void execute(System.FinalizerContext ctx) {
        if (ctx.getResult() != ParentJobResult.SUCCESS) {
            Exception ex = ctx.getException();
            Id jobId = ctx.getAsyncApexJobId();
            
            if (ex != null) {
                Logger.error(ex, className, jobId);
            } else {
                Logger.error('Limit/Unhandled Error', 'No Stack Trace', className, jobId);
            }
        }
    }
}