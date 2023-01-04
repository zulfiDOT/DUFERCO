/**
 * @TestClass: CreditNoteLineTriggerHandlerTest
 */
trigger CreditNoteTrigger on blng__CreditNote__c (before insert, before update,after insert, after update) {
    

    if(Trigger.isBefore){

        if (Trigger.isInsert) {
            CreditNoteTriggerHandler.setDocumentId(Trigger.new);
            CreditNoteTriggerHandler.setCustomAutonumber(Trigger.new);
            CreditNoteTriggerHandler.resetStatusKoine(Trigger.new);
            
        }

        if(Trigger.isUpdate){
            
            CreditNoteTriggerHandler.setCustomAutonumber(Trigger.new);
    

        }
    }

}