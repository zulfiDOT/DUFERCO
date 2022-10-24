import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { updateRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Status__c';
import PRICEBOOK_TYPE_FIELD from '@salesforce/schema/SBQQ__Quote__c.PricebookType__c';
import fetchData from '@salesforce/apex/aggiungiIndirizzoQuickAction_Controller.fetchData';

const fields = [STATUS_FIELD, PRICEBOOK_TYPE_FIELD];

export default class aggiungiIndirizzoQuickAction extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isCalledFromAura = false;
    @api disabledBtnAura;
    @track records;
    accID;
    selectedItem;
    disabledBtn = true;
    isLoading = false;
    isNewAddress = false;
    wiredAddressResult;

    @wire(getRecord, { recordId: '$recordId', fields })
    quote;

    get statusAndPricebook(){

        var showAction = false;
        if (this.quote && this.quote.data) {
            showAction = this.quote.data.fields.PricebookType__c.value == 'IdR' && this.quote.data.fields.SBQQ__Status__c.value != '0';
        }
        return  !showAction;
    }

    @wire(fetchData, { quoteId : '$recordId'})
    wiredAddress(result) {
        this.wiredAddressResult = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].Indirizzi__r) {
                this.records = JSON.parse(JSON.stringify(result.data[0].Indirizzi__r));
            }

            this.accID = result.data[0].Id;

        } else if (result.error) {
            console.error(error);
        }
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
    
    get recordsLoaded(){
        var recordsLoaded = false;
        if (this.records) {
            recordsLoaded = this.records.length > 0 && !this.isNewAddress;
        }
          return recordsLoaded;
      }

    // handleRowSelection(event){
    //       this.disabledBtn = false;
    //   }

    handleSelectedItem(event){
        this.disabledBtn = false;
        this.selectedItem = event.detail.selectedItem;
        this.records.forEach(item => {
            item.selected = item.Id === this.selectedItem.Id ? true :false;
        });
        
        this.dispatchEvent(new CustomEvent('selected'));
    }
    newAddress(){
        this.isNewAddress = true;
    }

    handleCancel(){
        this.isNewAddress = false;
    }
    handleAddressSuccess(event){
        //getRecordNotifyChange([{recordId: this.recordId}]);
        this.isNewAddress = false;
        return refreshApex(this.wiredAddressResult);
        
    }
    handleAddressSubmit(event){
        event.preventDefault(); 
        this.template.querySelector('c-new-address-form').handleAddressSubmit();
    }

    handleAddressError(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione Fallita',
                message: '',
                variant: 'error'
            })
        );
    }
    @api
    handleSave(){
        this.isLoading = true;
        var fields = {};
        var recordInput = {};
        //var selectedRow = this.template.querySelector('lightning-datatable').getSelectedRows()[0];
        var selectedRow = this.selectedItem;
        fields["Id"] = this.recordId;
        fields["ShippingCompany__c"] = selectedRow.Company__c ? selectedRow.Company__c : '';
        fields["ShippingLastName__c"] = selectedRow.LastName__c ? selectedRow.LastName__c : '';
        fields["SBQQ__ShippingName__c"] = selectedRow.FirstName__c ? selectedRow.FirstName__c : '';
        fields["SBQQ__ShippingStreet__c"] = selectedRow.StreetName__c ? selectedRow.StreetName__c : '';
        fields["ShippingStreetNumber__c"] = selectedRow.StreetNumber__c ? selectedRow.StreetNumber__c : '';
        fields["SBQQ__ShippingPostalCode__c"] = selectedRow.ZipCode__c ? selectedRow.ZipCode__c : '';
        fields["SBQQ__ShippingState__c"] = selectedRow.Province__c ? selectedRow.Province__c : '';
        fields["SBQQ__ShippingCity__c"] = selectedRow.City__c ? selectedRow.City__c: '';
        fields["SBQQ__ShippingCountry__c"] = selectedRow.Country__c ? selectedRow.Country__c : '';
        fields["ShippingNote__c"] = selectedRow.Note__c ? selectedRow.Note__c : '';
        recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Operazione completata',
                        message: 'Indirizzo aggiunto correttamente',
                        variant: 'success'
                    })
                );   
                this.isLoading = false;
                //eval("$A.get('e.force:refreshView').fire();");
                getRecordNotifyChange([{recordId: this.recordId}]);

                if(!this.isCalledFromAura){
                    this.closeAction();
                }else{
                    this.dispatchEvent(new CustomEvent('successinsert'));
                }
            }
        ).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.isLoading = false;
        });
      }
      
}