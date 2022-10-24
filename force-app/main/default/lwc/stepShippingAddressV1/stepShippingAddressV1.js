import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchDataAddress from '@salesforce/apex/aggiungiIndirizzoQuickAction_Controller.fetchData';

export default class StepShippingAddressV1 extends LightningElement {

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
    @api address = {}
    @api selectedItem;
    @track selectedRow = [];
    @api isNewAddress = false;
    isLoading = false;

    @wire(fetchDataAddress, { quoteId : '$quoteId'})
    wiredAddress(result) {
        this.wiredAddressResults = result;
        if (result.data) {
            if (result.data[0].Indirizzi__r) {
                this.addressRecords = JSON.parse(JSON.stringify(result.data[0].Indirizzi__r));
                if(this.selectedItem){
                    this.selectedRow = this.addressRecords.filter(item => item.Id == this.selectedItem.Id).map(record=>record.Id);
                }
            }

        } else if (result.error) {
            console.error(error);
        }
    }

    handleRowSelection(event){
        this.selectedItem = event.detail.selectedRows[0];
    }

    @api
    handleNext(){

        if(this.isNewAddress){
            const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
            if(isInputsCorrect){
                this.mockSubmit();
            }
        }else if(this.selectedItem){
            this.dispatchEvent(new CustomEvent('selectedaddress', { detail: this.selectedItem}));
            
        }
        
    }

    mockSubmit(){      
        var temp = {};
        this.template.querySelectorAll('lightning-input-field').forEach(each => {
               temp[each.fieldName] = each.value;
            });
        this.dispatchEvent(new CustomEvent('setform', {detail : temp}));
    }

    handleAddressSelection(event){
        this.customerAddress = event.detail.address;
    }

    get streetNumber(){
        return this.address.StreetNumber__c ? this.address.StreetNumber__c : this.customerAddress.street_number;
    }

    get streetName(){
        return this.address.StreetName__c ? this.address.StreetName__c : this.customerAddress.route;
    }

    get zipCode(){
        return this.address.ZipCode__c ? this.address.ZipCode__c : this.customerAddress.postal_code;
    }

    get city(){
        return this.address.City__c ? this.address.City__c : this.customerAddress.city;
    }

    get province(){
        return this.address.Province__c ? this.address.Province__c : this.customerAddress.province;
    }

    get country(){
        return this.address.Country__c ? this.address.Country__c : this.customerAddress.country;
    }

    get locality(){
        return this.address.Hamlet__c ? this.address.Hamlet__c : this.customerAddress.city != this.customerAddress.locality ? this.customerAddress.locality : '';
    }

    handleNewAddressMethod(){
        this.dispatchEvent(new CustomEvent('newaddress', {detail : true}));
    }

    back(){
        this.dispatchEvent(new CustomEvent('newaddress', {detail : false}));
    }
}