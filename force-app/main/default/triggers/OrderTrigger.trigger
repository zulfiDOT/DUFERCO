/*
 *   @TestClass: OrderItemTriggerHandlerTest
*/
trigger OrderTrigger on Order (after insert) {
    for(Order itemOrder : Trigger.new){
        system.debug('order company: '+itemOrder.company__c);
    }
    OrderTriggerHandler.createNotes(Trigger.new);
}