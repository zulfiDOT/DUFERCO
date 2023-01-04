/**
 * @TestClass: AttachmentBehaviorSettingsControllerTEST
 */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContentDocumentLinkTriggerHandler.makeProductDocumentVisible(Trigger.new);
        }
    } else if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            ContentDocumentLinkTriggerHandler.createNamirialEnvelope(Trigger.new);
        }
    }

}