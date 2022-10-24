import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentMethodItem extends LightningElement {
    @api item;
    @api isNew;
    @api account={};
    match = false;
    isSdd = false;
    isBonifico = false;
    isCard = false;
    italy = true;
    paymentType = '';
    @api address = {"street_number":"",
                "route":"",
                "postal_code":"",
                "locality":"",
                "province":"",
                "country":""}

    handleClick(){
        this.dispatchEvent(new CustomEvent('selected',{detail : {selectedItem : this.item}}));
    }
    handleSuccess(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione completata',
                message: 'Metodo di Pagamento creato correttamente',
                variant: 'success'
            })
        );
        
        this.dispatchEvent(new CustomEvent('successpayment', {detail : event.detail.id}));
    }
    handleError(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione fallita',
                variant: 'error'
            })
        );
        this.dispatchEvent(new CustomEvent('errorpayment'));
    }

    get options() {
        return [
            { label: 'SDD', value: '1', checked : true},
            { label: 'Bonifico', value: '2', checked : false},
        ];
    }
    
    handlePaymentType(event){

        this.paymentType = event.target.value;
        this.isSdd = event.target.value == '1' ? true :false;
        this.isBonifico = event.target.value == '2' ? true :false;
        this.isCard = event.target.value != '1' && event.target.value != '2' ? true :false;
        this.match = false;
    }

    handleMatch(event){
        this.match = !event.target.value;
    }

    handleCountry(event){
        this.italy = event.target.value == 'Italy';
    }
    get isPersonaFisica(){
        return this.account.recordType == 'PersonAccount';
    }
    get isPersonaFisicaClass(){
        return this.account.recordType == 'PersonAccount' ? 'slds-grid slds-size_1-of-1' : 'slds-grid slds-size_1-of-2';
    }

    handleAddressSelection(event){
        this.address = event.detail.address;
    }

    @api handleSubmitPayment(){
        //this.template.querySelector('lightning-record-edit-form').submit();
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);

        if (isInputsCorrect) {
            this.template.querySelector('lightning-record-edit-form').submit();
        }
    }

    @api handleMockSubmit(){

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
            
        var temp = {};
        this.template.querySelectorAll('lightning-input-field').forEach(each => {
               temp[each.fieldName] = each.value;
            });

        this.dispatchEvent(new CustomEvent('setform', {detail : temp}));
    }

    get viewSdd(){
        return this.item.blng__PaymentType__c  == 'SDD';
    }

    get viewCard(){
        return this.item.blng__PaymentType__c  != 'SDD' && this.item.blng__PaymentType__c  != 'Bonifico';
    }



}