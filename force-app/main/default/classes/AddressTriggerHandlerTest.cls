/*
 *   @Class  :   AddressTriggerHandler
*/
@istest
public with sharing class AddressTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recordTypeId;
        // EDB 2022-08-04 @TEN - start
        Account acc1 = new Account();
        acc1.Name = 'Test Account amministratore';
        acc1.Tipologia_Parent_Account__c='Amministratore di condominio';
        acc1.RecordTypeId = recordTypeId;
        insert acc1;
        Account acc2 = new Account();
        acc2.Name = 'Test Account collegato';
        acc2.ParentId = acc1.Id;
        acc2.RecordTypeId = recordTypeId;
        // EDB 2022-08-04 @TEN - end
        //insert acc;
        insert new List<Account>{acc,acc2};

        Address__c address = new Address__c();
        address.Type__c = '1';
        address.AccountId__c = acc.Id;
        address.DefaultAddress__c = false;
        address.IsActive__c = false;
        // EDB 2022-08-04 @TEN - start
        Address__c address1 = new Address__c();
        address1.Type__c = '9';
        address1.AccountId__c = acc1.Id;
        address1.City__c = 'Miano';
        address1.ZipCode__c = '20100';
        address1.StreetName__c = 'Via Bolla';
        address1.StreetNumber__c = '20';
        address1.Country__c = 'Italia';
        address1.Province__c = 'MI';
        address1.DefaultAddress__c = true;
        address1.IsActive__c = true;
        
        Address__c address2 = new Address__c();
        address2.Type__c = '9';
        address2.AccountId__c = acc2.Id;
        address2.City__c = 'Miano';
        address2.ZipCode__c = '20100';
        address2.StreetName__c = 'Via Bolla';
        address2.StreetNumber__c = '20';
        address2.Country__c = 'Italia';
        address2.Province__c = 'MI';
        address2.DefaultAddress__c = true;
        address2.IsActive__c = true;
        // EDB 2022-08-04 @TEN - end 
        //insert address;
        insert new List<Address__c>{address,address1,address2};
    }

    @isTest
    public static void addressFilterTest() {

        Address__c ad = [Select Id, Type__c, AccountId__c From Address__c WHERE IsActive__c=false Limit 1];
        
        Test.startTest();
        ad.Type__c = '8';
        update ad;
        Test.stopTest();
    }

    @isTest
    public static void preventAddressDeletionTest() {

        Address__c ad = [Select Id, Type__c, AccountId__c, DefaultAddress__c, IsActive__c From Address__c WHERE IsActive__c=false Limit 1];
        
        Test.startTest();
        delete ad;
        Test.stopTest();
    }

    // EDB 2022-08-04 @TEN - start
    @isTest 
    public static void invokeUpdateAddress_Test() {
        Address__c ad = [Select Id, Type__c, AccountId__c,Tipologia_Parent_Account__c,City__c,ZipCode__c,StreetName__c,StreetNumber__c,Country__c,Province__c From Address__c WHERE Type__c='9' AND Tipologia_Parent_Account__c='Amministratore di condominio' Limit 1];
        ad.City__c = 'Roma';
        update ad;
        UpdateCustomerAddress batch = new UpdateCustomerAddress(new Map<Id,Address__c>{ad.AccountId__c=>ad});
        Database.executeBatch(batch);
    }
    // EDB 2022-08-04 @TEN - end
}