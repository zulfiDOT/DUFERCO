import { LightningElement, api, wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NATION_FIELD from '@salesforce/schema/Account.Nation__c';
import queryAccountBeforeInsert from '@salesforce/apex/RecordTypeSelector.queryAccountBeforeInsert';
import retrieveAccount from '@salesforce/apex/MulesoftApiController.retrieveAccount';
export default class WizardStep1 extends LightningElement {

    @track optionList=[];
    @api fieldValue;
    @api rtBoolean;
    @track accInfo;
    @track isLoading = false;

    // Gestione Validazione Campi
    @track checkvalidation = true;
    @track validationruleserror = 'hide';
    @track validationruleserrormessage = '';
    @track inputerror = '';
    // fine

    accId;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    getRecordType({error,data}) {
        if(data){
            this.accInfo = data;
            for (const key in data.recordTypeInfos) {
                if(data.recordTypeInfos[key].name!='Master' && data.recordTypeInfos[key].name!='Partner' && data.recordTypeInfos[key].name!='Principale'){
                    this.optionList.push({ "label": data.recordTypeInfos[key].name, "value": key});
                }                
            }
        }else if(error){
            console.log('error');
        }
        
    }

    handleChange(event){
        var rtValue=[];
            rtValue['label'] = this.optionList.filter(function(el){
                               return el.value == event.detail.value})[0].label;
            rtValue['value'] = event.detail.value;
        
            this.dispatchEvent(new CustomEvent('handleradio',{
                detail: {"recordType":rtValue}
            }))
        
    }
    get businessItaly(){

        return this.rtBoolean.isBusiness;
    }
    get personItaly(){

        return this.rtBoolean.isPerson && this.fieldValue.Nation__c == 'IT';
    }
    get notItaly(){

        return this.rtBoolean.isPerson && this.fieldValue.Nation__c != 'IT';
    }

    handleFormInputChange(event){
        // In 1 line, assign the value to the property
        var currentField= [];
        currentField["field"] = event.target.fieldName;
        currentField["value"] = event.target.value;
        this.dispatchEvent(new CustomEvent('inputchange', {
            detail: currentField
        }));


        console.log(event.target.fieldName+' '+event.target.value);
        this.checkvalidationrules(event);

    }

    checkvalidationrules(event){

        if( event.target.fieldName == 'Nation__c' ){
            if( event.target.value != 'IT' ){
                this.checkvalidation = false;
            }else{
                this.checkvalidation = true;
            }
        }
        
        if((event.target.fieldName == 'FiscalCode__c' || event.target.fieldName == 'VatNumber__c') && this.fieldValue.Nation__c == 'IT'){
            let numberspattern = /^\d+$/;
            let cfpattern = /^[a-zA-Z]{6}[0-9]{2}[abcdehlmprstABCDEHLMPRST]{1}[0-9]{2}([a-zA-Z]{1}[0-9]{3})[a-zA-Z]{1}$/;

            if(event.target.fieldName == 'FiscalCode__c' && (event.target.value.length<16 || cfpattern.test(event.target.value)==false) ){ 
                this.validationruleserrormessage = 'Il campo Codice Fiscale non è popolato correttamene';
                this.validationruleserror = 'show';
                this.inputerror = 'slds-has-error slds-input';
                this.checkvalidation = true;
            }else if( event.target.fieldName == 'VatNumber__c' && (event.target.value.length<11 || numberspattern.test(event.target.value)==false) ){ 
                this.validationruleserrormessage = 'Il campo Partita Iva non è popolato correttamene';
                this.validationruleserror = 'show';
                this.inputerror = 'slds-has-error slds-input';
                this.checkvalidation = true;
            }else{
                this.validationruleserror = 'hide';
                this.inputerror = '';
                this.checkvalidation = false;
            }
            
        }
    }
    
    handleNext(event){
        var params={};
        if (((!this.fieldValue.RecordTypeId) || this.rtBoolean.isBusiness && !this.fieldValue.VatNumber__c) || 
            (this.rtBoolean.isPerson && !this.fieldValue.FiscalCode__c && this.fieldValue.Nation__c == 'IT') || 
            (this.rtBoolean.isPerson && this.fieldValue.Nation__c != 'IT' && !this.fieldValue.Email__c)) {
            
            this.showToastEvent('Compilare tutti i campi','','error');

        }else{
            this.isLoading = true;
            params['Company__c'] = this.fieldValue.Company__c.value;
            params['Nation__c'] = this.fieldValue.Nation__c;
            if (this.rtBoolean.isBusiness) {
                params['VatNumber__c'] = this.fieldValue.VatNumber__c;
            }else if (this.rtBoolean.isPerson && this.fieldValue.Nation__c =='IT') {
                params['FiscalCode__c'] = this.fieldValue.FiscalCode__c;
            }else if (this.rtBoolean.isPerson && this.fieldValue.Nation__c != 'IT') {
                params['Email__c'] = this.fieldValue.Email__c;
            }
            console.log('params '+params);
            this.searchAccount(params);  
            //this.isLoading = false;
            //this.dispatchEvent(new CustomEvent('next', { detail : this.accId}));
        }
    }


    searchAccount(params){

        queryAccountBeforeInsert({whereConditions : this.whereConditionBuilder(params)})
        .then(result => {

            if (result.recordFound) {
                this.accId = result.records[0].Id;
                this.showToastEvent('Record presente','È stato trovato un record con i dati inseriti','success');
                //this.dispatchEvent(new CustomEvent('next', { detail : this.accId}));
                this.dispatchEvent(new CustomEvent('next', { detail : {accountId : this.accId}}));
            }else if(this.fieldValue.Nation__c != 'IT'){

                this.dispatchEvent(new CustomEvent('next'));

            }else{
                // chiamata api
                //this.showToastEvent('Record non trovato','Chiamata api','error');
                //this.dispatchEvent(new CustomEvent('next', { detail : this.accId}));
                this.retrieveAccountFromDatamax();
            }

        }).catch(error => {

                console.log(error);
        });
    }

    retrieveAccountFromDatamax(){
        var params = {};
        params["fiscalCode"] = this.fieldValue.FiscalCode__c;
        params["vatNumber"] = this.fieldValue.VatNumber__c;
        params["contactType"] = this.fieldValue.RecordTypeName == 'Persona Fisica' ? '1':'2';
        retrieveAccount({accParams : params})
        .then(result => {
            var response = JSON.parse(result);
                if (response.account_iddatamax) {
                    this.dispatchEvent(new CustomEvent('next', { detail : {datamaxField : response}}));
                }else{
                    this.dispatchEvent(new CustomEvent('next'));
                }
        }).catch(error => {
            console.log(error);
            
            this.isLoading = false;
        })
    }

    whereConditionBuilder(whereCond){
        var returnValue;
        for (let [key, value] of Object.entries(whereCond)) {
            console.log(key + " = " + value);
            if (returnValue) {
                returnValue += ' AND '+key+ " = \'" +value.trim()+'\'';
            }else{
                returnValue = ' ( '+key+ " = \'" +value.trim()+'\'';
            }
         }
         returnValue += ' )';
         return returnValue;
    }

    showToastEvent(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

}