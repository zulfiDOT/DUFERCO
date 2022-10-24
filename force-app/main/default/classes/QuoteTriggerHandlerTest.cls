@isTest
private class QuoteTriggerHandlerTest {
	
    @testSetup
    static void loadData(){
        List<sObject> Accounts = Test.loadData(Account.SObjectType,'AccountsToLoadTestClass');
        List<sObject> Promotions = Test.loadData(Promotion__c.SObjectType,'PromoToLoadTestClass');
        List<sObject> Quotes = Test.loadData(SBQQ__Quote__c.SObjectType,'QuotesToLoadTestClass');
    }
    
    @isTest
    static void ManageQuotesForTest() {
        
        List<SBQQ__Quote__c> QuoteToUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : [Select id, Promotion_Code__c,SBQQ__Account__c,Promo_Code_Validation__c from SBQQ__Quote__c]){
         if(string.isNotBlank(quote.Promotion_Code__c))  quote.Promotion_Code__c='';
              else  quote.Promotion_Code__c='testerr';
            QuoteToUpdate.add(quote);
        }
        Database.update(QuoteToUpdate);
    }
}