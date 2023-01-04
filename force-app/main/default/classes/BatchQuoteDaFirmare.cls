/**
 * @TestClass: BatchQuoteDaFirmareTest
 */
public class BatchQuoteDaFirmare implements Database.Batchable<sObject> {

    public Set<Id> parentQuoteIds;
    public BatchQuoteDaFirmare(Set<Id> parentQuoteIds) {
        this.parentQuoteIds = parentQuoteIds;
    }
    
    public Database.Querylocator start(Database.BatchableContext bc) {
        System.debug('parentQuoteIds='+parentQuoteIds);
        String query = 'SELECT ParentQuote__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE ParentQuote__c IN :parentQuoteIds';
        return Database.getQuerylocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope) {
        System.debug('scope='+scope);
        if(!scope.isEmpty()){
            for(SBQQ__Quote__c itemQuote : scope) {
                itemQuote.SBQQ__Status__c = '1';
                itemQuote.CompleteQuote__c = false;
                itemQuote.Print_Document__c = true;
            }
            MulesoftApiController.lockTriggers = true;
            update scope;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }

}