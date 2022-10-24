/*
 *   @Class  :   NexiPaymentApiController
 *   @MockClass  :   NexiPaymentApiControllerMock
*/

@isTest
public class NexiPaymentApiControllerTest {

    @TestSetup
    static void makeData(){
        MulesoftApi__c createPayByLink = new MulesoftApi__c();
        createPayByLink.Username__c = 'Test';
        createPayByLink.Password__c = 'PSW';
        createPayByLink.End_Point__c = 'http://example.com/example/CreatePayByLink';
        createPayByLink.Name = 'CreatePayByLink';
        insert createPayByLink;

        MulesoftApi__c upsertAcc = new MulesoftApi__c();
        upsertAcc.Username__c = 'Test';
        upsertAcc.Password__c = 'PSW';
        upsertAcc.End_Point__c = 'http://example.com/example/CreateUser';
        upsertAcc.Name = 'CreateUser';
        insert upsertAcc;

    }

    @isTest static void createPayByLinkTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NexiPaymentApiControllerMock());
        
        NexiPaymentApiController.Request req = new NexiPaymentApiController.Request();
        req.calloutName = 'CreatePayByLink';
        req.method = 'POST';
        List<CalloutFlowParameter> flowParamList = new List<CalloutFlowParameter>();
        CalloutFlowParameter flowParam = new CalloutFlowParameter();
        flowParam.fieldName = 'Username';
        flowParam.fieldValue = 'test@test.com';
        flowParamList.add(flowParam);
        req.getParams = flowParamList;

        List<NexiPaymentApiController.Request> reqList = new List<NexiPaymentApiController.Request>();
        reqList.add(req);
        
        List<NexiPaymentApiController.Response> result = NexiPaymentApiController.makeCallout(reqList);

    }

    @isTest static void buildParamsGETTest() {

        List<CalloutFlowParameter> flowParamList = new List<CalloutFlowParameter>();
        CalloutFlowParameter flowParam = new CalloutFlowParameter();
        flowParam.fieldName = 'Username';
        flowParam.fieldValue = 'test@test.com';
        flowParamList.add(flowParam);
        String result = NexiPaymentApiController.buildParamsGET(flowParamList);
    }
}