/*
 * @HandlerClass : AssetTriggerHandler
*/
trigger AssetTrigger on Asset (after insert, after update) {

    if(Trigger.isInsert) {
        AssetTriggerHandler.syncWithMobilityInsert(Trigger.new);
    } else {
        AssetTriggerHandler.syncWithMobilityUpdate(Trigger.new, Trigger.oldMap);
    }

}