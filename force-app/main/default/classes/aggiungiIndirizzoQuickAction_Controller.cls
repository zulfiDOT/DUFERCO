/*
 *   @TestClass: aggiungiIndirizzoQuickAction_Test
*/
public with sharing class aggiungiIndirizzoQuickAction_Controller {

    @AuraEnabled(cacheable=true)
    public static List<Account> fetchData(String quoteId) {
        
        List<Account> addressList = [Select id,(Select Country__c, Province__c, City__c,  StreetName__c, StreetNumber__c, ZipCode__c, AccountId__c, FirstName__c, LastName__c, Company__c, Note__c, DefaultAddress__c, toLabel(Type__c), Indirizzo_completo__c from Indirizzi__r order by CreatedDate DESC) 
                                        from account where id IN (Select SBQQ__Account__c from SBQQ__Quote__c where id =: quoteId)];

        return addressList;
    }
}