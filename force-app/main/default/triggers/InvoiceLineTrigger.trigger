trigger InvoiceLineTrigger on blng__InvoiceLine__c (before insert, before update,after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            InvoiceLineTriggerHandler.setProgressivo(Trigger.new);
            InvoiceLineTriggerHandler.updateInvoiceLineNumber(Trigger.new);
        }
    }
}