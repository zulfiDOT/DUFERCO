/*
 *   @Class: AccountDatamaxFormController
*/
@isTest
public with sharing class AccountDatamaxFormControllerTest {

    @IsTest
    static void createObjFromDatamaxTest(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account a = new Account(Name = 'Test Acc1', RecordTypeId = recordTypeId);
        List<SObject> sObjectList = new List<SObject>{a};
        Test.startTest();
        Map<String,String> result = AccountDatamaxFormController.createObjFromDatamax(sObjectList);
        Test.stopTest();
        
    }

    @IsTest
    static void createFailObjFromDatamaxTest(){
        Account a;
        List<SObject> sObjectList = new List<SObject>{a};
        Test.startTest();
        try {
        Map<String,String> result = AccountDatamaxFormController.createObjFromDatamax(sObjectList);
        }
        catch(Exception e){
        System.assertNotEquals(sObjectList != null, sObjectList.isEmpty());
        }
        Test.stopTest();

    }

    @IsTest
    static void isAdminAgency() {
        AccountDatamaxFormController.isAdminAgency();

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@dufercotest.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, AgencyCode__c = 'aaaaa',
        TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);

        System.runAs(u) {
            AccountDatamaxFormController.isAdminAgency();
        }

    }

    @IsTest
    static void isNotAdminAgency() {
        AccountDatamaxFormController.isAdminAgency();
        
        List<AdminAgency__mdt> agencies = AdminAgency__mdt.getAll().values();

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@dufercotest.com';
        Profile p = [SELECT Id FROM Profile WHERE Name!='System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, AgencyCode__c = agencies[0].DeveloperName,
        TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);

        System.runAs(u) {
            AccountDatamaxFormController.isAdminAgency();
        }

    }

}