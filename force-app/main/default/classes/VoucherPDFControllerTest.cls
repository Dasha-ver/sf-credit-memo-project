@IsTest
private class VoucherPDFControllerTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Credit_Memo__c memo = new Credit_Memo__c(
            Account__c = acc.Id,
            Amount__c = 500,
            Credit_Expiry_Date__c = Date.today().addDays(30),
            Valid_From__c = Date.today().addDays(-10)
        );
        insert memo;
    }

    @IsTest
    static void testControllerWithValidRecordId() {
        Credit_Memo__c memo = [
            SELECT Amount__c 
            FROM Credit_Memo__c 
            LIMIT 1];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(memo);

        Test.startTest();
        VoucherPDFController controller = new VoucherPDFController(stdController);
        Test.stopTest();

        Assert.isNotNull(controller.pdfData, 'pdfData object should be initialized');
        Assert.isNotNull(controller.pdfData.record, 'VoucherService should have populated the record field');
        Assert.areEqual(500, controller.pdfData.record.Amount__c, 'Amount should match the queried record');
    }

    @IsTest
    static void testControllerWithNullRecordId() {
        Credit_Memo__c uninsertedMemo = new Credit_Memo__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(uninsertedMemo);

        Test.startTest();
        VoucherPDFController controller = new VoucherPDFController(stdController);
        Test.stopTest();

        Assert.isNotNull(controller.pdfData, 'pdfData object should be initialized even if ID is null');
        Assert.isNull(controller.pdfData.record, 'Record should be null inside pdfData because VoucherService was not called');
    }
}