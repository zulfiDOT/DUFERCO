/*
 *   @Class  :   IdentityServerApiController
 *   @MockClass  :   IdentityServerApiControllerMock
*/

@isTest
public class IdentityServerApiControllerTest {

    @TestSetup
    static void makeData(){
        MulesoftApi__c retrieveAcc = new MulesoftApi__c();
        retrieveAcc.Username__c = 'Test';
        retrieveAcc.Password__c = 'PSW';
        retrieveAcc.End_Point__c = 'http://example.com/example/VerifyUsername';
        retrieveAcc.Name = 'VerifyUsername';
        insert retrieveAcc;

        MulesoftApi__c upsertAcc = new MulesoftApi__c();
        upsertAcc.Username__c = 'Test';
        upsertAcc.Password__c = 'PSW';
        upsertAcc.End_Point__c = 'http://example.com/example/CreateUser';
        upsertAcc.Name = 'CreateUser';
        insert upsertAcc;

    }

    
    @isTest static void verifyUsernameTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdentityServerApiControllerMock());
        
        IdentityServerApiController.Request req = new IdentityServerApiController.Request();
        req.calloutName = 'VerifyUsername';
        req.method = 'GET';
        List<CalloutFlowParameter> flowParamList = new List<CalloutFlowParameter>();
        CalloutFlowParameter flowParam = new CalloutFlowParameter();
        flowParam.fieldName = 'Username';
        flowParam.fieldValue = 'test@test.com';
        flowParamList.add(flowParam);
        req.params = flowParamList;

        List<IdentityServerApiController.Request> reqList = new List<IdentityServerApiController.Request>();
        reqList.add(req);
        
        List<IdentityServerApiController.Response> result = IdentityServerApiController.makeCallout(reqList);

    }

    @isTest static void createUserTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdentityServerApiControllerMock());
        
        IdentityServerApiController.Request req = new IdentityServerApiController.Request();
        req.calloutName = 'CreateUser';
        req.method = 'POST';
        IdentityServerParams flowParam = new IdentityServerParams();
        flowParam.username = 'test@test.com';
        req.serializedParams = flowParam;

        List<IdentityServerApiController.Request> reqList = new List<IdentityServerApiController.Request>();
        reqList.add(req);
        
        List<IdentityServerApiController.Response> result = IdentityServerApiController.makeCallout(reqList);

    }

    @isTest static void buildParamsPOSTTest() {

        List<CalloutFlowParameter> flowParamList = new List<CalloutFlowParameter>();
        CalloutFlowParameter flowParam = new CalloutFlowParameter();
        flowParam.fieldName = 'Username';
        flowParam.fieldValue = 'test@test.com';
        flowParamList.add(flowParam);
        Map<String,String> result = IdentityServerApiController.buildParamsPOST(flowParamList);

    }
}