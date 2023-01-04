/*
 *   @Class: IdentityServerApiController
 *   @TestClass: IdentityServerApiControllerMockTest
*/
global class IdentityServerApiControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        IdentityServerApiController.Response response = new IdentityServerApiController.Response();
        response.code = 200;
        response.message = 'OK';
        res.setBody(JSON.serialize(response));
        res.setStatusCode(200);
        if (req.getMethod() == 'POST') {
            res.setBody(JSON.serialize(response));
        }
        return res;
    }
}