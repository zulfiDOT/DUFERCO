/*
 *   @TestClass: BatchCloseQuoteCondomini_Test
*/

public class BatchGestioneContratto implements Database.Batchable<sObject>{

    public Set<Id> setQuoteIds;
    public BatchGestioneContratto(Set<Id> quoteIds){
         this.setQuoteIds = quoteIds;
    }
    
    public Database.Querylocator start(Database.BatchableContext bc){
        System.debug('setQuoteIds::: '+ setQuoteIds);
        String query = 'Select Id, Status, SBQQ__Contracted__c, SBQQ__Quote__c From Order Where SBQQ__Quote__c IN :setQuoteIds';
        return Database.getQuerylocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<Order> scope){

        System.debug('BEFORE Order: '+ scope);
        if(!scope.isEmpty()){
            for(Order itemOrder : scope){
                itemOrder.Status= 'Activated';
                itemOrder.SBQQ__Contracted__c = true;
            }
            update scope;
        } 
        System.debug('AFTER Order:: '+ scope);   

    }
    
    public void finish(Database.BatchableContext bc){}
}