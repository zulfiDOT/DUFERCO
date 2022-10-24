import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewAddressForm extends LightningElement {

    @api accountId;
    @api hideButton = false;
    @api disableAccount = false;
    @api type;
    @api typeReadOnly = false;
    isLoading = false;
    address = {"street_number":"",
                "route":"",
                "postal_code":"",
                "city":"",
                "locality":"",
                "province":"",
                "country":""}

    cancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleSuccess(event){
        this.isLoading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione completata',
                message: 'Indirizzo creato correttamente',
                variant: 'success'
            })
        );
        this.dispatchEvent(new CustomEvent('addresssuccess', { detail: {Id : event.detail.id} }));
    }

    handleError(event){
        console.log('error');
        var message = '';
        for (var i in event.detail.output.errors){
            if(event.detail.output.errors[i].errorCode == 'DUPLICATE_VALUE' &&
                event.detail.output.errors[i].message.includes("UniqueKey__c")) {
                message = "Esiste già un indirizzo di residenza/sede legale associato al cliente: non è possibile inserirne un altro.";
            }
        }
        this.isLoading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Operazione fallita',
                variant: 'error',
                message : message
            })
        );
        this.dispatchEvent(new CustomEvent('addresserror'));
    }

    @api handleAddressSubmit(){

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
        
        if (isInputsCorrect) {
            this.isLoading = true;
            this.template.querySelector('lightning-record-edit-form').submit();
        }
        
    }

    @api handleMockSubmit(){

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
            .reduce((validSoFar, inputField) => {
                return (validSoFar && inputField.reportValidity());
            }, true);
            
        var temp = {};
        this.template.querySelectorAll('lightning-input-field').forEach(each => {
               temp[each.fieldName] = each.value;
            });
        if(isInputsCorrect){
            this.dispatchEvent(new CustomEvent('setform', {detail : temp}));
        }
    }

    /*validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }*/

    handleAddressSelection(event){
        this.address = event.detail.address;
    }

    get locality(){

        return this.address.city != this.address.locality ? this.address.locality : '';
    }

    addressInputChange(event){

        const address = this.template.querySelector('lightning-input-address');
    
        console.log('Street is ' , event.target.street);
        console.log('City is ' , event.target.city);
        console.log('Province is ' , event.target.province);
        console.log('Country is ' , event.target.country);
        console.log('postal Code is ' , event.target.postalCode);
    
    
        }
}