/**
 * @HandlerClass: AccountTriggerHandler
 * @TestClass: ContractServiceTests
*/
trigger AccountTrigger on Account (before insert, before update,after insert, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            Util_OpenCaseForChangeField.createFieldChange(Trigger.oldMap, Trigger.new);
        }
    } else if(Trigger.isAfter) {
        List<Account> updateIndividualList = new List<Account>();
        Set<String> individualAccount = new Set<String>();
        if(Trigger.isUpdate) {
            AccountTriggerHandler.syncWithDatamax(Trigger.new);

            String typeAccountCheck = '';
            for(Account itemAccount : Trigger.new){
                if((itemAccount.PrivacyCommerciale__c != Trigger.oldMap.get(itemAccount.Id).PrivacyCommerciale__c) || (itemAccount.PrivacyProfilazioneConsumo__c != Trigger.oldMap.get(itemAccount.Id).PrivacyProfilazioneConsumo__c)){
                    updateIndividualList.add(itemAccount);
                    if(itemAccount.IsPersonAccount)
                        typeAccountCheck = 'Person';
                    else{
                        individualAccount.add(itemAccount.Id);
                        typeAccountCheck = 'Business'; 
                    } 
                }    
            }
            System.debug('updateIndividualList::: ' + updateIndividualList);
            if(updateIndividualList.size() > 0){
                if(typeAccountCheck == 'Person')
                    IndividualManageClass.manageTrigger(updateIndividualList, 'Account');
                else{
                    Map<String,AccountContactRelation> mapContact = new Map<String,AccountContactRelation>([Select Id From AccountContactRelation Where AccountId IN: individualAccount And Roles = 'RL']);
                    List<String> individualAccountList = new List<String>();
                    individualAccountList.addAll(mapContact.keyset());
                    IndividualManageClass.manageTrigger(individualAccountList, 'Contact');
                }
   
            }
                
        }
        if(Trigger.isInsert) 
            for(Account itemAccount : Trigger.new){
                if(itemAccount.IsPersonAccount)
                    updateIndividualList.add(itemAccount);
            }
            if(updateIndividualList.size() > 0)
                IndividualManageClass.manageTrigger(updateIndividualList, 'Account');
    }

}