/*
 *   @Class  :   AssetTriggerHandler
*/
@istest
public class AssetTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        MulesoftApi__c upsertCard = new MulesoftApi__c();
        upsertCard.Username__c = 'Test';
        upsertCard.Password__c = 'PSW';
        upsertCard.End_Point__c = 'http://example.com/example/UpsertCard';
        upsertCard.Disabled__c = false;
        upsertCard.Name = 'UpsertCard';
        insert upsertCard;

        Account acc = new Account( Name = 'Test Account' );
        insert acc;
    }
    
    @isTest static void insertUpdateAsset() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpsertCardApiControllerMock());

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Asset a = new Asset( Name = 'card virtuale', AccountId = acc.Id, CardNumber__c = '1234567890' );
        insert a;

        a.LicencePlate__c = 'AA111AA';
        update a;
        Test.stopTest();
    }

}