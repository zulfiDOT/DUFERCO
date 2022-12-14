/*
 *   @Class  :   NexiPaymentApiController
 *   @TestClass  :   NexiPaymentApiControllerTest
*/

global class NexiPaymentApiControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        NexiPaymentApiController.Response response = new NexiPaymentApiController.Response();
        response.ResponseCode = '200';
        response.ResponseMessage = 'OK';
        res.setBody(JSON.serialize(response));
        res.setStatusCode(200);
        if (req.getMethod() == 'POST') {
            res.setBody(JSON.serialize(response));
        }
        return res;
    }
}