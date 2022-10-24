/*
 *   @TestClass : InvoiceManagementBatchTest
*/
public class InvoiceManagementBatch implements Database.Batchable<sObject> {
    
    public String invoiceRunId;

    public InvoiceManagementBatch(String invoiceRunId) {
        this.invoiceRunId = invoiceRunId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT BillingProfile__c, BillingProfile__r.PaymentConditions__c, blng__InvoiceDate__c, Progressivo_fattura__c, '+
                                        'InvoiceLineCount__c, blng__Order__c '+
                                        'FROM blng__Invoice__c '+
                                        'WHERE blng__InvoiceRunCreatedBy__c = :invoiceRunId');
    }

    public void execute(Database.BatchableContext context, List<blng__Invoice__c> scope) {
        InvoiceTriggerHandler.setDueDate(scope);
        InvoiceTriggerHandler.setCustomAutonumber(scope);
        //InvoiceManagementBatchHandler.EngineLinesScontoAndRitenuta(scope);
    }

    public void finish(Database.BatchableContext context) {
    }

}