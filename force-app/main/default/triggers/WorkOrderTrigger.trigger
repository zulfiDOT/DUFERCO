/*
 *   @TestClass: OrderItemTriggerHandlerTest
*/
trigger WorkOrderTrigger on WorkOrder (before update) {

    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            WorkOrderTriggerHandler.assignToBoQueue(Trigger.new, Trigger.oldMap);
        }
    }

}