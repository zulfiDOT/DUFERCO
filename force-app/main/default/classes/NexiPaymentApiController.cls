/*
 *   @TestClass  :   NexiPaymentApiControllerTest
 *   @MockClass  :   NexiPaymentApiControllerMock
*/

global class NexiPaymentApiController {

  @InvocableMethod(label='HTTP REQUEST' description='Invocazione di una chiamata Api verso Nexi')
  public static List<Response> makeCallout(List<Request> request) {

    System.debug('REQUEST --> '+request.get(0));
    Response r = new Response();
    if(request == null || request.size() == 0) {
      r.ResponseCode = '400';
      r.ResponseMessage = 'Request is empty';
      return new List<Response>{r};
    }

    HttpRequest req = new HttpRequest();

    String url = MulesoftApi__c.getValues(request.get(0).calloutName).End_Point__c;
    if (request.get(0).method.equalsIgnoreCase('GET')) {
      url += '?'+buildParamsGET(request.get(0).getParams);
    }
    String username = MulesoftApi__c.getValues(request.get(0).calloutName).Username__c;
    String password = MulesoftApi__c.getValues(request.get(0).calloutName).Password__c;
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'Basic ' +
    EncodingUtil.base64Encode(headerValue);
    System.debug('## Header '+authorizationHeader);
    req.setHeader('Authorization', authorizationHeader);
    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
    req.setEndpoint(url);
    req.setMethod(request.get(0).method);
    if (request.get(0).method.equalsIgnoreCase('POST')) {
      req.setBody(Json.serialize(request.get(0).nexiParams,true));
    }
    req.setTimeout(120000);
    Http http = new Http();
    System.debug('Request : '+req);

    HTTPResponse res = http.send(req);
    System.debug('Response : '+res);
    System.debug(res.getBody());
  
    if (request.get(0).calloutName == 'OrderDetails' && res.getStatusCode() == 200 ) {
       r.nexiOrderDetailsResponse = (NexiPaymentResponse)JSON.deserialize(res.getBody(), NexiPaymentResponse.class);
       r.report = r.nexiOrderDetailsResponse.transaction_report != null && r.nexiOrderDetailsResponse.transaction_report.size() > 0 ? r.nexiOrderDetailsResponse.transaction_report[0] : null;
       r.dettaglio = r.report.transaction_dettaglio;
       r.operazioni = r.dettaglio.transaction_operazioni != null && r.dettaglio.transaction_operazioni.size() > 0  ? r.dettaglio.transaction_operazioni[0] : null;
    }else {
      r = (NexiPaymentApiController.Response)JSON.deserialize(res.getBody(), NexiPaymentApiController.Response.class);
    }
    return new List<Response>{r};
  }

  global class Request {
    @InvocableVariable
    global String method;
    @InvocableVariable
    global String calloutName;
    @InvocableVariable
    global NexiPaymentParams nexiParams;
    @InvocableVariable
    global List<CalloutFlowParameter> getParams;
  }
  global class Response {

    @InvocableVariable
    global NexiPaymentResponse nexiOrderDetailsResponse;
    @InvocableVariable
    global cls_transaction_report report;
    @InvocableVariable
    global cls_transaction_dettaglio dettaglio;
    @InvocableVariable
    global cls_transaction_operazioni operazioni;

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

  public static String buildParamsGET(List<CalloutFlowParameter> params) {
    
    String input='';
    System.debug('PARAMS --> '+params);
    for (CalloutFlowParameter par : params) {
      
      if (par.fieldName != null && par.fieldName != '') {
        input += input != '' ? '&'+par.fieldName +'='+par.fieldValue : par.fieldName +'='+par.fieldValue;
      }
    }
    System.debug('Input '+input);
    return input;
  }
}