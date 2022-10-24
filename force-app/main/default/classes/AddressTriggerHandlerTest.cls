/*
 *   @Class  :   AddressTriggerHandler
*/
@istest
public with sharing class AddressTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Address__c address = new Address__c();
        address.Type__c = '1';
        address.AccountId__c = acc.Id;
        address.DefaultAddress__c = false;
        address.IsActive__c = false;
        insert address;
    }

    @isTest
    public static void addressFilterTest() {

        Address__c ad = [Select Id, Type__c, AccountId__c From Address__c Limit 1];
        
        Test.startTest();
        ad.Type__c = '8';
        update ad;
        Test.stopTest();
    }

    @isTest
    public static void preventAddressDeletionTest() {

        Address__c ad = [Select Id, Type__c, AccountId__c, DefaultAddress__c, IsActive__c From Address__c Limit 1];
        
        Test.startTest();
        delete ad;
        Test.stopTest();
    }
}