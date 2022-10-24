trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
            ContentDocumentLinkTriggerHandler.makeProductDocumentVisible(Trigger.new);

        }
    }

}