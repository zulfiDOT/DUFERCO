/*
 * @Trigger : ContactTrigger
*/
public class ContactTriggerHandler {
    
    public static void syncWithDatamax(List<Contact> triggerNew) {
        if(MulesoftApiController.isActive('UpsertAccount')) {
            MulesoftApiController.lockTriggers = true;
            Set<Id> accountIdsToSend = new Set<Id>();
            Set<Id> accountIdsToSend2 = new Set<Id>();
            List<Contact> removeSync = new List<Contact>();
            for(Contact cnt : triggerNew) {
                if(!cnt.LockSync__c && cnt.AccountId != null && !cnt.IsPersonAccount) {
                    if(accountIdsToSend.size()<100) {
                        accountIdsToSend.add(cnt.AccountId);
                    } else if(accountIdsToSend.size()>=100) {
                        accountIdsToSend2.add(cnt.AccountId);
                    }
                } else if (cnt.LockSync__c) {
                    removeSync.add(new Contact(Id = cnt.Id, LockSync__c = false));
                }
            }
            if(accountIdsToSend != null && accountIdsToSend.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend);
            if(accountIdsToSend2 != null && accountIdsToSend2.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend2);
            if(removeSync != null && removeSync.size() > 0) update removeSync;
        }
    }

}