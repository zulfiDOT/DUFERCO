import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchDataAddress from '@salesforce/apex/aggiungiIndirizzoQuickAction_Controller.fetchData';

import { publish, MessageContext } from 'lightning/messageService';
import ENABLE_BUTTON_CHANNEL from '@salesforce/messageChannel/EnableButton__c';

export default class StepShippingAddress extends LightningElement {

    @api quoteId;
    @api account;
    @track addressRecords;
    wiredAddressResults;
    customerAddress = {};
    @track columns = [{ label: 'Tipo di Indirizzo', fieldName: 'Type__c', type: 'text', sortable: true},
                      { label: 'Nome Via', fieldName: 'StreetName__c', type: 'text', sortable: true},
                      { label: 'Numero Civico', fieldName: 'StreetNumber__c', type: 'text', sortable: true},
                      { label: 'Località', fieldName: 'City__c', type: 'text', sortable: true },
                      { label: 'Provincia', fieldName: 'Province__c', type: 'text', sortable: true},
                      { label: 'Paese', fieldName: 'Country__c', type: 'text', sortable: true}];
    selectedItem;
    @track selectedRow = [];
    isNewAddress = false;
    isLoading = false;

    @wire(fetchDataAddress, { quoteId : '$quoteId'})
    wiredAddress(result) {
        this.wiredAddressResults = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].Indirizzi__r) {
                this.addressRecords = JSON.parse(JSON.stringify(result.data[0].Indirizzi__r));
                //this.recordsAddressSize = this.addressRecords.length > 0;
                if(this.selectedItem){
                    this.selectedRow = this.addressRecords.filter(item => item.Id == this.selectedItem).map(record=>record.Id);
                }
            }

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

        if(this.isNewAddress){
            this.isLoading = true;
            this.template.querySelector('c-new-address-form').handleAddressSubmit();
        }else if(this.selectedItem){
            this.dispatchEvent(new CustomEvent('selectedaddress', { detail: this.selectedItem}));
            //this.dispatchEvent(new CustomEvent('next'));
        }
        
    }

    handleAddressSuccess(event){
        this.selectedItem = event.detail.Id;
        //this.dispatchEvent(new CustomEvent('selectedaddress', { detail: event.detail}));
        this.isLoading = false;
        this.isNewAddress = false;
        this.disableButton(false,false,'Avanti','Indietro');
        return refreshApex(this.wiredAddressResults); 
    }

    handleNewAddressMethod(){
        this.isNewAddress = true;
        this.disableButton(false,true,'Salva','Annulla');
    }

    back(){
        this.isNewAddress = false;
        this.disableButton(true,false,'Avanti','Indietro');
    }

    disableButton(disableRightBtn, disableLeftBtn, labelRightBtn, labelLeftBtn){
        const payload = { disableRightButton: disableRightBtn, disableLeftButton: disableLeftBtn, 
                            rightButtonLabel : labelRightBtn, leftButtonLabel : labelLeftBtn};
        publish(this.messageContext, ENABLE_BUTTON_CHANNEL, payload);
    }
}