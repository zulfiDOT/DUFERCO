/*
 *   @Class  :   MulesoftApiController
 *   @MockClass  :   MulesoftApiControllerMock
*/

@isTest
public class MulesoftApiControllerTest {

    @TestSetup
    static void makeData(){
        MulesoftApi__c retrieveAcc = new MulesoftApi__c();
        retrieveAcc.Username__c = 'Test';
        retrieveAcc.Password__c = 'PSW';
        retrieveAcc.End_Point__c = 'http://example.com/example/retrieve';
        retrieveAcc.Name = 'RetrieveAccount';
        insert retrieveAcc;

        MulesoftApi__c upsertAcc = new MulesoftApi__c();
        upsertAcc.Username__c = 'Test';
        upsertAcc.Password__c = 'PSW';
        upsertAcc.End_Point__c = 'http://example.com/example/upsert';
        upsertAcc.Name = 'UpsertAccount';
        insert upsertAcc;

    }

    
    @isTest static void retrieveAccountTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MulesoftApiControllerMock());
        Map<String,String> params = new Map<String,String>();
        params.put('Test', 'Test');
        String result = MulesoftApiController.retrieveAccount(params);

        Test.stopTest();
    }

    /*@isTest static void upsertAccountTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MulesoftApiControllerMock());
        Map<String,String> params = new Map<String,String>();
        params.put('Test', 'Test');
        String result = MulesoftApiController.upsertAccount(params);

        Test.stopTest();
    }*/

    @isTest static void upsertAccountFlowTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MulesoftApiControllerMock());
        DmxAccount acc = new DmxAccount();
        acc.account_name = 'Test';
        MulesoftApiController.Request req = new MulesoftApiController.Request();
        req.acc = acc;
        List<MulesoftApiController.Request> reqList = new List<MulesoftApiController.Request>();
        reqList.add(req);

        
        List<MulesoftApiController.Response> result = MulesoftApiController.upsertAccount(reqList);

    }


}