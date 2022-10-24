@istest
public with sharing class ResetAssetValueBatchTest {

    @testSetup
    public static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        MulesoftApi__c upsertCard = new MulesoftApi__c();
        upsertCard.Username__c = 'Test';
        upsertCard.Password__c = 'PSW';
        upsertCard.End_Point__c = 'http://example.com/example/UpsertCard';
        upsertCard.Disabled__c = false;
        upsertCard.Name = 'UpsertCard';
        insert upsertCard;
    }
    @IsTest
    static void methodName(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpsertCardApiControllerMock());

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Asset a = new Asset();
        a.Name = 'test';
        a.kWhConsumatiMese__c = 250;
        a.AccountId = acc.Id;
        insert a;

        SchedulableContext sc = null;
        ResetAssetValueBatchScheduleClass ravc = new ResetAssetValueBatchScheduleClass();
        ravc.execute(sc);
        Test.stopTest();
        
    }
}