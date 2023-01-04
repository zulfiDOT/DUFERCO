/*
 *   @TestClass: ContractServiceTests
*/
global  class Batch_AccountContactRelation_Insert implements Database.Batchable<sObject>,Database.stateful {
    global static Boolean isRunTrigger = true;
    global  Set<Id> accountParentIds = new Set<Id>();
    global  Batch_AccountContactRelation_Insert(Set<Id> accountParentIds) {
        this.accountParentIds = accountParentIds;
    }
    global  Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id,Name,ParentId '+
                                        'FROM Account '+
                                        'WHERE ParentId  IN :accountParentIds');
    }

    global  void execute(Database.BatchableContext context, List<Account> scope) {
        system.debug('scope:'+ scope);
        system.debug('accountParentIds:'+ accountParentIds);
        isRunTrigger = false;
        Map<String,AccountContactRelation> mapAccIdAcr =  new Map<String,AccountContactRelation>();
        List<AccountContactRelation>  acrListToCreate = new List<AccountContactRelation> ();
        List<AccountContactRelation> acrList =  [SELECT id,Account.Name,Account.ParentId,Contact.LastName,ContactId,Roles 
                                                 FROM AccountContactRelation 
                                                 WHERE AccountId IN :accountParentIds];
        system.debug('acrList:'+ acrList.size());
        system.debug('acrList:'+ acrList);
        for(AccountContactRelation acr : acrList){
            mapAccIdAcr.put(acr.AccountId, acr);
        }
        system.debug('mapAccIdAcr:'+ mapAccIdAcr);
        for(Account acc : scope){
            system.debug('mapAccIdAcr.containskey(acc.ParentId):'+ mapAccIdAcr.containskey(acc.ParentId));
            if(!String.isBlank(acc.ParentId) && mapAccIdAcr.containskey(acc.ParentId)){
                AccountContactRelation  acr = new AccountContactRelation ();
                acr.AccountId = acc.Id;
                acr.ContactId = mapAccIdAcr.get(acc.ParentId).ContactId;
                acr.Roles  = mapAccIdAcr.get(acc.ParentId).Roles; 
                acrListToCreate.add(acr);
            }
        }
        system.debug('acrListToCreate:'+ acrListToCreate);
        if(!acrListToCreate.isEmpty()){
            Database.SaveResult[] srList = Database.insert(acrListToCreate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }

    global  void finish(Database.BatchableContext context) {
    }


}