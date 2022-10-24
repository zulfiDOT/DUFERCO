trigger UsageTrigger on blng__Usage__c (before insert, before update,after insert, after update) {

    PrintTimestamp.print(new List<List<String>> {new List<String>{'Trigger UsageTrigger', Trigger.operationType.name()}});
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //UsageTriggerHandler.createCustomUsageSummary(Trigger.new);
        }
    }
}