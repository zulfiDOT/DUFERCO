/**
 * @TestClass: CreditNoteLineTriggerHandlerTest
 */
trigger CreditNoteLineTrigger on blng__CreditNoteLine__c (before insert, before update,after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CreditNoteLineTriggerHandler.setProgressivo(Trigger.new);
            CreditNoteLineTriggerHandler.updateCreditNoteLineNumber(Trigger.new);
            CreditNoteLineTriggerHandler.resetExportStatus(Trigger.new);
        }
       /* else if(Trigger.isUpdate){
            CreditNoteLineTriggerHandler.resetExportStatus(Trigger.new);
        }*/
    }        

}