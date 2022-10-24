/*
 * @HandlerClass : AccountTriggerHandler
*/
trigger AccountTrigger on Account (before insert, before update,after insert, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            Util_OpenCaseForChangeField.createFieldChange(Trigger.oldMap, Trigger.new);
        }
    } else if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            AccountTriggerHandler.syncWithDatamax(Trigger.new);
        }
    }

}