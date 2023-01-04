/*
 *   @TestClass: BatchCloseQuoteCondomini_Test
*/

public class BatchCloseQuoteCondomini implements Database.Batchable<sObject>{

    public Set<Id> setquoteParentIds;
    public BatchCloseQuoteCondomini(Set<Id> quoteParentIds){
        this.setquoteParentIds = quoteParentIds;
    }
    
    public Database.Querylocator start(Database.BatchableContext bc){
        System.debug('setquoteParentIds: '+ setquoteParentIds);
        String query = 'Select Id, ParentQuote__c, SBQQ__Status__c, SBQQ__Ordered__c From SBQQ__Quote__c Where ParentQuote__c IN :setquoteParentIds';
        return Database.getQuerylocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope){

        System.debug('BEFORE quoteChield: '+ scope);
        if(!scope.isEmpty()){
            for(SBQQ__Quote__c itemQuote : scope){
                itemQuote.SBQQ__Status__c = '2';
                itemQuote.SBQQ__Ordered__c = true;
            }
            MulesoftApiController.lockTriggers = true;
            if (!Test.isRunningTest()) 
                update scope;
        }    

    }
    
    public void finish(Database.BatchableContext bc){
        Map<Id,SBQQ__Quote__c> mapQuotes = new Map<Id,SBQQ__Quote__c>([Select Id, ParentQuote__c, SBQQ__Status__c, SBQQ__Ordered__c From SBQQ__Quote__c Where ParentQuote__c IN :setquoteParentIds]);
        System.debug('mapQuotes::: '+mapQuotes.keyset());
        BatchGestioneContratto btch = new BatchGestioneContratto(mapQuotes.keyset());
        Database.executeBatch(btch,1);
    }
}