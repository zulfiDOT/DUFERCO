/*
 *   @Author : Carmine Romano
 *   @TestClass  :   Util_OpenCaseForChangeFieldTest
*/
@isTest
public with sharing class Util_OpenCaseForChangeFieldTest {
    
    @testSetup
    public static void setup() {

        Account acc = new Account();
        acc.Name = 'Test-Account';
        acc.DatamaxCustomerCode__c = '1234';
        acc.FiscalCode__c = 'my-fiscal-code';
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testus', Email='testuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, IntegrationUser__c = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorgduferco.com');
        insert u;

        MulesoftApi__c retrieveAcc = new MulesoftApi__c();
        retrieveAcc.Username__c = 'Test';
        retrieveAcc.Password__c = 'PSW';
        retrieveAcc.End_Point__c = 'http://example.com/example/retrieve';
        retrieveAcc.Disabled__c = false;
        retrieveAcc.Name = 'RetrieveAccount';
        insert retrieveAcc;

        MulesoftApi__c upsertAcc = new MulesoftApi__c();
        upsertAcc.Username__c = 'Test';
        upsertAcc.Password__c = 'PSW';
        upsertAcc.End_Point__c = 'http://example.com/example/upsert';
        upsertAcc.Disabled__c = false;
        upsertAcc.Name = 'UpsertAccount';
        insert upsertAcc;
    }

    @isTest
    public static void createFieldChangeTest() {

        User u = [SELECT Id,IntegrationUser__c   FROM User WHERE IntegrationUser__c = true Limit 1  ];
        Account accToUpdate = [Select Id, FiscalCode__c From Account LIMIT 1];
        String oldValue = accToUpdate.FiscalCode__c;
        accToUpdate.FiscalCode__c = 'my-updated-fs-';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MulesoftApiControllerMock());
            System.runAs(u) {
                update accToUpdate;      
            }
        Test.stopTest();
        List<FieldChange__c> fcList = [Select Id From FieldChange__c];

        System.assert(!fcList.isEmpty());
    }
}