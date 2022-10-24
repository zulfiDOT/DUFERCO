import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getPaymentMethod';

import { publish, MessageContext } from 'lightning/messageService';
import ENABLE_BUTTON_CHANNEL from '@salesforce/messageChannel/EnableButton__c';

export default class StepPaymentMethod extends LightningElement {

    @api quoteId;
    @api account;
    @track paymentRecords;
    wiredPaymentResults;
    customerAddress = {};
    @track columns = [{ label: 'Tipo di Pagamento', fieldName: 'blng__PaymentType__c', type: 'text', sortable: true},
                          { label: 'IBAN/Conto Corrente Estero', fieldName: 'IBAN__c', type: 'text', sortable: true},
                          { label: 'Sottoscrittore e Debitore coincidono', fieldName: 'Sottoscrittore_e_Debitore_coincidono__c', type: 'boolean', sortable: true },
                          { label: 'Attivo', fieldName: 'blng__Active__c', type: 'boolean', sortable: true}];
    selectedItem;
    @track selectedRow = [];
    isNewPayment = false;
    isLoading = false;

    @wire(fetchData, { quoteId : '$quoteId'})
    wiredPayments(result) {
        this.wiredPaymentResults = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].blng__AccountPaymentMethods__r) {
                this.paymentRecords = JSON.parse(JSON.stringify(result.data[0].blng__AccountPaymentMethods__r));
                if(this.selectedItem){
                    this.selectedRow = this.paymentRecords.filter(item => item.Id == this.selectedItem).map(record=>record.Id);
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

    @wire(MessageContext)
    messageContext;

    handleRowSelection(event){
        this.selectedItem = event.detail.selectedRows[0];
        this.disableButton(false,false,'Avanti','Indietro');
    }

    @api
    handleNext(){

        if(this.isNewPayment){
            this.isLoading = true;
            this.template.querySelector('c-payment-method-item').handleSubmitPayment();
        }else if(this.selectedItem){
            this.dispatchEvent(new CustomEvent('selectedpayment', { detail: this.selectedItem}));
            //this.dispatchEvent(new CustomEvent('next'));
        }
        
    }

    handlePaymentSuccess(event){
        this.selectedItem = event.detail;
        //this.dispatchEvent(new CustomEvent('selectedpayment', { detail: event.detail}));
        this.isLoading = false;
        this.isNewPayment = false;
        this.disableButton(false,false,'Avanti','Indietro');
        return refreshApex(this.wiredPaymentResults); 
    }

    handleNewPaymentMethod(){
        this.isNewPayment = true;
        this.disableButton(false,true,'Salva','Annulla');
    }

    back(){
        this.isNewPayment = false;
        this.disableButton(true,false,'Avanti','Indietro');
    }

    disableButton(disableRightBtn, disableLeftBtn, labelRightBtn, labelLeftBtn){
        const payload = { disableRightButton: disableRightBtn, disableLeftButton: disableLeftBtn, 
                            rightButtonLabel : labelRightBtn, leftButtonLabel : labelLeftBtn};
        publish(this.messageContext, ENABLE_BUTTON_CHANNEL, payload);
    }
}