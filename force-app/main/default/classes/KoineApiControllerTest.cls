/*
 *   @Class  :   KoineApiController
 *   @MockClass  :   KoineApiControllerMock
*/
@isTest
public class KoineApiControllerTest {

    @TestSetup
    static void makeData(){
        MulesoftApi__c retrieveAcc = new MulesoftApi__c();
        retrieveAcc.Username__c = 'Test';
        retrieveAcc.Password__c = 'PSW';
        retrieveAcc.End_Point__c = 'http://example.com/example/retrieve';
        retrieveAcc.Name = 'RetrieveDocFile';
        insert retrieveAcc;
    }
    
    @isTest static void retrieveDocFile() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new KoineApiControllerMock());
        KoineApiController.Request request = new KoineApiController.Request();
        request.docNumber = 'numero_documento';
        List<KoineApiController.Response> response = KoineApiController.retrieveDocFile(new List<KoineApiController.Request>{request});
        Test.stopTest();
    }

}