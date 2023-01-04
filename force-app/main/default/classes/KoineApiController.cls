/*
 *   @TestClass: KoineApiControllerTest
 *   @MockClass: KoineApiControllerMock
*/
global class KoineApiController {
    
    @InvocableMethod(label='Retrieve Doc File' description='Invocazione asincrona del metodo Mulesoft per recuperare il link al PDF fattura su Koinè')
    public static List<Response> retrieveDocFile(List<Request> requests) {

        Response r = new Response();
        if(requests == null || requests.size() == 0) {
            r.ResponseCode = '400';
            r.ResponseMessage = 'Request is empty';
            return new List<Response>{r};
        }

        HttpRequest req = new HttpRequest();
        String url = MulesoftApi__c.getValues('RetrieveDocFile').End_Point__c;
        String username = MulesoftApi__c.getValues('RetrieveDocFile').Username__c;
        String password = MulesoftApi__c.getValues('RetrieveDocFile').Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

		req.setHeader('Content-Type','application/json;charset=UTF-8');
        //System.debug('HEADER --> '+JSON.serialize(requests[0],true));
        //req.setHeader('docNumber', requests[0].docNumber);
        url = url + '?docNumber=' + requests[0].docNumber+'&invoiceSezionale=' + requests[0].invoiceSezionale;
        req.setEndpoint(url);
        req.setMethod('GET');
       // reqBody.docNumber = requests[0].docNumber;
        //System.debug('BODY --> '+JSON.serialize(reqBody,true));
        //req.setBody(JSON.serialize(reqBody,true));
        req.setTimeout(120000);
        Http http = new Http();
        System.debug('Request : '+req);

        HTTPResponse res = http.send(req);
        System.debug('Response : '+res);
        System.debug(res.getBody());
        r = (Response)JSON.deserialize(res.getBody(), Response.class);
        return new List<Response>{r};
    }
  
    global class Request {
        @InvocableVariable
        global String docNumber;
        @InvocableVariable
        global String invoiceSezionale;
    }
    global class Response {
        @InvocableVariable
        global String ExternalKey;
        @InvocableVariable
        global String ResponseMessage;
        @InvocableVariable
        global String ResponseCode;
        @InvocableVariable
        global String X_Correlation_id;
        @InvocableVariable
        global String TimeStamp;
    }
  
}