import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getPaymentMethod';
import fetchDataAddress from '@salesforce/apex/aggiungiIndirizzoQuickAction_Controller.fetchData';

export default class NewBillingProfileForm extends LightningElement {
    @api accountId;
    @api quoteId;
    @api account = {};
    @track records;
    isNewPayment = false;
    newRecordOptions = [];
    recentlyViewed = [];
    payment;
    @track address;
    customerAddress = {};
    @track recordsAddress = [];
    recordsAddressSize = false;;
    wiredAddressResult;
    isNewAddress=false;
    activetabContent;
    wiredPaymentResults;
    addressToClone;

    tabIndirizzo = 'Indirizzo di Fatturazione';
    tabPaymentMethod = 'Metodo di Pagamento';
    cancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleSuccess(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione completata',
                message: 'Billing Profile creato correttamente',
                variant: 'success'
            })
        );
        this.dispatchEvent(new CustomEvent('successbilling'));
    }

    handleError(event){
        console.log('error');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione fallita',
                variant: 'error'
            })
        );
        this.dispatchEvent(new CustomEvent('error'));
    }

    @wire(fetchData, { quoteId : '$quoteId'})
    wiredPayments(result) {
        this.wiredPaymentResults = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].blng__AccountPaymentMethods__r) {
                this.records = JSON.parse(JSON.stringify(result.data[0].blng__AccountPaymentMethods__r));
            }
            this.customerAddress.street_number = result.data[0].Customer_Address_Numero_Civico__c;
            this.customerAddress.route = result.data[0].Customer_Address_Street__c;
            this.customerAddress.postal_code = result.data[0].Customer_Address_Postal_Code__c;
            this.customerAddress.locality = result.data[0].Customer_Address_City__c;
            this.customerAddress.province = result.data[0].Customer_Address_State__c;
            this.customerAddress.country = result.data[0].Customer_Address_Country__c;

        } else if (result.error) {
            console.error(error);
        }
    }

    @wire(fetchDataAddress, { quoteId : '$quoteId'})
    wiredAddress(result) {
        this.wiredAddressResult = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].Indirizzi__r) {
                this.recordsAddress = JSON.parse(JSON.stringify(result.data[0].Indirizzi__r));
                this.recordsAddressSize = this.recordsAddress.length > 0;
            }

        } else if (result.error) {
            console.error(error);
        }
    }
    handleSelectedItem(event){
        
        this.selectedItem = event.detail.selectedItem;
        if (this.activetabContent == this.tabIndirizzo) {
            this.addressToClone = new Object();
            this.recordsAddress.forEach(item => {
                item.selected = item.Id === this.selectedItem.Id ? true :false;
                if (item.selected && item.Type__c != 'Indirizzo Fatturazione') {
                    this.addressToClone =  Object.assign({}, item);
                    this.addressToClone.Type__c = '4';
                    delete this.addressToClone["Id"];
                    delete this.addressToClone["selected"];
                }
            });
            this.address = this.selectedItem.Id;
        }else{
            this.records.forEach(item => {
                item.selected = item.Id === this.selectedItem.Id ? true :false;
            });
            this.payment = this.selectedItem.Id;
        }
    }

    tabChangeHandler(event) {
 
        this.activetabContent  = event.target.label;
     }

    getNewForm(){
        if (this.activetabContent == this.tabIndirizzo) {
            this.isNewAddress = true;
        }else{
            this.isNewPayment = true;
        }

        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : true} }));
    }

    back(){
        if (this.activetabContent == this.tabIndirizzo) {
            this.isNewAddress = false;
        }else{
            this.isNewPayment = false;
        }
        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false} }));
    }

    backForm(){
        this.dispatchEvent(new CustomEvent('hideform'));
    }

    @api handleBillingSubmit(){
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
        
        if (isInputsCorrect) {
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
            alert('Error: ' +JSON.stringify(error));
        });
    }

    handleSubmitPayment(event){
        event.preventDefault(); 
        this.template.querySelector('c-payment-method-item').handleSubmitPayment();
    }
    handlePaymentSuccess(){
        this.isNewPayment = false;
        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false} }));
        return refreshApex(this.wiredPaymentResults);
    }

    handlePaymentError(){

    }
    handleAddressSubmit(event){
        event.preventDefault(); 
        this.template.querySelector('c-new-address-form').handleAddressSubmit();
    }

    handleAddressSuccess(){
        this.isNewAddress = false;
        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false} }));
        return refreshApex(this.wiredAddressResult);
    }

    handleAddressError(){

    }

    get isPA(){
        return this.account.formaAnagrafica == 'PA';
    }
    get isPerson(){
        return this.account.recordType == 'PersonAccount';
    }
}