/*
 *   @TestClass: Batch_AccountContactRelation_InsertTest
*/
public class AccountContactRelationTriggerHandler {
    
    public static void handleAfterUpdate(Map<Id,AccountContactRelation> triggerNewMap,Map<Id,AccountContactRelation> triggerOldMap){
        Set<Id> accountParentIds =  new Set<Id>();
        for(AccountContactRelation acr : triggerNewMap.values() ){
            if(acr.isDirect && !String.isBlank(acr.Roles) && acr.Roles == 'RL'){
                System.debug('acr.AccountId::: '+ acr.AccountId);
                accountParentIds.add(acr.AccountId);
            }
        }
        
        if(!accountParentIds.isEmpty()){
            //System.debug('accountParentIds::: '+ accountParentIds);
            //Batch_AccountContactRelation_Insert batch = new Batch_AccountContactRelation_Insert(accountParentIds);
            //Database.executeBatch(batch);
            AsyncQueueable createRelation = new AsyncQueueable(accountParentIds);
            ID jobcreateEvent = System.enqueueJob(createRelation);
        }
        
    }

    public class AsyncQueueable implements Queueable {
        Set<Id> listIdAccountParent = new Set<Id>();
        List<Account> listAccount = new List<Account>();
        public AsyncQueueable(Set<Id> parentAccountIds){
            this.listIdAccountParent = parentAccountIds;
            listAccount = [SELECT Id,Name,ParentId FROM Account WHERE ParentId  IN: listIdAccountParent];
        }
        public void execute(QueueableContext context) {
            if(!listIdAccountParent.isEmpty()){
                Map<String,AccountContactRelation> mapAccIdAcr =  new Map<String,AccountContactRelation>();
                List<AccountContactRelation>  acrListToCreate = new List<AccountContactRelation> ();
                List<AccountContactRelation> acrList =  [SELECT id,Account.Name,Account.ParentId,Contact.LastName,ContactId,Roles FROM AccountContactRelation WHERE AccountId IN :listIdAccountParent];

                for(AccountContactRelation acr : acrList){
                    mapAccIdAcr.put(acr.AccountId, acr);
                }

                System.debug('listAccount::: ' + listAccount);
                System.debug('listAccountSIZE::: ' + listAccount.size());
                System.debug('listIdAccountParent::: ' + listIdAccountParent);
                System.debug('listIdAccountParentSIZE::: ' + listIdAccountParent.size());
                if(listAccount != null && listAccount.size() > 0){
                    for(Account acc : listAccount){
                        if(!String.isBlank(acc.ParentId) && mapAccIdAcr.containskey(acc.ParentId)){
                            AccountContactRelation  acr = new AccountContactRelation ();
                            acr.AccountId = acc.Id;
                            acr.ContactId = mapAccIdAcr.get(acc.ParentId).ContactId;
                            acr.Roles  = mapAccIdAcr.get(acc.ParentId).Roles;
                            acrListToCreate.add(acr); 
                            listIdAccountParent.remove(acc.ParentId);
                        }
                    }
                    if(!acrListToCreate.isEmpty()){
                        Database.SaveResult[] srList = Database.insert(acrListToCreate, false);
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            }
                            else {              
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                    System.debug('listIdAccountParentSIZE::: ' + listIdAccountParent.size());
                    if((listIdAccountParent.size() > 0)){
                        AsyncQueueable createRelation = new AsyncQueueable(listIdAccountParent);
                        ID jobcreateEvent = System.enqueueJob(createRelation);
                    }
                }  
            }        
        }
    }
}