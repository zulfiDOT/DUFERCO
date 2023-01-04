/*
 *   @TestClass: Batch_AccountContactRelation_InsertTest
*/
trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update) {
    List<String> individualAccount = new List<String>();
    for(AccountContactRelation itemRelation : Trigger.new){
        if((Trigger.isInsert && itemRelation.Roles == 'RL') || (Trigger.isUpdate && itemRelation.Roles != Trigger.oldMap.get(itemRelation.Id).Roles && itemRelation.Roles == 'RL'))
            individualAccount.add(itemRelation.Id);
    }
    if(!individualAccount.isEmpty() && individualAccount.size() > 0)
        IndividualManageClass.manageTrigger(individualAccount, 'Contact');


    if(Trigger.isUpdate){
        System.debug('Batch_AccountContactRelation_Insert.isRunTrigger::: '+ Batch_AccountContactRelation_Insert.isRunTrigger);
        if(Batch_AccountContactRelation_Insert.isRunTrigger){
            AccountContactRelationTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }   
}