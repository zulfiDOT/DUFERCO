/*
 *   @Class: MulesoftApiController
 *   @TestClass: MulesoftApiControllerTest
*/
global class MulesoftApiControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        DmxAccount acc = new DmxAccount();
        acc.account_name = 'Test';
        MulesoftApiController.Response response = new MulesoftApiController.Response();
        response.acc = acc;
        res.setBody('Test Response');
        res.setStatusCode(200);
        if (req.getMethod() == 'POST') {
            res.setBody(JSON.serialize(response));
        }
        return res;
    }
}