import { LightningElement, api, wire } from 'lwc';
import getPreviewImageUrl from '@salesforce/apex/VoucherService.getPreviewImageUrl';
import noBackgroundImageFound from '@salesforce/label/c.Voucher_No_Background_Image';
import errorFetchingImage from '@salesforce/label/c.Voucher_Error_Fetching_Image';

export default class VoucherImagePreview extends LightningElement {
    @api recordId;
    imageUrl;

    labels = {
        noBackgroundImageFound
    };

    @wire(getPreviewImageUrl, { creditMemoId: '$recordId' })
    wiredImage({ error, data }) {
        if (data) {
            this.imageUrl = data;
        } else if (error) {
            console.error(`${errorFetchingImage}:`, error);
        }
    }
}