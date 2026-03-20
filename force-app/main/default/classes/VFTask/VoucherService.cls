public with sharing class VoucherService {

    public class VoucherData {
        public Credit_Memo__c record { get; set; }
        public String imageUrl { get; set; } 
        public String currencySymbol { get; set; }
        public String exclusivelyForName { get; set; }
    }

    public static List<VoucherData> getVouchersDataForPdf(List<Id> creditMemoIds) {
        List<VoucherData> results = new List<VoucherData>();
        
        if (creditMemoIds == null || creditMemoIds.isEmpty()) {
            return results;
        }

        List<Credit_Memo__c> memos = [
            SELECT Name, Amount__c, Valid_From__c, Credit_Expiry_Date__c,
                   Notes__c, Account__r.Name, Exclusively_For__c, CurrencyIsoCode
            FROM Credit_Memo__c
            WHERE Id IN :creditMemoIds
            WITH USER_MODE
        ];

        Map<Id, String> memoImages = getVoucherImageUrls(memos);

        for (Credit_Memo__c memo : memos) {
            VoucherData data = new VoucherData();
            data.record = memo;
            data.exclusivelyForName = String.isNotBlank(memo.Exclusively_For__c) 
                ? memo.Exclusively_For__c 
                : memo.Account__r.Name;
            data.currencySymbol = getCurrencySymbol(memo.CurrencyIsoCode);
            data.imageUrl = memoImages.get(memo.Id);
            
            results.add(data);
        }

        return results;
    }

    public static VoucherData getVoucherDataForPdf(Id creditMemoId) {
        List<VoucherData> bulkResult = getVouchersDataForPdf(new List<Id>{ creditMemoId });
        return bulkResult.isEmpty() ? new VoucherData() : bulkResult[0];
    }

    private static String getCurrencySymbol(String isoCode) {
        if (String.isBlank(isoCode)){ return '$'; }
        switch on isoCode {
            when 'USD' { return '$'; }
            when 'EUR' { return '€'; }
            when 'RUB' { return '₽'; }
            when else { return isoCode; } 
        }
    }

    private static Map<Id, String> getVoucherImageUrls(List<Credit_Memo__c> memos) {
        Map<Id, String> resultUrls = new Map<Id, String>();
        if (memos.isEmpty()){
            return resultUrls;
        }

        Set<Id> memoIds = new Set<Id>();
        for (Credit_Memo__c m : memos) {
            memoIds.add(m.Id);
        }

        Map<Id, Id> entityToDocIdMap = new Map<Id, Id>();
        for (ContentDocumentLink link : [
            SELECT LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :memoIds 
            WITH USER_MODE
        ]) {
            if (!entityToDocIdMap.containsKey(link.LinkedEntityId)) {
                entityToDocIdMap.put(link.LinkedEntityId, link.ContentDocumentId);
            }
        }

        Set<Id> neededBackgroundIds = new Set<Id>();
        Map<Id, Id> memoToBackgroundIdMap = new Map<Id, Id>();
        List<Credit_Memo__c> memosNeedingBackground = new List<Credit_Memo__c>();

        for (Credit_Memo__c m : memos) {
            if (!entityToDocIdMap.containsKey(m.Id)) {
                memosNeedingBackground.add(m);
            }
        }

        if (!memosNeedingBackground.isEmpty()) {
            List<Voucher_Background__c> activeBgs = [
                SELECT Expiry_From_Date__c, Expiry_To_Date__c 
                FROM Voucher_Background__c 
                WHERE Is_Active__c = true 
                WITH USER_MODE 
                ORDER BY CreatedDate DESC
            ];

            for (Credit_Memo__c m : memosNeedingBackground) {
                for (Voucher_Background__c bg : activeBgs) {
                    if (bg.Expiry_From_Date__c <= m.Credit_Expiry_Date__c && bg.Expiry_To_Date__c >= m.Credit_Expiry_Date__c) {
                        memoToBackgroundIdMap.put(m.Id, bg.Id);
                        neededBackgroundIds.add(bg.Id);
                        break; 
                    }
                }
            }
        }

        if (!neededBackgroundIds.isEmpty()) {
            for (ContentDocumentLink link : [
                SELECT LinkedEntityId, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :neededBackgroundIds 
                WITH USER_MODE
            ]) {
                if (!entityToDocIdMap.containsKey(link.LinkedEntityId)) {
                    entityToDocIdMap.put(link.LinkedEntityId, link.ContentDocumentId);
                }
            }
        }

        Map<Id, String> docIdToUrlMap = new Map<Id, String>();
        if (!entityToDocIdMap.isEmpty()) {
            for (ContentVersion cv : [
                SELECT ContentDocumentId
                FROM ContentVersion 
                WHERE ContentDocumentId IN :entityToDocIdMap.values() 
                  AND FileType IN ('JPG', 'JPEG', 'PNG') 
                  AND IsLatest = true 
                WITH USER_MODE 
                ORDER BY CreatedDate DESC
            ]) {
                if (!docIdToUrlMap.containsKey(cv.ContentDocumentId)) {
                    docIdToUrlMap.put(cv.ContentDocumentId, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                }
            }
        }

        for (Credit_Memo__c m : memos) {
            String finalUrl = null;
            if (entityToDocIdMap.containsKey(m.Id)) {
                Id docId = entityToDocIdMap.get(m.Id);
                finalUrl = docIdToUrlMap.get(docId);
            } else if (memoToBackgroundIdMap.containsKey(m.Id)) {
                Id bgId = memoToBackgroundIdMap.get(m.Id);
                if (entityToDocIdMap.containsKey(bgId)) {
                    Id docId = entityToDocIdMap.get(bgId);
                    finalUrl = docIdToUrlMap.get(docId);
                }
            }
            resultUrls.put(m.Id, finalUrl);
        }

        return resultUrls;
    }

    @AuraEnabled(cacheable=true)
    public static String getPreviewImageUrl(Id creditMemoId) {
        List<Credit_Memo__c> memos = [
            SELECT Credit_Expiry_Date__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemoId 
            WITH USER_MODE 
            LIMIT 1
        ];
        
        if (memos.isEmpty()){
            return null;
        }
        
        Map<Id, String> imageMap = getVoucherImageUrls(memos);
        return imageMap.get(creditMemoId);
    }
}