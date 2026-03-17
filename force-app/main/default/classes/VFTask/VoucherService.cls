public with sharing class VoucherService {

    public class VoucherData {
        public Credit_Memo__c record { get; set; }
        public String imageUrl { get; set; } 
        public String currencySymbol { get; set; }
        public String exclusivelyForName { get; set; }
    }

    public static VoucherData getVoucherDataForPdf(Id creditMemoId) {
        VoucherData result = new VoucherData();

        result.record = [
            SELECT Name, Amount__c, Valid_From__c, Credit_Expiry_Date__c,
                   Notes__c, Account__r.Name, Exclusively_For__c, CurrencyIsoCode
            FROM Credit_Memo__c
            WHERE Id = :creditMemoId
            WITH USER_MODE
            LIMIT 1
        ];

        result.exclusivelyForName = String.isNotBlank(result.record.Exclusively_For__c) 
            ? result.record.Exclusively_For__c 
            : result.record.Account__r.Name;

        result.currencySymbol = getCurrencySymbol(result.record.CurrencyIsoCode);

        result.imageUrl = getVoucherImageUrl(result.record);

        return result;
    }

    private static String getCurrencySymbol(String isoCode) {
        if (String.isBlank(isoCode)){
            return '$'; 
        }

        switch on isoCode {
            when 'USD' { 
                return '$'; 
            }
            when 'EUR' {
                return '€'; 
            }
            when 'RUB' {
                return '₽'; 
            }
            when else { 
                return isoCode; 
            } 
        }
    }

    private static String getVoucherImageUrl(Credit_Memo__c memo) {
        Id targetEntityId = memo.Id; 

        List<ContentDocumentLink> memoLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :targetEntityId
            WITH USER_MODE
            LIMIT 1
        ];

        if (memoLinks.isEmpty()) {
            List<Voucher_Background__c> globalBgs = [
                SELECT Id 
                FROM Voucher_Background__c 
                WHERE Expiry_From_Date__c <= :memo.Credit_Expiry_Date__c 
                  AND Expiry_To_Date__c >= :memo.Credit_Expiry_Date__c
                  AND Is_Active__c = true
                WITH USER_MODE
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!globalBgs.isEmpty()) {
                targetEntityId = globalBgs[0].Id; 
            } else {
                return null; 
            }
        }

        List<ContentDocumentLink> finalLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :targetEntityId
            WITH USER_MODE
        ];

        if (finalLinks.isEmpty()){
         return null;
        }

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : finalLinks) {
            docIds.add(link.ContentDocumentId);
        }

        List<ContentVersion> versions = [
            SELECT Id 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :docIds 
              AND FileType IN ('JPG', 'JPEG', 'PNG')
              AND IsLatest = true
            WITH USER_MODE
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        if (!versions.isEmpty()) {
            return '/sfc/servlet.shepherd/version/download/' + versions[0].Id;
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getPreviewImageUrl(Id creditMemoId) {
        Credit_Memo__c memo = [
            SELECT Credit_Expiry_Date__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemoId 
            WITH USER_MODE 
            LIMIT 1
        ];
        
        return getVoucherImageUrl(memo);
    }
}