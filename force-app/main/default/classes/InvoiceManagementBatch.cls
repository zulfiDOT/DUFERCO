/*
 *   @TestClass: InvoiceManagementBatchTest
*/
public class InvoiceManagementBatch implements Database.Batchable<sObject> {
    
    public String invoiceRunId;

    public InvoiceManagementBatch(String invoiceRunId) {
        this.invoiceRunId = invoiceRunId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, BillingProfile__c, blng__Account__c, BillingProfile__r.PaymentConditions__c, BillingProfile__r.PaymentMethod__r.blng__PaymentType__c, MinInvoiceLineStartDate__c, '+
                                        'MaxInvoiceLineEndDate__c, Progressivo_fattura__c, blng__InvoiceDate__c, InvoiceLineCount__c, blng__Order__c, '+
                                        'blng__TotalAmount__c, blng__Account__r.FormaAnagrafica__c, blng__Account__r.Nation__c, '+
                                        'blng__Account__r.RecordType.DeveloperName, blng__Account__r.AccountRegion__c, blng__InvoiceStatus__c, '+
                                        '( SELECT Id, blng__Subtotal__c, blng__TaxAmount__c, blng__TotalAmount__c, blng__TaxPercentageApplied__c FROM blng__InvoiceInvoiceLines__r ), '+
                                        '(Select Id, blng__Amount__c From blng__Payments__r) '+
                                        'FROM blng__Invoice__c '+
                                        'WHERE blng__InvoiceRunCreatedBy__c = :invoiceRunId');
    }

    public void execute(Database.BatchableContext context, List<blng__Invoice__c> scope) {
        system.debug('scope:'+ scope);
        InvoiceManagementBatchHandler.setPeriodoFatturazione(scope);
        InvoiceTriggerHandler.setDueDate(scope);
        //InvoiceTriggerHandler.setCustomAutonumber(scope);
        InvoiceManagementBatchHandler.EngineLinesScontoAndRitenuta(scope);
        InvoiceTriggerHandler.setCastellettoIva(scope);

        List<Id> invoiceIds = new List<Id>();
        for(blng__Invoice__c inv : scope)
            invoiceIds.add(inv.Id);
        InvoiceManagementBatchHandler.controlloDelleFatture(invoiceIds);
    }

    public void finish(Database.BatchableContext context) {
    }

}