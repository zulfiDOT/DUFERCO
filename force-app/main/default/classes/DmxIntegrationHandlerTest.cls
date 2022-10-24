/*
 *   @Class  :   DmxIntegrationHandler
*/
@isTest
public class DmxIntegrationHandlerTest {
    
    @TestSetup
    static void makeData(){
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
    
    @isTest static void insertAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MulesoftApiControllerMock());

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business' AND IsActive = true AND SobjectType = 'Account'];

        Account acc = new Account( Name = 'Test', RecordTypeId = rt.Id );
        insert acc;

        Contact cnt = new Contact( FirstName = 'Nome', LastName = 'Cognome', AccountId = acc.Id );
        insert cnt;

        AccountContactRelation acr = [SELECT Id FROM AccountContactRelation WHERE AccountId = :acc.Id AND ContactId = :cnt.Id];
        acr.Roles = 'RL';
        update acr;

        MulesoftApiController.lockTriggers = false;
        Address__c adr = new Address__c( AccountId__c = acc.Id, Type__c = '9' );
        insert adr;

        MulesoftApiController.lockTriggers = false;
        update acc;
        MulesoftApiController.lockTriggers = false;
        update cnt;
        
        Test.stopTest();
    }

}