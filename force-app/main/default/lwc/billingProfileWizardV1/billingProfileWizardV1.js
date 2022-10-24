import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Status__c';
import PRICEBOOK_TYPE_FIELD from '@salesforce/schema/SBQQ__Quote__c.PricebookType__c';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getBillingRecords';

const fields = [STATUS_FIELD, PRICEBOOK_TYPE_FIELD];
export default class BillingProfileWizardV1 extends LightningElement {
    steps = [{label: "Metodo di Pagamento", value: "1"}, {label: "Indirizzo di Fatturazione", value: "2"}, {label: "Billing Profile", value: "3"}];
    current = "1";
    currentIndex = 0;
    @track columns = [{ label: 'Modalità di Pagamento', fieldName: 'PaymentMode__c', type: 'text', sortable: true},
                      { label: 'Attivo', fieldName: 'IsActive__c', type: 'boolean', sortable: true},
                      { label: 'Indirizzo di Fatturazione', fieldName: 'Indirizzo_di_fatturazione__c', type: 'text', sortable: true },
                      { label: 'Condizioni di Pagamento', fieldName: 'PaymentConditions__c', type: 'text', sortable: true}];
    
    @track billingRecords;
    @api recordId;
    isLoading;
    billingAccount = {};
    accID;
    wiredBillingResult;
    selectedItem;
    selectedRow = [];
    startWizard = false;
    paymentSelected;
    addressSelected;
    payment = {};
    address = {};
    newPayment = false;
    newAddress = false;



    @wire(fetchData, { quoteId : '$recordId'})
    wiredBilling(result) {
        this.wiredBillingResult = result;
        if (result.data) {
            //this.records = Object.values({...data});
            if (result.data[0].Billing_Profiles__r) {
                this.billingRecords = JSON.parse(JSON.stringify(result.data[0].Billing_Profiles__r));
                if(this.selectedItem){
                    this.selectedRow = this.billingRecords.filter(item => item.Id == this.selectedItem).map(record => record.Id);
                    this.startWizard = false;
                    this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false, rightButtonLabel : 'Salva', leftButtonLabel : 'Annulla'}}));
                }
            }

            this.accID = result.data[0].Id;
            this.billingAccount.Id = result.data[0].Id;
            this.billingAccount.formaAnagrafica = result.data[0].FormaAnagrafica__c;
            this.billingAccount.sdiCode = result.data[0].RecordType.DeveloperName == 'PersonAccount' ? result.data[0].FiscalCode__c : result.data[0].SdiCode__c;
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

    @wire(getRecord, { recordId: '$recordId', fields })
    quote;

    get statusAndPricebook(){

        var showAction = false;
        if (this.quote && this.quote.data) {
            showAction = this.quote.data.fields.PricebookType__c.value == 'IdR' && this.quote.data.fields.SBQQ__Status__c.value != '0';
        }
        return  !showAction;
    }

    handleRowSelection(event){

        this.selectedItem = event.detail.selectedRows[0].Id;
        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false}}));
    }

    handleSelectedPayment(event){
        this.payment = '';
        this.paymentSelected = event.detail;
        this.handleNext();
    }

    handleNewPayment(event){
        this.newPayment = event.detail;
    }

    handleNewAddress(event){
        this.newAddress = event.detail;
    }

    handleSelectedAddress(event){
        this.address = '';
        this.addressSelected = event.detail;
        this.handleNext();
    }

    back(){

        if(this.currentIndex == 0){
            this.startWizard = false;
        }else{
            this.currentIndex--;
            this.current = this.steps[this.currentIndex].value;
        }
    }

    handleNext(event) {
        if(this.currentIndex + 1 == this.steps.length) {

        }else {
            this.currentIndex++;
            this.current = this.steps[this.currentIndex].value;
        }
    }

    @api
    handleSave(){
        
        if(!this.startWizard){
            this.saveBillingSelected();
        }else if(this.steps[this.currentIndex].value == 1){
            this.saveStep1();
        }else if(this.steps[this.currentIndex].value == 2){
            this.saveStep2();
        }else if(this.steps[this.currentIndex].value == 3){
            this.saveStep3();
        }
    }

    saveBillingSelected(){
        this.isLoading = true;
        var fields = {};
        var recordInput = {};
        fields["Id"] = this.recordId;
        fields["Billing_Profile__c"] = this.selectedItem;
        recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.notifyUser('Operazione completata','Billing Profile aggiunto correttamente','success');          
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.dispatchEvent(new CustomEvent('successinsert'));
            }
        ).catch(error => {
            
            this.notifyUser('Errore',this.errorMapping(error),'error');
        })
        .finally(() => this.isLoading = false );
    }

    handleSetForm(event){
        this.payment = event.detail;
        this.paymentSelected = '';
        this.handleNext();
    }

    handleSetFormAd(event){
        this.address = event.detail;
        this.addressSelected = '';
        this.handleNext();
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
        }else{
            errorMessage = error.body.message;
        }

        return errorMessage;
    }

    saveStep1(){
        this.template.querySelector('c-step-payment-method-v1').handleNext();
    }

    saveStep2(){
        this.template.querySelector('c-step-shipping-address-v1').handleNext();
    }

    saveStep3(){
        this.template.querySelector('c-step-billing-profile-v1').handleBillingSubmit();
    }

    handleNewBillingProfile(){
        this.startWizard = true;
        this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : false, rightButtonLabel : 'Avanti', leftButtonLabel : 'Indietro'}}));

    }

    

    get step1() {
        return this.current == this.steps[0].value;
    }

    get step2() {
        return this.current == this.steps[1].value;
    }

    get step3() {
        return this.current == this.steps[2].value;
    }

    handleSuccess(event){
        //this.selectedItem = event.detail.Id;
        //this.startWizard = false;  
        //return refreshApex(this.wiredBillingResult); 
        getRecordNotifyChange([{recordId: this.recordId}]);
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleError(){
        
    }

    @api
    handlePreavious(){
        if(!this.startWizard){
            this.dispatchEvent(new CustomEvent('close'));
        }else if(this.current - 1 == 0){
            this.startWizard = false;
            this.dispatchEvent(new CustomEvent('disablebutton', { detail: {disableButton : true, rightButtonLabel : 'Salva', leftButtonLabel : 'Annulla'}}));
        }else{
            this.currentIndex--;
            this.current = this.steps[this.currentIndex].value;
        }
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
      
    }
}