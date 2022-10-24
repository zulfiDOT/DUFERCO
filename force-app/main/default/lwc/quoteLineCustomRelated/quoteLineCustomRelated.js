import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchData from '@salesforce/apex/aggiungiBillingProfileQA_Controller.getQuoteLines';

export default class QuoteLineCustomRelated extends NavigationMixin(LightningElement) {
    @api recordId;
    quoteLines;

    @wire(fetchData, { quoteId : '$recordId'})
    wiredQuoteLines(result) {
        console.log('Id '+this.recordId);
        if (result.data) {
            
            this.quoteLines = result.data;

        } else if (result.error) {
            console.error(error);
        }
    }

    viewRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "SBQQ__QuoteLine__c",
                "actionName": "view"
            },
        });
    }
}