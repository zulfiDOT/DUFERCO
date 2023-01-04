/*
 *   @Class  :   KoineApiController
 *   @TestClass: KoineApiControllerTest
*/
global class KoineApiControllerMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        KoineApiController.Response response = new KoineApiController.Response();
        response.ExternalKey = 'https://invoicelink.test';
        response.ResponseMessage = 'ok';
        response.ResponseCode = '200';
        response.X_Correlation_id = 'correlationid';
        response.TimeStamp = 'timestamp';
        res.setBody('Test Response');
        res.setStatusCode(200);
        if (req.getMethod() == 'GET') {
            res.setBody(JSON.serialize(response));
        }
        return res;
    }
}