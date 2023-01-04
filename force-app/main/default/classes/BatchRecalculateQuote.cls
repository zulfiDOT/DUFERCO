public class BatchRecalculateQuote implements Database.Batchable<sObject>{
    
    public set<id> QuotePadreSet;
     public BatchRecalculateQuote(set<id> Input){
         this.QuotePadreSet = Input;
    }
    
    public Database.Querylocator start(Database.BatchableContext bc){
        Set<String> accountId = new Set<String>();
        String query = 'Select Id,SBQQ__Account__c, Re_calculate_Quote__c From SBQQ__Quote__c Where id in :QuotePadreSet';
        List<SBQQ__Quote__c> tempList = Database.query(query);
        for(SBQQ__Quote__c item : tempList){
            accountId.add(item.SBQQ__Account__c);
        }
        String finalQuery = 'Select Id ,(Select Id,SBQQ__Account__c, Re_calculate_Quote__c From Quotes__r Where id in :QuotePadreSet) From Account Where Id IN: accountId';

        return Database.getQuerylocator(finalQuery);
    } 
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        System.debug('scope:::' + scope);
        List<SBQQ__Quote__c> udateList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listQuote = new List<SBQQ__Quote__c>();
        listQuote = scope[0].Quotes__r;
        for(SBQQ__Quote__c sbq : listQuote){
            sbq.Re_calculate_Quote__c = !sbq.Re_calculate_Quote__c;
            udateList.add(sbq);
        }
        update udateList;
    }
    
    public void finish(Database.BatchableContext bc){}
}