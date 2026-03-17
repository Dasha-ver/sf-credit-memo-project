public with sharing class VoucherPDFController {
    
    public VoucherService.VoucherData pdfData { get; private set; }

    public VoucherPDFController(ApexPages.StandardController stdController) {
        Id recordId = stdController.getId();
        
        if (recordId != null) {
            this.pdfData = VoucherService.getVoucherDataForPdf(recordId);
        } else {
            this.pdfData = new VoucherService.VoucherData();
        }
    }
}