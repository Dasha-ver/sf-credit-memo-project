@IsTest
private class VoucherServiceTest {

    @TestSetup
    static void setupTestData() {

        Account acc = new Account(Name = 'Universal Exports');
        insert acc;

        List<Credit_Memo__c> memosToInsert = new List<Credit_Memo__c>();
        
        memosToInsert.add(new Credit_Memo__c(
            Account__c = acc.Id,
            Amount__c = 500,
            Credit_Expiry_Date__c = Date.today().addDays(30),
            Valid_From__c = Date.today().addDays(-10)

        ));

        memosToInsert.add(new Credit_Memo__c(
            Account__c = acc.Id,
            Amount__c = 1000,
            Credit_Expiry_Date__c = Date.today().addDays(30),
            Valid_From__c = Date.today().addDays(-10),
            Exclusively_For__c = 'James Bond'
        ));

        memosToInsert.add(new Credit_Memo__c(
            Account__c = acc.Id,
            Amount__c = 100,
            Credit_Expiry_Date__c = Date.today().addDays(-50),
            Valid_From__c = Date.today().addDays(-10)
        ));

        insert memosToInsert;

        Voucher_Background__c globalBg = new Voucher_Background__c(
            Expiry_From_Date__c = Date.today().addDays(-10),
            Expiry_To_Date__c = Date.today().addDays(60),
            Is_Active__c = true
        );
        insert globalBg;

        ContentVersion cvGlobal = new ContentVersion(
            Title = 'Global Bg',
            PathOnClient = 'global.jpg',
            VersionData = Blob.valueOf('Global Image Data'),
            IsMajorVersion = true
        );
        ContentVersion cvOverride = new ContentVersion(
            Title = 'Override Bg',
            PathOnClient = 'override.png',
            VersionData = Blob.valueOf('Override Image Data'),
            IsMajorVersion = true
        );
        insert new List<ContentVersion>{cvGlobal, cvOverride};

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id 
            IN (:cvGlobal.Id, :cvOverride.Id)
        ]);

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        linksToInsert.add(new ContentDocumentLink(
            LinkedEntityId = globalBg.Id,
            ContentDocumentId = cvMap.get(cvGlobal.Id).ContentDocumentId,
            ShareType = 'V'
        ));

        linksToInsert.add(new ContentDocumentLink(
            LinkedEntityId = memosToInsert[1].Id,
            ContentDocumentId = cvMap.get(cvOverride.Id).ContentDocumentId,
            ShareType = 'V'
        ));

        insert linksToInsert;
    }

    @IsTest
    static void testGlobalImageAndAccountNameFallback() {
        Credit_Memo__c memo = [
            SELECT Id 
            FROM Credit_Memo__c 
            WHERE Amount__c = 500 
            LIMIT 1];

        Test.startTest();
        VoucherService.VoucherData result = VoucherService.getVoucherDataForPdf(memo.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'VoucherData should not be null');
        Assert.areEqual('Universal Exports', result.exclusivelyForName, 'Should fallback to Account Name if Exclusively For is blank');
        Assert.isNotNull(result.imageUrl, 'Global image URL should be resolved');
        Assert.isTrue(String.isNotBlank(result.currencySymbol), 'Currency symbol should be populated');
    }

    @IsTest
    static void testOverrideImageAndExclusivelyFor() {
        Credit_Memo__c memo = [
            SELECT Id 
            FROM Credit_Memo__c 
            WHERE Amount__c = 1000 
            LIMIT 1];

        Test.startTest();
        VoucherService.VoucherData result = VoucherService.getVoucherDataForPdf(memo.Id);
        Test.stopTest();

        ContentVersion cvOverride = [
            SELECT Id 
            FROM ContentVersion 
            WHERE Title = 'Override Bg' 
            LIMIT 1];

        Assert.areEqual('James Bond', result.exclusivelyForName, 'Exclusively For name should be prioritized');
        Assert.isNotNull(result.imageUrl, 'Override image URL should be resolved');
        Assert.isTrue(result.imageUrl.contains(cvOverride.Id), 'The URL should point to the Override image version ID');
    }

    @IsTest
    static void testNoActiveImageAvailable() {

        Credit_Memo__c memo = [
            SELECT Id 
            FROM Credit_Memo__c 
            WHERE Amount__c = 100 
            LIMIT 1];

        Test.startTest();
        VoucherService.VoucherData result = VoucherService.getVoucherDataForPdf(memo.Id);
        Test.stopTest();

        Assert.isNull(result.imageUrl, 'Image URL should be null if no override and no matching global background exists');
    }

    @IsTest
    static void testLwcPreviewMethod() {
        Credit_Memo__c memo = [
            SELECT Id 
            FROM Credit_Memo__c 
            WHERE Amount__c = 1000 
            LIMIT 1];

        Test.startTest();
        String imageUrl = VoucherService.getPreviewImageUrl(memo.Id);
        Test.stopTest();

        ContentVersion cvOverride = [
            SELECT Id 
            FROM ContentVersion 
            WHERE Title = 'Override Bg' 
            LIMIT 1];
            
        Assert.isNotNull(imageUrl, 'Preview method should successfully return an image URL');
        Assert.isTrue(imageUrl.contains(cvOverride.Id), 'Preview should match the resolved background URL');
    }
}