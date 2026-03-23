@IsTest
private class CreditMemoExtensionTest {

    @TestSetup
    static void setupTestData() {
        Voucher_Setting__c testSetting = new Voucher_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Default_Notes__c = 'Please issue refund for {0} as requested.'
        );
        insert testSetting;
        
        Account acc = new Account(Name = 'Test Account for Aura Memo');
        insert acc;
    }

    @IsTest
    static void testClassicControllerInitAndCancel() {
        Credit_Memo__c emptyMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(emptyMemo);
        
        Test.startTest();
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        PageReference cancelRef = extension.cancel();
        Test.stopTest();
        
        String expectedNotes = 'Please issue refund for  as requested.';
        Assert.areEqual(expectedNotes, extension.memo.Notes__c, 'Constructor should clean the {0} placeholder in Notes__c');
        
        String expectedPrefix = Credit_Memo__c.sObjectType.getDescribe().getKeyPrefix();
        Assert.isTrue(cancelRef.getUrl().contains('/' + expectedPrefix + '/o'), 'Cancel should redirect to the Credit Memo list page');
    }

    @IsTest
    static void testSaveSuccess() {
        Account acc = [
            SELECT Id 
            FROM Account 
            LIMIT 1];
        Credit_Memo__c emptyMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(emptyMemo);
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        
        extension.memo.Account__c = acc.Id;
        extension.memo.Amount__c = 250;
        extension.memo.Valid_From__c = Date.today();
        extension.memo.Credit_Expiry_Date__c = Date.today().addDays(30);
        
        Test.startTest();
        PageReference saveRef = extension.save();
        Test.stopTest();
        
        Assert.isNotNull(extension.memo.Id, 'Record should be saved and have an Id');
        Assert.isNotNull(saveRef, 'PageReference should not be null');
        
        String fifteenCharId = String.valueOf(extension.memo.Id).substring(0, 15);
        Assert.isTrue(saveRef.getUrl().contains(fifteenCharId), 'Should redirect to the detail page of the created record');
    }

    @IsTest
    static void testSaveWithValidationErrors() {
        Credit_Memo__c emptyMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(emptyMemo);
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        
        Test.startTest();
        PageReference saveRef = extension.save();
        Test.stopTest();
        
        Assert.isNull(saveRef, 'Save should return null when validation fails');
        Assert.isNull(extension.memo.Id, 'Record should NOT be saved');
        Assert.isTrue(ApexPages.hasMessages(), 'Messages should be added to the page when validation fails');
    }

    @IsTest
    static void testAuraMethodSuccess() {
        Test.startTest();
        String auraNote = CreditMemoExtension.getDefaultNoteForLightning();
        Test.stopTest();
        
        String expectedNotes = 'Please issue refund for  as requested.';
        Assert.areEqual(expectedNotes, auraNote, 'Aura method should return the cleaned string without the {0} placeholder');
    }

    @IsTest
    static void testWithoutCustomSettings() {
        delete [
            SELECT Id 
            FROM Voucher_Setting__c];
        
        Credit_Memo__c emptyMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(emptyMemo);
        
        Test.startTest();
        CreditMemoExtension extension = new CreditMemoExtension(stdController);
        String auraNote = CreditMemoExtension.getDefaultNoteForLightning();
        Test.stopTest();
        
        Assert.isNull(extension.memo.Notes__c, 'If no custom settings exist, the Notes__c field should be null in Classic');
        Assert.areEqual('', auraNote, 'If no custom settings exist, the Aura method should return an empty string');
    }
}