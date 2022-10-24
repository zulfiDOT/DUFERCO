import { api, LightningElement } from 'lwc';

export default class AccountForm extends LightningElement {
    @api objectName;
    @api recordTypeChild;
    accountId;

   handleSuccess(event) {
       this.accountId = event.detail.id;
   }
   @api
   handleSubmit() {
    console.log('Sono nel child');
    this.template.querySelector('lightning-record-edit-form').submit();
}
}