/*
 *   @TestClass: WorkOrderTriggerHandlerTest
*/
public with sharing class WorkOrderTriggerHandler {
    
    public static void assignToBoQueue (List<WorkOrder> triggerNew, Map<Id, WorkOrder> triggerOldMap) {
        List<QueueSobject> queues = [SELECT Id, QueueId FROM QueueSobject WHERE Queue.DeveloperName = 'Back_Office' LIMIT 1];
        for(WorkOrder wo : triggerNew) {
            if(triggerOldMap.get(wo.Id).Status == 'In attesa logo' && wo.Status == 'Logo caricato' && queues != null && queues.size() > 0) {
                wo.OwnerId = queues[0].QueueId;
            }
        }
    }

}