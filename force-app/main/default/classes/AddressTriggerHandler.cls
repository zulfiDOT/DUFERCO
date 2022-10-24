/*
 * @TestClass : AddressTriggerHandlerTest
 * @Trigger : AddressTrigger
*/
public with sharing class AddressTriggerHandler {

    // metodo per filtrare gli indirizzi da cui deve partire la creazione di un case
    public static void addressFilter(Map<Id, Address__c> oldMap, List<Address__c> newList) {
        List<Address__c> addressListFiltered = new List<Address__c>();
        for (Address__c ad : newList) {
            if (ad.Type__c != null && ad.Type__c != '1' && ad.Type__c != '2' && ad.Type__c != '4') {
                addressListFiltered.add(ad);
            }
        }

        if (!addressListFiltered.isEmpty()) {
            Util_OpenCaseForChangeField.createFieldChange(oldMap, addressListFiltered);
        }
    }

    public static void preventAddressDeletion(List<Address__c> adList) {

        for (Address__c ad : adList) {
            if (ad.DefaultAddress__c && ad.IsActive__c) {
                
                ad.addError('Non è Possibile Eliminare un Indirizzo di Default');
            }
        }
        
    }

    public static void syncWithDatamax(List<Address__c> triggerNew) {
        if(MulesoftApiController.isActive('UpsertAccount')) {
            MulesoftApiController.lockTriggers = true;
            Set<Id> accountIdsToSend = new Set<Id>();
            Set<Id> accountIdsToSend2 = new Set<Id>();
            List<Address__c> removeSync = new List<Address__c>();
            for(Address__c adr : triggerNew) {
                if(!adr.LockSync__c && adr.AccountId__c != null && (adr.Type__c == '8' || adr.Type__c == '9')) {
                    if(accountIdsToSend.size()<100) {
                        accountIdsToSend.add(adr.AccountId__c);
                    } else if(accountIdsToSend.size()>=100) {
                        accountIdsToSend2.add(adr.AccountId__c);
                    }
                } else if (adr.LockSync__c) {
                    removeSync.add(new Address__c(Id = adr.Id, LockSync__c = false));
                }
            }
            if(accountIdsToSend != null && accountIdsToSend.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend);
            if(accountIdsToSend2 != null && accountIdsToSend2.size() > 0) DmxIntegrationHandler.syncWithDatamax(accountIdsToSend2);
            if(removeSync != null && removeSync.size() > 0) update removeSync;
        }
    }

}