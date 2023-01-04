/*
 *   @TestClass: OrderItemTriggerHandlerTest
*/
trigger OrderItemTrigger on OrderItem (before insert, before update,after insert, after update) {
    
    if(Trigger.isBefore){

    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            OrderItemTriggerHandler.createWorkOrder(trigger.new);
        }
    }

}