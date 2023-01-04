/**
 * @HandlerClass: ContactTriggerHandler
 * @TestClass: ContractServiceTests
*/
trigger ContactTrigger on Contact (before insert, before update,after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            Util_OpenCaseForChangeField.createFieldChange(Trigger.oldMap, Trigger.new);
        }
    } else if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            ContactTriggerHandler.syncWithDatamax(Trigger.new);
        }
    }

}