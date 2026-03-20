@IsTest
private class CreditMemoExtensionTest {

    @TestSetup
    static void setupTestData() {
        Voucher_Setting__c testSetting = new Voucher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Default_Notes__c = 'Please refund the amount for {0} immediately.'
        );
        insert testSetting;
        
        Account acc = new Account(Name = 'Test Account for Memo');
        insert acc;
    }

    @IsTest
    static void testStandardControllerSaveAndCancel() {
        Account acc = [
            SELECT Id 
            FROM Account 
            LIMIT 1];
        Credit_Memo__c newMemo = new Credit_Memo__c();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newMemo);
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        
        String expectedNotes = 'Please refund the amount for  immediately.';
        Assert.areEqual(expectedNotes, extension.memo.Notes__c, 'Notes should be cleaned');
        
        extension.memo.Account__c = acc.Id;
        extension.memo.Amount__c = 100;
        extension.memo.Valid_From__c = Date.today();
        extension.memo.Credit_Expiry_Date__c = Date.today().addDays(30);
        
        Test.startTest();
        PageReference saveRef = extension.save();
        PageReference cancelRef = extension.cancel();
        Test.stopTest();
        
        Assert.isNotNull(extension.memo.Id, 'Record should be inserted into the database');
        Assert.isNotNull(saveRef, 'Save method should return a PageReference to the new record');
    }

    @IsTest
    static void testStandardSetControllerSaveAndCancel() {
        Account acc = [
            SELECT Id 
            FROM Account 
            LIMIT 1];
        List<Credit_Memo__c> emptyList = new List<Credit_Memo__c>();
        
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
        CreditMemoExtension extension = new CreditMemoExtension(setController);
        
        extension.memo.Account__c = acc.Id;
        extension.memo.Amount__c = 500;
        extension.memo.Valid_From__c = Date.today();
        extension.memo.Credit_Expiry_Date__c = Date.today().addDays(15);
        
        Test.startTest();
        PageReference saveRef = extension.save();
        PageReference cancelRef = extension.cancel();
        Test.stopTest();
        
        Assert.isNotNull(extension.memo.Id, 'Record should be inserted via SetController logic');
        Assert.isNotNull(saveRef, 'Should redirect to the new record');
    }
    
    @IsTest
    static void testSaveWithError() {
        Credit_Memo__c newMemo = new Credit_Memo__c(); 
        ApexPages.StandardController stdController = new ApexPages.StandardController(newMemo);
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
    
        Test.startTest();
        PageReference saveRef = extension.save();
        Test.stopTest();
        
        Assert.isNull(saveRef, 'Save should return null if validation fails');
        Assert.isNull(extension.memo.Id, 'Record should NOT be inserted');
        Assert.isTrue(ApexPages.hasMessages(), 'The page should display error messages');
    }
    
    @IsTest
    static void testWithoutCustomSetting() {
        delete [
            SELECT Id
            FROM Voucher_Setting__c];
        
        Credit_Memo__c newMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(newMemo);

        Test.startTest();
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        Test.stopTest();

        Assert.areEqual('', extension.notesForLightning, 'Lightning notes should be empty');
        Assert.isNull(extension.memo.Notes__c, 'Memo notes should be null');
    }
}