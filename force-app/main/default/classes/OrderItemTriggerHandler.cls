/*
 *   @TestClass: OrderItemTriggerHandlerTest
*/
public with sharing class OrderItemTriggerHandler {


    public static void createWorkOrder(List<OrderItem> orderItemList){
        Map<String,Map<String,List<WorkOrderLineItem>>> orderIdToWorkOrderItemTypeSplitted = new Map<String,Map<String,List<WorkOrderLineItem>>>();
        List<WorkOrder> woList = new List<WorkOrder>();
        Set<String> workOrderTypes = new Set<String>();

        for (OrderItem oItem : [Select id,ServiceDate,EndDate,Quantity,UnitPrice,PricebookEntryId,OrderId,Product2.NeedWorkOrder__c, Product2.Work_Order_Type__c From OrderItem where Id IN: orderItemList]) {
            System.debug('Need Work Order : '+oItem.Product2.NeedWorkOrder__c);
            if (oItem.Product2.NeedWorkOrder__c && oItem.Product2.Work_Order_Type__c != Null) {
                WorkOrderLineItem workItemTemp = new WorkOrderLineItem();
                    workItemTemp.StartDate = oItem.ServiceDate;
                    workItemTemp.EndDate = oItem.EndDate;
                    workItemTemp.Quantity = oItem.Quantity;
                    workItemTemp.UnitPrice = oItem.UnitPrice;
                    workItemTemp.PricebookEntryId = oItem.PricebookEntryId;
                    workItemTemp.OrderId = oItem.OrderId;
                
                if (!orderIdToWorkOrderItemTypeSplitted.containsKey(oItem.OrderId)) {
                    orderIdToWorkOrderItemTypeSplitted.put(oItem.OrderId, new Map<String,List<WorkOrderLineItem>>());
                }
                if (!orderIdToWorkOrderItemTypeSplitted.get(oItem.OrderId).containsKey(oItem.Product2.Work_Order_Type__c)) {
                    orderIdToWorkOrderItemTypeSplitted.get(oItem.OrderId).put(oItem.Product2.Work_Order_Type__c, new List<WorkOrderLineItem>());
                }
                orderIdToWorkOrderItemTypeSplitted.get(oItem.OrderId).get(oItem.Product2.Work_Order_Type__c).add(workItemTemp);
                workOrderTypes.add(oItem.Product2.Work_Order_Type__c);
            }
        }

        Map<String,Id> rtIdPerType = new Map<String,Id>();
        for(RecordType rt : [SELECT DeveloperName FROM RecordType WHERE SobjectType = 'WorkOrder' AND IsActive = true AND DeveloperName IN :workOrderTypes]) {
            rtIdPerType.put(rt.DeveloperName, rt.Id);
        }

        List<QueueSobject> queues = [SELECT Id, QueueId FROM QueueSobject WHERE Queue.DeveloperName = 'Back_Office' LIMIT 1];

        for (Order ord : [Select id,AccountId,Pricebook2Id,EffectiveDate, SBQQ__Quote__r.OwnerId, (Select Id, Subject  from Work_Orders__r) from Order where Id IN: orderIdToWorkOrderItemTypeSplitted.keySet()]) {

            if (ord.Work_Orders__r.isEmpty()) {
                for (String workOrderType : orderIdToWorkOrderItemTypeSplitted.get(ord.Id).keyset()) {
                    WorkOrder wo = new WorkOrder();
                    wo.AccountId = ord.AccountId;
                    wo.Pricebook2Id = ord.Pricebook2Id;
                    wo.StartDate = ord.EffectiveDate;
                    wo.Order__c = ord.Id;
                    wo.Subject = workOrderType;
                    wo.OwnerId = ord.SBQQ__Quote__r.OwnerId;

                    if(rtIdPerType.get(workOrderType) != null) {
                        wo.RecordTypeId = rtIdPerType.get(workOrderType);
                    }

                    if((workOrderType == 'Spedizione' || workOrderType == 'Garanzia') && queues != null && queues.size() > 0) {
                        wo.OwnerId = queues[0].QueueId;
                    }

                    woList.add(wo);
                }                        
            }
        }

        if (!woList.isEmpty()) {

            insert woList;
        }
        
        createWorkOrderLineItems(orderIdToWorkOrderItemTypeSplitted);
        
    }
    public static void createWorkOrderLineItems(Map<String,Map<String,List<WorkOrderLineItem>>> workOrderItemMap){
        List<WorkOrderLineItem> woItemToInsert = new List<WorkOrderLineItem>();

        for (WorkOrder woInserted : [SELECT Id, Order__c, Subject FROM WorkOrder where order__c IN: workOrderItemMap.keySet()]) {
            
            //for (String workOrderType : workOrderItemMap.get(woInserted.Order__c).keyset()) {

                for (WorkOrderLineItem woLineItem : workOrderItemMap.get(woInserted.Order__c).get(woInserted.Subject)) {

                    woLineItem.WorkOrderId = woInserted.Id;
                    woLineItem.Subject = woInserted.Subject;
                }
                
                woItemToInsert.addAll(workOrderItemMap.get(woInserted.Order__c).get(woInserted.Subject));

            //}
        }

        if (!woItemToInsert.isEmpty()) {
            insert woItemToInsert;
        }

    }
}