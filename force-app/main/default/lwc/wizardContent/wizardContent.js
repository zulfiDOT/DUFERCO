import { api, LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import COMPANY_FIELD from '@salesforce/schema/User.Company__c';
import NAME_FIELD from '@salesforce/schema/User.Name';
import AGENCYCODE_FIELD from '@salesforce/schema/User.AgencyCode__c';
import AGENTCODE_FIELD from '@salesforce/schema/User.AgentCode__c';
import SALESCHANNEL_FIELD from '@salesforce/schema/User.SalesChannel__c';
import Id from '@salesforce/user/Id';
import queryRecords from '@salesforce/apex/RecordTypeSelector.queryRecords';
const fields = [COMPANY_FIELD, NAME_FIELD, AGENCYCODE_FIELD, AGENTCODE_FIELD, SALESCHANNEL_FIELD];
export default class WizardContent extends LightningElement {
    userId = Id;
    steps = [{label: "Step 1", value: "1"}, {label: "Step 2", value: "2"}, {label: "Step 3", value: "3"}];
    current = "1";
    currentIndex = 0;
    accountId;
    accDatamax;
    query;
    @track fieldValueContent = {"RecordTypeId":"",
                            "Nation__c":"IT",
                            "VatNumber__c":"",
                            "FiscalCode__c":"",
                            "Email__c":"",
                            "Company__c":'',
                            "AccountSource":''};
    @api rtBoolean = {'isBusiness':false,'isPerson':false};


    @wire(getRecord, { recordId: '$userId', fields })
    userInfo({error,data}) {
        if (data) {
            // this.fieldValueContent.Company__c = data.fields.Company__c.value;
            this.fieldValueContent.Nation__c = 'IT';
            this.fieldValueContent.Company__c = data.fields.Company__c;
            //this.fieldValueContent.AgentId__c = data.fields.Name.value;
            this.fieldValueContent.AgentId__c = data.fields.AgentCode__c.value;
            this.fieldValueContent.AccountSource = data.fields.SalesChannel__c.displayValue;
            //alert('AccountSource: '+JSON.stringify(data.fields.SalesChannel__c));
            if (data.fields.AgencyCode__c.value) {
                this.query = 'Select Id, Name From Account Where AgencyCodeDatamax__c = \''+data.fields.AgencyCode__c.value+'\' LIMIT 1';               
            }
        }else if (error) {
            console.error('USERINFO error:'+error);
        }
    }

    @wire(queryRecords, {query: '$query'})
    resultQuery({error,data}){
        if (data && data.length) {
            console.log(data);
            this.fieldValueContent.Agency__c = data[0].Id;
        }else if(error){
            console.error(error);
        }
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

    handleNext(event) {
        this.accountId = '';
        this.accDatamax = '';
        if (event.detail) {
            if (event.detail.accountId) {
                this.accountId = event.detail.accountId;
            }else if (event.detail.datamaxField) {
                this.accDatamax = event.detail.datamaxField;
            }   
        }

        if(this.currentIndex + 1 == this.steps.length) {
            console.log(this.contactId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.contactId,
                    actionName: 'view'
                }
            });
        } else {

            this.currentIndex++;
            this.current = this.steps[this.currentIndex].value;
        }
        
    }

    handleInputChange(event){
        
        this.fieldValueContent[event.detail.field] = event.detail.value;
    }

    handleRadioBtn(event){

        this.fieldValueContent.RecordTypeId = event.detail.recordType.value;
        this.fieldValueContent.RecordTypeName = event.detail.recordType.label;
        this.rtBoolean.isBusiness= event.detail.recordType.label == 'Persona Giuridica';
        this.rtBoolean.isPerson= event.detail.recordType.label == 'Persona Fisica';
        this.fieldValueContent.FiscalCode__c = '';
        this.fieldValueContent.VatNumber__c = '';
    }

    handlePreavious(){
        this.currentIndex--;
        this.current = this.steps[this.currentIndex].value;
    }
}