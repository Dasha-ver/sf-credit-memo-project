public class CreditMemoExtension {
    public Credit_Memo__c memo { get; set; }
    public String notesForLightning { get; set; }
    
    private ApexPages.StandardSetController setCtrl;
    private ApexPages.StandardController stdCtrl;

    public CreditMemoExtension(ApexPages.StandardController stdController) {
        this.stdCtrl = stdController;
        this.memo = (Credit_Memo__c)stdController.getRecord();
        setupNotes();
    }

    public CreditMemoExtension(ApexPages.StandardSetController setController) {
        this.setCtrl = setController;
        this.memo = new Credit_Memo__c(); 
        setupNotes();
    }

    private void setupNotes() {
        Voucher_Setting__c settings = Voucher_Setting__c.getInstance();
        if (settings != null && settings.Default_Notes__c != null) {
            String cleanNotes = settings.Default_Notes__c.replace('{0}', '');
            this.memo.Notes__c = cleanNotes;
            this.notesForLightning = cleanNotes;
        } else {
            this.notesForLightning = '';
        }
    }

    public PageReference save() {
        try {
            upsert this.memo; 
            
            PageReference pageRef = new ApexPages.StandardController(this.memo).view();
            pageRef.setRedirect(true);
            return pageRef;
            
        } catch (Exception e) {
            ApexPages.addMessages(e); 
            return null;
        }
    }

    public PageReference cancel() {
        if (setCtrl != null) {
            return setCtrl.cancel();
        } else {
            return stdCtrl.cancel();
        }
    }
}