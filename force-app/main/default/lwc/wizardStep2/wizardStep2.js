import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import VAT_FIELD from '@salesforce/schema/Account.VatNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Account.Email__c';
import NATION_FIELD from '@salesforce/schema/Account.Nation__c';
import COMPANY_FIELD from '@salesforce/schema/Account.Company__c';
import FISCALCODE_FIELD from '@salesforce/schema/Account.FiscalCode__c';
import PERSONFISCALCODE_FIELD from '@salesforce/schema/Account.PersonContact.FiscalCode__c';

const myfields = [NAME_FIELD,VAT_FIELD,FISCALCODE_FIELD,PERSONFISCALCODE_FIELD,EMAIL_FIELD,NATION_FIELD,COMPANY_FIELD];
export default class WizardStep2 extends NavigationMixin(LightningElement) {
    @api accountId;
    @api rtBoolean;
    @track accRecord;
    @track url;

    @wire(getRecord, { recordId: '$accountId', fields: myfields})
        getAccRecord({data,error}){
            if (data) {
                this.accRecord = data;
                console.debug(JSON.stringify(data));
            }else if (error) {
                console.log(error);
            }
        }

    handlePreavious(event) {

        this.dispatchEvent(new CustomEvent('preavious'));
    }

    goToAccount() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    get isBusiness(){
        return this.accRecord.recordTypeInfo.name == 'Persona Giuridica' && this.accRecord.fields.Nation__c.value == 'IT';
    }

    get isPerson(){
        return this.accRecord.recordTypeInfo.name == 'Persona Fisica' && this.accRecord.fields.Nation__c.value == 'IT';
    }

    get isForeign(){
        return this.accRecord.recordTypeInfo.name == 'Persona Fisica' && this.accRecord.fields.Nation__c.value != 'IT';
    }

    handleNext(){
        this.dispatchEvent(new CustomEvent('next'));
    }

}