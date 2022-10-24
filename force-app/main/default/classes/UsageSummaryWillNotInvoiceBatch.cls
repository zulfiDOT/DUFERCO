public class UsageSummaryWillNotInvoiceBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM blng__UsageSummary__c '+
            'WHERE blng__NextBillingDate__c < today AND blng__Status__c = \'Queued For Invoice\' AND '+
            'blng__InvoiceRunProcessingStatus__c = \'Pending Billing\' AND (blng__Subtotal__c = null OR blng__Subtotal__c = 0) AND '+
            '(blng__PreratedAmount__c = null OR blng__PreratedAmount__c = 0)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<blng__UsageSummary__c> scope) {
        for(blng__UsageSummary__c us : scope) {
            us.blng__InvoiceRunProcessingStatus__c = 'Will Not Invoice';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {

    }
    
}