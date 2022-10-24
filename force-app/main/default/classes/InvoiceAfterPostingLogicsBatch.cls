//Lutech AT 06/09/2022 lanciato da Trigger InvoiceTrigger quando l’Invoice ha blng__Status__c = ‘Posted’.
global  class InvoiceAfterPostingLogicsBatch implements Database.Batchable<sObject>,Database.stateful {
    global static Boolean isRunTrigger = true;
    global  Set<Id> invoiceIds = new Set<Id>();
    global  InvoiceAfterPostingLogicsBatch(Set<Id> invoiceIds) {
        this.invoiceIds = invoiceIds;
    }
    
     global  Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT BillingProfile__c, BillingProfile__r.PaymentConditions__c,  Progressivo_fattura__c, blng__InvoiceStatus__c,blng__Order__c,'+
                                        'InvoiceLineCount__c, blng__Account__r.AccountRegion__c, blng__Account__r.RecordType.DeveloperName, blng__Account__r.FormaAnagrafica__c, blng__Account__r.Nation__c, blng__InvoiceDate__c '+
                                        'FROM blng__Invoice__c '+
                                        'WHERE Id IN :invoiceIds');
    }

    global  void execute(Database.BatchableContext context, List<blng__Invoice__c> scope) {
        system.debug('scope:'+ scope);
        isRunTrigger = false;
        InvoiceTriggerHandler.setCustomAutonumber(scope);
        
    }

    global  void finish(Database.BatchableContext context) {
    }

}