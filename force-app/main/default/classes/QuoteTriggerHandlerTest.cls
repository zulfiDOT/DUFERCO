@isTest
private class QuoteTriggerHandlerTest {
	
    @testSetup
    static void loadData(){
        List<sObject> Accounts = Test.loadData(Account.SObjectType,'AccountsToLoadTestClass');
        //List<sObject> PersonAccounts = Test.loadData(Account.SObjectType,'PersonAccountsToLoadTestClass');
        List<sObject> Promotions = Test.loadData(Promotion__c.SObjectType,'PromoToLoadTestClass');
        List<sObject> Quotes = Test.loadData(SBQQ__Quote__c.SObjectType,'QuotesToLoadTestClass');
    }
    
    @isTest
    static void ManageQuotesForTest() {
        
        List<SBQQ__Quote__c> QuoteToUpdate = new List<SBQQ__Quote__c>();
        List<Account> AccountToUpdate = new List<Account>();
        List<Contact> ContactToCreate = new List<Contact>();
        Account account;
        Contact contact;
        Schema.RecordTypeInfo recordTypeInfo = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount');
        String recordTypeIdAccount = recordTypeInfo.getRecordTypeId();
        String recordTypeId = [select Id, DeveloperName  from RecordType where  SobjectType = 'SBQQ__Quote__c' and DeveloperName  = 'EfficienzaEnergetica' LIMIT 1].id;
        for(SBQQ__Quote__c quote : [Select id,SBQQ__Account__r.name,Cadastral_Category__c, Promotion_Code__c,SBQQ__Status__c, Intended_General_Use__c,TaxableSignificantAsset__c,TaxableThirdPartyComponentsAndLabour__c, SBQQ__Account__c,SBQQ__Account__r.isPersonAccount,Promo_Code_Validation__c from SBQQ__Quote__c]){
         if(string.isNotBlank(quote.Promotion_Code__c))  quote.Promotion_Code__c='';
              else  quote.Promotion_Code__c='testerr';
            account = new Account(id = quote.SBQQ__Account__c,  recordTypeId = recordTypeIdAccount); 
            contact = new contact(FirstName =quote.SBQQ__Account__r.name,LastName = quote.SBQQ__Account__r.name,accountId = quote.SBQQ__Account__c,email = 'asd@live.it.test');
            system.debug('ispersonaccount: '+ quote.SBQQ__Account__r.isPersonAccount); 
            quote.SBQQ__Status__c = '8';
            quote.Intended_General_Use__c = 'Residenziale';
            quote.RecordTypeId = recordTypeId;
            //quote.TaxableSignificantAsset__c = 10000;
            //quote.TaxableThirdPartyComponentsAndLabour__c = 100;
            QuoteToUpdate.add(quote);
            AccountToUpdate.add(account);
            ContactToCreate.add(contact);
        }
        Database.insert(ContactToCreate);
        Database.update(AccountToUpdate);
        for(Account acc : AccountToUpdate){
            acc.Email__c = 'test@test.it';
            acc.Phone = '3333333333';
            acc.Phone2__c = '3333333333';
        }
        Database.update(AccountToUpdate);
        Database.update(QuoteToUpdate);
    }
}