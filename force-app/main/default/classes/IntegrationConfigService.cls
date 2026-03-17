public inherited sharing class IntegrationConfigService {
    
    private static IntegrationConfigService instance;
    private Integration_Setting__mdt settings;

    private IntegrationConfigService() {
        List<Integration_Setting__mdt> configs = [
            SELECT Endpoint__c, ApiKey__c, Timeout__c 
            FROM Integration_Setting__mdt 
            WHERE DeveloperName = 'Default_Config'
            LIMIT 1
        ];

        if (!configs.isEmpty()) {
            this.settings = configs[0];
        } else {
            System.debug(LoggingLevel.ERROR, 'CRITICAL: Integration Metadata "Default_Config" is missing!');
            this.settings = new Integration_Setting__mdt(); 
        }
    }

    public static IntegrationConfigService getInstance() {
        if (instance == null) {
            instance = new IntegrationConfigService();
        }
        return instance;
    }

    public Integration_Setting__mdt getSettings() {
        return this.settings;
    }
}