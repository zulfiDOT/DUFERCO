/**
 * @HanlderClass: AddressTriggerHanlder
 * @TestClass: AddressTriggerHandlerTest
*/
trigger AddressTrigger on Address__c (before insert, before update, after insert, after update, before delete) {

    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            AddressTriggerHandler.addressFilter(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isDelete) {
            AddressTriggerHandler.preventAddressDeletion(Trigger.old);
        }
    } else if (Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            AddressTriggerHandler.syncWithDatamax(Trigger.new);
        }
        //EDB 2022-08-04 @TEN -start
        if (Trigger.isUpdate) {
            AddressTriggerHandler.invokeUpdateCustomerAddress(trigger.new,Trigger.oldMap);
        }
        //EDB 2022-08-04 @TEN -end
    }

}