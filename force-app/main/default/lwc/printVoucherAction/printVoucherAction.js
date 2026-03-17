import { LightningElement, api } from 'lwc';

export default class PrintVoucherAction extends LightningElement {
    @api recordId;

    @api invoke() {
        const vfUrl = '/apex/VoucherPDF?id=' + this.recordId;
        
        window.open(vfUrl, '_blank');
    }
}