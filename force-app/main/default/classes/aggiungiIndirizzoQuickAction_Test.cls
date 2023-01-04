/*
 *   @Class  :   aggiungiBillingProfileQA_Controller
*/
@isTest
public with sharing class aggiungiIndirizzoQuickAction_Test {
    @testSetup
    public static void setup() {

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        insert quote;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.AccountId = acc.Id;
        Insert c;

    }

    @isTest
    public static void fetchDataTest() {

        String quoteId = [Select id from SBQQ__Quote__c LIMIT 1].Id;
        Test.startTest();
        List<Account> accList = aggiungiIndirizzoQuickAction_Controller.fetchData(quoteId);
        Test.stopTest();

        System.assert(!accList.isEmpty());

    }
}