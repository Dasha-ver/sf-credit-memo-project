import { LightningElement } from 'lwc';
import createRiskAccount from '@salesforce/apex/SecureAccountController.createRiskAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoggerDemo extends LightningElement {

    handleSuccess() {
        this.callApex('Good Account');
    }

    handleError() {
        this.callApex('Test Account Error');
    }

    callApex(nameValue) {
        createRiskAccount({ accName: nameValue })
            .then(() => {
                this.showToast('Success', 'Account was created!', 'success');
            })
            .catch((error) => {
                console.error('LWC Error:', error);
            
                let message = 'Unknown error';
                if (error && error.body && error.body.message) {
                    message = error.body.message;
                }

                this.showToast('Error', message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}