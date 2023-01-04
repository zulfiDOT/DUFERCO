/*
 * @Trigger : AccountTrigger
 * @TestClass: ContractServiceTests
*/
public class AccountTriggerHandler {
    
    public static void syncWithDatamax(List<Account> triggerNew) {
        if(MulesoftApiController.isActive('UpsertAccount')) {
            MulesoftApiController.lockTriggers = true;
            Set<Id> accountIdsToSend = new Set<Id>();
            Set<Id> accountIdsToSend2 = new Set<Id>();
            List<Account> removeSync = new List<Account>();
            for(Account acc : triggerNew) {
                if(!acc.LockSync__c && acc.RecordType.DeveloperName != 'Partner') {
                    if(accountIdsToSend.size()<100) {
                        accountIdsToSend.add(acc.Id);
                    } else if(accountIdsToSend.size()>=100) {
                        accountIdsToSend2.add(acc.Id);
                    }
                } else if (acc.LockSync__c) {
                    removeSync.add(new Account(Id = acc.Id, LockSync__c = false));
                }
            }
            if(accountIdsToSend != null && accountIdsToSend.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend);
            if(accountIdsToSend2 != null && accountIdsToSend2.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend2);
            if(removeSync != null && removeSync.size() > 0) update removeSync;
        }
    }

}