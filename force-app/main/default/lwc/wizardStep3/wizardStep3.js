import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class WizardStep3 extends NavigationMixin(LightningElement) {
    @api accountId;

    handlePreavious(event) {

        this.dispatchEvent(new CustomEvent('preavious'));
    }

    handleNext(evt){
        //this.dispatchEvent(new CustomEvent('next'));
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
}