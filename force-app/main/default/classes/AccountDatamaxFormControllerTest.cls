/*
 *   @Class  :   AccountDatamaxFormController
*/
@isTest
public with sharing class AccountDatamaxFormControllerTest {

    @IsTest
    static void createObjFromDatamaxTest(){
        
        Account a = new Account(Name = 'Test Acc1');
        List<SObject> sObjectList = new List<SObject>{a};
        Test.startTest();
        Map<String,String> result = AccountDatamaxFormController.createObjFromDatamax(sObjectList);
        Test.stopTest();
        
    }

    @IsTest
    static void isAdminAgency() {
        AccountDatamaxFormController.isAdminAgency();
        
        List<AdminAgency__mdt> agencies = AdminAgency__mdt.getAll().values();

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@dufercotest.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, AgencyCode__c = agencies[0].DeveloperName,
        TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);

        System.runAs(u) {
            AccountDatamaxFormController.isAdminAgency();
        }
    }

}