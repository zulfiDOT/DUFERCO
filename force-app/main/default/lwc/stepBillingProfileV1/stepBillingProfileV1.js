import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import addBilling from '@salesforce/apex/aggiungiBillingProfileQA_Controller.addBillingProfile';

export default class StepBillingProfileV1 extends LightningElement {

    @api quoteId;
    @api account;
    @api payment;
    @api paymentSelected
    @api address;
    @api addressSelected;
    billingProfile = {};
    isLoading = false;

    @api handleBillingSubmit(){
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
        
        if (isInputsCorrect) {
            this.template.querySelectorAll('lightning-input-field').forEach(each => {
                    this.billingProfile[each.fieldName] = each.value;
                 });
            this.addBillingProfile();
            
        }
    }

    addBillingProfile(){
        this.isLoading = true;
        var params = {};
        params.address = this.addressSelected ? this.addressSelected : this.address;
        params.payment = this.paymentSelected ? this.paymentSelected : this.payment;
        params.billing = this.billingProfile;

        addBilling({billingParams : params, quoteId : this.quoteId})
        .then(result => {
            console.log(result);
            this.notifyUser('Operazione Completata','Billing Profile Aggiunto Con Successo','success');
            this.dispatchEvent(new CustomEvent('successbilling', { detail: {Id : result} }));
        }).catch(error => {
            console.log(error);
            this.notifyUser('Errore', this.errorMapping(error),'error');
        }).finally(() => this.isLoading = false );
    }

    errorMapping(error){        
        var errorMessage = '';
        if(error.body.output){
            if(error.body.output.errors[0]){
                errorMessage = error.body.output.errors[0].message;
            }else if(error.body.output.fieldErrors){
                let fieldError = Object.values(error.body.output.fieldErrors)[0];
                errorMessage = '['+fieldError[0].fieldLabel +'] '+ fieldError[0].message;
            }
        }else if(error.body.pageErrors[0]){
                errorMessage = error.body.pageErrors[0].message;
        }else{
            errorMessage = error.body.message;
        }

        return errorMessage;
    }

    get isPA(){
        return this.account.formaAnagrafica == 'PA';
    }
    get isPerson(){
        return this.account.recordType == 'PersonAccount';
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
      
    }
}