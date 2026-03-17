public with sharing class CrashTestBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM User LIMIT 100');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        for(Integer i = 0; i < 300; i++) {
            List<Account> accs = [
                SELECT Id 
                FROM Account 
                LIMIT 1];
        }
        
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch finished');
    }
}