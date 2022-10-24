import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

export default class StepBillingProfile extends LightningElement {


    @api account;
    @api payment;
    @api address;
    @api addressToClone;
    isLoading = false;

    @api handleBillingSubmit(){
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
        
        if (isInputsCorrect) {
            this.isLoading = true;
            if (Object.keys(this.addressToClone).length !== 0 && this.addressToClone.constructor === Object) {
                this.cloneAddressRecord();
            }else{
                this.template.querySelector('lightning-record-edit-form').submit();
            }
        }
    }

    cloneAddressRecord(){

        var fields = this.addressToClone;
        var objRecordInput = {'apiName' : 'Address__c', fields};
        createRecord(objRecordInput).then(response => {
            const inputFields = this.template.querySelectorAll(
                '.billingAddress'
            );
            var addressInput;
            if (inputFields) {
                inputFields.forEach(field => {
                    addressInput = field;
                });
            }
            this.address = response.id;
            addressInput.value = response.id;
            this.template.querySelector('lightning-record-edit-form').submit();
        }).catch(error => {
            this.isLoading = true;
            alert('Error: ' +JSON.stringify(error));
        });
    }

    handleSuccess(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione completata',
                message: 'Billing Profile creato correttamente',
                variant: 'success'
            })
        );
        this.isLoading = true;
        this.dispatchEvent(new CustomEvent('successbilling', { detail: {Id : event.detail.id} }));
    }
    handleError(event){
        console.log('error');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione fallita',
                variant: 'error'
            })
        );
        this.isLoading = false;
        this.dispatchEvent(new CustomEvent('error'));
    }

    get isPA(){
        return this.account.formaAnagrafica == 'PA';
    }
    get isPerson(){
        return this.account.recordType == 'PersonAccount';
    }
}