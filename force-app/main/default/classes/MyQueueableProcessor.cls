public with sharing class MyQueueableProcessor implements Queueable {
    
    public void execute(QueueableContext context) {
            System.attachFinalizer(new QueueableMonitoringFinalizer('FailingQueueable'));
            
            Integer crash = 1 / 0; 
    }
}