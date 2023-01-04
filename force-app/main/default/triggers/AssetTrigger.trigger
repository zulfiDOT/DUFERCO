/**
 * @HandlerClass: AssetTriggerHandler
 * @TestClass: AssetTriggerHandlerTest
*/
trigger AssetTrigger on Asset (after insert, after update) {

    if(Trigger.isInsert) {
        AssetTriggerHandler.syncWithMobilityInsert(Trigger.new);
    } else {
        if(!System.isBatch() && !System.isFuture()) {
            AssetTriggerHandler.syncWithMobilityUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

}