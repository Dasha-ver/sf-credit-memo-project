public with sharing class SecureAccountController {

    @AuraEnabled
    public static void createRiskAccount(String accName) {
        try {
            
            Account a = new Account(Name = accName);
            
            if (accName.contains('Error')) {
                throw new DmlException('Incorrect word in name!');
            }
            
            if (accName.contains('Zero')) {
                Integer crash = 1 / 0;
            }

            insert a;
            
        } catch (Exception e) {
            Logger.error(e, 'SecureAccountController.createRiskAccount', null);
            
            AuraHandledException uiError = new AuraHandledException('Operation failed.');
            
            uiError.setMessage('Operation rejected by security system. Error ID saved.');
            
            throw uiError;
        }
    }
}