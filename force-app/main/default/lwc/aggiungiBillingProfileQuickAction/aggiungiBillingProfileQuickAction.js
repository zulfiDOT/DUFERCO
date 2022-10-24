import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Status__c';
import PRICEBOOK_TYPE_FIELD from '@salesforce/schema/SBQQ__Quote__c.PricebookType__c';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getBillingRecords';

const fields = [STATUS_FIELD, PRICEBOOK_TYPE_FIELD];

export default class AggiungiBillingProfileQuickAction extends LightningElement {
    @api recordId;
    @track records;
    @api isCalledFromAura = false;
    accID;
    billingAccount = {};
    wiredBillingResult;
    selectedItem;
    isLoading = false;
    isNewBilling = false;
    disabledBtn = true;

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
    wiredBilling(result) {
        this.wiredBillingResult = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].Billing_Profiles__r) {
                this.records = JSON.parse(JSON.stringify(result.data[0].Billing_Profiles__r));
            }

            this.accID = result.data[0].Id;
            this.billingAccount.Id = result.data[0].Id;
            this.billingAccount.formaAnagrafica = result.data[0].FormaAnagrafica__c;
            this.billingAccount.sdiCode = result.data[0].RecordType.DeveloperName == 'PersonAccount' ? /*result.data[0].FiscalCode__c*/'0000000' : result.data[0].SdiCode__c;
            this.billingAccount.email = result.data[0].Email__c;
            this.billingAccount.pec = result.data[0].RecordType.DeveloperName == 'PersonAccount' ? result.data[0].PEC__pc : result.data[0].PEC__c;
            this.billingAccount.recordType = result.data[0].RecordType.DeveloperName;
            this.billingAccount.firstName = result.data[0].FirstName;
            this.billingAccount.lastName = result.data[0].LastName;
            this.billingAccount.name = result.data[0].Name;

        } else if (result.error) {
            console.error(error);
        }
    }

    handleSelectedItem(event){
        
        this.selectedItem = event.detail.selectedItem;
        this.records.forEach(item => {
            item.selected = item.Id === this.selectedItem.Id ? true :false;
        });
        this.disabledBtn = false;
        this.dispatchEvent(new CustomEvent('selectedbilling', { detail: {disableButton : false} }));
    }
    newBilling(){
        this.isNewBilling = true;
        this.disabledBtn = false;
        this.dispatchEvent(new CustomEvent('selectedbilling', { detail: {disableButton : false} }));
    }
    handleError(){
        this.isLoading = false;
    }
    handleHideForm(){
        this.isNewBilling = false;
        this.disabledBtn = false;
    }
    handleSuccess(){
        this.isLoading = false;
        this.isNewBilling = false;
        return refreshApex(this.wiredBillingResult);
    }
    handleDisableButton(event){
        this.disabledBtn = event.detail.disableButton;
        this.dispatchEvent(new CustomEvent('selectedbilling', { detail: {disableButton : this.disabledBtn} }));
        
    }
    @api
    handleSave(){
        
        if (this.isNewBilling) {
           return this.template.querySelector("c-new-billing-profile-form").handleBillingSubmit();
        }
        this.isLoading = true;
        var fields = {};
        var recordInput = {};
        var selectedRow = this.selectedItem;
        fields["Id"] = this.recordId;
        fields["Billing_Profile__c"] = selectedRow.Id;
        recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Operazione completata',
                        message: 'Billing Profile aggiunto correttamente',
                        variant: 'success'
                    })
                );   
                this.isLoading = false;
                
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
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
}