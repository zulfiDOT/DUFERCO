/*
 *   @Class: UpsertCardApiController
 *   @MockClass: UpsertCardApiControllerMock
*/
@isTest
public class UpsertCardApiControllerTest {

    @TestSetup
    static void makeData(){
        MulesoftApi__c upsertCard = new MulesoftApi__c();
        upsertCard.Username__c = 'Test';
        upsertCard.Password__c = 'PSW';
        upsertCard.End_Point__c = 'http://example.com/example/UpsertCard';
        upsertCard.Name = 'UpsertCard';
        insert upsertCard;

    }

    @isTest static void upsertCardTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpsertCardApiControllerMock());
        
        UpsertCardApiController.Request req = new UpsertCardApiController.Request();
        req.calloutName = 'UpsertCard';
        req.method = 'POST';
        VIR_Tessere card = new VIR_Tessere();
        card.asset_cardnumber = '1234';
        req.card = card;

        List<UpsertCardApiController.Request> reqList = new List<UpsertCardApiController.Request>();
        reqList.add(req);
        
        List<UpsertCardApiController.Response> result = UpsertCardApiController.makeCallout(reqList);

    }

    @isTest static void buildParamsGETTest() {

        List<CalloutFlowParameter> flowParamList = new List<CalloutFlowParameter>();
        CalloutFlowParameter flowParam = new CalloutFlowParameter();
        flowParam.fieldName = 'Username';
        flowParam.fieldValue = 'test@test.com';
        flowParamList.add(flowParam);
        String result = UpsertCardApiController.buildParamsGET(flowParamList);
    }
}