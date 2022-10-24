import { api, LightningElement, wire } from 'lwc';
import {createRecord} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createObjects from '@salesforce/apex/AccountDatamaxFormController.createObjFromDatamax';
import isAdminAgency from '@salesforce/apex/AccountDatamaxFormController.isAdminAgency';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class AccountDatamaxForm extends LightningElement {
    
    @api accountDatamax;
    @api fieldPreaviusStep;
    contacts = [];
    address = {};
    account;
    params = [];
    isBusiness = false;
    isLoading = false;
    isAdmin = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    get isBusinessType(){
        
        this.isBusiness = this.accountDatamax['account_vatnumber'] ? true : false;
        return this.isBusiness;
    }

    get accountName(){

        return this.accountDatamax['account_vatnumber'] ? this.accountDatamax['account_name'] : this.accountDatamax['contacts'][0]['contact_firstname']+' '+this.accountDatamax['contacts'][0]['contact_lastname'];
    }

    get agentCode(){
        isAdminAgency()
        .then(result =>{
            console.log(result);
            this.isAdmin = result;
        })
        .catch(error => {
            console.log('Error while creating account'+this.errorMapping(error));
        });

        return this.isAdmin || this.fieldPreaviusStep.AgentId__c == this.accountDatamax['account_agent'];
    }

    handleSave(){
        this.isLoading = true;
        this.params = [];
        const fields = {};
        if(!this.isBusiness){
            fields['FirstName'] = this.accountDatamax['contacts'][0]['contact_firstname'];
            fields['LastName'] = this.accountDatamax['contacts'][0]['contact_lastname'];
        }else{
            fields['Name'] = this.accountDatamax['account_name'];
        }
        fields['DatamaxCustomerCode__c'] = this.accountDatamax['account_iddatamax'];
        fields['FiscalCode__c'] = this.accountDatamax['account_fiscalcode'];
        fields['VatNumber__c'] = this.accountDatamax['account_vatnumber'];
        fields['PEC__c'] = this.accountDatamax['account_pec'];
        fields['PrivacyProfilazioneConsumo__c'] = this.accountDatamax['account_privacyprofilazione'];
        fields['PrivacyCommercialeTerzi__c'] = this.accountDatamax['account_privacycommercialeterzi'];
        fields['PrivacyCommerciale__c'] = this.accountDatamax['account_privacycommerciale'];
        fields['PrivacyContratto__c'] = this.accountDatamax['account_privacycontratto'];
        //fields['Agency__r.AgencyCodeDatamax__c'] = this.accountDatamax['account_agency']; //lookup
        // fields[ 'Agency__r' ] = {
        //                         'AgencyCodeDatamax__c' : this.accountDatamax['account_agency']
        //                             };
        fields['AgentId__c'] = this.accountDatamax['account_agent'];
        fields['StatusCommodity__c'] = this.accountDatamax['account_status'];
        fields['Phone'] = this.accountDatamax['account_phone'];
        fields['Phone2__c'] = this.accountDatamax['account_mobile'];
        fields['Fax'] = this.accountDatamax['account_fax'];
        fields['Email__c'] = this.accountDatamax['account_email'];
        fields['FormaAnagrafica__c'] = this.accountDatamax['account_formaanagrafica'];
        fields['IDTERPDatamax__c'] = this.accountDatamax['account_idterp'];
        fields['Nation__c'] = this.accountDatamax['account_country'];
        const rtis = this.objectInfo.data.recordTypeInfos;
        if(this.isBusiness){
            fields['RecordTypeId'] = Object.keys(rtis).find(rti => rtis[rti].name === 'Persona Giuridica');
        }else{
            fields['RecordTypeId'] = Object.keys(rtis).find(rti => rtis[rti].name === 'Persona Fisica');
        }
        fields['sobjectType'] = 'Account';
        this.account = fields;
        this.params.push(this.account);
        if(this.isBusiness){
            this.createContact();
        }
        this.createAddress();
        createObjects({objParams : this.params})
            .then(result =>{
                     console.log(result);
                     this.notifyUser('Operazione Completata','','success');
                     this.dispatchEvent(new CustomEvent('next', { detail : {accountId : result.Account}}));
            })
            .catch(error => {

                this.notifyUser('Error while creating account',this.errorMapping(error),'error');
            })
            .finally(() => this.isLoading = false );
    }
    


    notifyUser(title, message, variant) {
          const toastEvent = new ShowToastEvent({ title, message, variant });
          this.dispatchEvent(toastEvent);
        
      }

    createContact(){
        var contacts = this.accountDatamax['contacts'];
        for(var contact of this.accountDatamax['contacts']){
            var fields = {};
            fields['DatamaxContactCode__c'] = contact['contact_iddatamax'];
            fields['FirstName'] = contact['contact_firstname'];
            fields['LastName'] = contact['contact_lastname'];
            fields['FiscalCode__c'] = contact['contact_fiscalcode'];
            fields['Birthdate'] = contact['contact_birthdate'];
            fields['Email'] = contact['contact_email'];
            fields['Gender__c'] = contact['contact_gender'];
            fields['Phone'] = contact['contact_phone'];
            fields['MobilePhone'] = contact['contact_mobile'];
            fields['Type__c'] = contact['contact_type'];
            fields['Fax'] = contact['contact_fax'];
            fields['NascitaLuogo__c'] = contact['contact_nascitaluogo'];
            fields['NascitaProvincia__c'] = contact['contact_nascitaprovincia'];
            fields['DocTipo__c'] = contact['contact_doctipo'];
            fields['DocNumero__c'] = contact['contact_docnumero'];
            fields['DocRilasciatoDa__c'] = contact['contact_docrilasciatoda'];
            fields['Role__c'] = contact['acr_roles'];
            fields['Account'] = {'sobjectType':'Account',
                                'DatamaxCustomerCode__c':this.account.DatamaxCustomerCode__c
                                };
            fields['sobjectType'] = 'Contact';
            this.params.push(fields);
        }
    }

    createAddress(){
        var address = this.accountDatamax['addresses'][0];
        this.address['StreetName__c'] = address['address_streetname'];
        this.address['StreetNumber__c'] = address['address_streetnumber'];
        this.address['City__c'] = address['address_city'];
        this.address['Hamlet__c'] = address['address_hamlet'];
        this.address['Province__c'] = address['address_province'];
        this.address['ZipCode__c'] = address['address_zipcode'];
        this.address['Country__c'] = address['address_country'];
        this.address['Note__c'] = address['address_note'];
        this.address['ZipCode__c'] = address['address_zipcode'];
        this.address['Type__c'] = this.isBusiness ? '9': '8';
        this.address['AccountId__r'] = {'sobjectType':'Account',
                                'DatamaxCustomerCode__c':this.account.DatamaxCustomerCode__c
                            };
        this.address['sobjectType'] = 'Address__c';
        this.params.push(this.address);
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
    handlePreavious(evt){
        this.dispatchEvent(new CustomEvent('preavious'));
    }
}