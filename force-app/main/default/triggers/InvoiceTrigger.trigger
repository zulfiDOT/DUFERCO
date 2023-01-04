/*
 *   @TestClass: InvoiceLineTriggerTest
*/
trigger InvoiceTrigger on blng__Invoice__c (before insert, before update,after insert, after update) {

    if(Trigger.isAfter){

        /*if (Trigger.isInsert) {
            InvoiceTriggerHandler.setCustomAutonumber(Trigger.new);
        }*/

        if(Trigger.isUpdate){
            InvoiceTriggerHandler.setInvoiceOnPayment(Trigger.new);
            //InvoiceTriggerHandler.setCustomAutonumber(Trigger.new);
            if(InvoiceAfterPostingLogicsBatch.isRunTrigger)
                InvoiceTriggerHandler.setCustomAutonumberForStatusPosted(Trigger.new,Trigger.OldMap);
        }
    }else{
        if (Trigger.isInsert) {
            InvoiceTriggerHandler.setDocumentId(Trigger.new);
        }  
    }
}