public class CreditMemoExtension {
    public Credit_Memo__c memo { get; set; }

    public CreditMemoExtension(ApexPages.StandardController stdController) {
        this.memo = new Credit_Memo__c(); 
        setupNotes();
    }

    private void setupNotes() {
        Voucher_Setting__c settings = Voucher_Setting__c.getInstance();
        if (settings != null && settings.Default_Notes__c != null) {
            this.memo.Notes__c = settings.Default_Notes__c.replace('{0}', '');
        }
    }

    public PageReference save() {
        try {
            insert this.memo; 
            PageReference pageRef = new ApexPages.StandardController(this.memo).view();
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception e) {
            ApexPages.addMessages(e); 
            return null;
        }
    }

    public PageReference cancel() {
        return new PageReference('/' + Credit_Memo__c.sObjectType.getDescribe().getKeyPrefix() + '/o');
    }

    @AuraEnabled
    public static String getDefaultNoteForLightning() {
        Voucher_Setting__c settings = Voucher_Setting__c.getInstance();
        if (settings != null && settings.Default_Notes__c != null) {
            return settings.Default_Notes__c.replace('{0}', '');
        }
        return '';
    }
}