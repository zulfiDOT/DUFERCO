import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getPaymentMethod';

export default class StepPaymentMethodV1 extends LightningElement {

    @api quoteId;
    @api account;
    @track paymentRecords;
    @api payment = {};
    wiredPaymentResults;
    customerAddress = {};
    @track columns = [{ label: 'Tipo di Pagamento', fieldName: 'blng__PaymentType__c', type: 'text', sortable: true},
                          { label: 'IBAN/Conto Corrente Estero', fieldName: 'IBAN__c', type: 'text', sortable: true},
                          { label: 'Sottoscrittore e Debitore coincidono', fieldName: 'Sottoscrittore_e_Debitore_coincidono__c', type: 'boolean', sortable: true },
                          { label: 'Attivo', fieldName: 'blng__Active__c', type: 'boolean', sortable: true}];
    @api selectedItem;
    @track selectedRow = [];
    @api isNewPayment = false;
    isLoading = false;
    match = false;
    italy = true;
    @api paymentType;

    @wire(fetchData, { quoteId : '$quoteId'})
    wiredPayments(result) {
        this.wiredPaymentResults = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].blng__AccountPaymentMethods__r) {
                this.paymentRecords = JSON.parse(JSON.stringify(result.data[0].blng__AccountPaymentMethods__r));
                if(this.selectedItem){
                    this.selectedRow = this.paymentRecords.filter(item => item.Id == this.selectedItem.Id).map(record=>record.Id);
                }
                
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

    handleRowSelection(event){
        this.selectedItem = event.detail.selectedRows[0];
    }

    @api
    handleNext(){

        if(this.isNewPayment){
            const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);

            if(isInputsCorrect){
                this.isLoading = true;
                this.handleMockSubmit();
            }
            
        }else if(this.selectedItem){
            this.dispatchEvent(new CustomEvent('selectedpayment', { detail: this.selectedItem}));
            //this.dispatchEvent(new CustomEvent('next'));
        }
        
    }

    handleMockSubmit(){
 
        var temp = {};
        this.template.querySelectorAll('lightning-input-field').forEach(each => {
               temp[each.fieldName] = each.value;
            });
        this.dispatchEvent(new CustomEvent('setform', {detail : temp}));      
    }

    get options() {
        return [
            { label: 'SDD', value: '1', checked : true},
            { label: 'Bonifico', value: '2', checked : false},
        ];
    }

    get isPersonaFisicaClass(){
        return this.account.recordType == 'PersonAccount' ? 'slds-grid slds-size_1-of-1' : 'slds-grid slds-size_1-of-2';
    }

    get isPersonaFisica(){
        return this.account.recordType == 'PersonAccount';
    }

    handleCountry(event){
        this.italy = event.target.value == 'Italy';
    }

    handleMatch(event){
        this.match = !event.target.value;
    }

    handlePaymentType(event){

        this.paymentType = event.target.value;
        this.match = false;
    }

    get isSdd(){
        return this.paymentType == 1;
    }

    get isBonifico(){
        return this.paymentType == 2;
    }

    handleAddressSelection(event){
        this.address = event.detail.address;
    }

    handleNewPaymentMethod(){
        this.dispatchEvent(new CustomEvent('newpayment', {detail : true}));
    }

    back(){
        this.dispatchEvent(new CustomEvent('newpayment', {detail : false}));
    }

    get streetNumber(){
        return this.payment.StreetNumber__c ? this.payment.StreetNumber__c : this.customerAddress.street_number;
    }

    get streetName(){
        return this.payment.blng__BillingStreet__c ? this.payment.blng__BillingStreet__c : this.customerAddress.route;
    }

    get zipCode(){
        return this.payment.blng__BillingZipPostal__c ? this.payment.blng__BillingZipPostal__c : this.customerAddress.postal_code;
    }

    get city(){
        return this.payment.blng__BillingCity__c ? this.payment.blng__BillingCity__c : this.customerAddress.locality;
    }

    get province(){
        return this.payment.blng__BillingStateProvince__c ? this.payment.blng__BillingStateProvince__c : this.customerAddress.province;
    }
}