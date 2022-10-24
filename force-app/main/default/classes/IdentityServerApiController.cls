/*
 *   @TestClass  :   IdentityServerApiControllerTest
 *   @MockClass  :   IdentityServerApiControllerMock
*/

global class IdentityServerApiController {

  @InvocableMethod(label='HTTP REQUEST' description='Invocazione di una chiamata Api verso l\' Identity Server')
  public static List<Response> makeCallout(List<Request> request) {

    System.debug('REQUEST --> '+request.get(0));
    Response r = new Response();
    if(request == null || request.size() == 0) {
      r.code = 400;
      r.message = 'Request is empty';
      return new List<Response>{r};
    }

    HttpRequest req = new HttpRequest();

    String url = MulesoftApi__c.getValues(request.get(0).calloutName).End_Point__c;
    if (request.get(0).method.equalsIgnoreCase('GET')) {
      url += '?'+buildParamsGET(request.get(0).params);
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
      req.setBody(Json.serialize(request.get(0).serializedParams,true));
    }
    req.setTimeout(120000);
    Http http = new Http();
    System.debug('Request : '+req);

    HTTPResponse res = http.send(req);
    System.debug('Response : '+res);
    System.debug(res.getBody());
    r = (IdentityServerApiController.Response)JSON.deserialize(res.getBody(), IdentityServerApiController.Response.class);
    r.code = res.getStatusCode();
    return new List<Response>{r};
  }

  global class Request {
    @InvocableVariable
    global String method;
    @InvocableVariable
    global String calloutName;
    @InvocableVariable
    global List<CalloutFlowParameter> params;
    @InvocableVariable
    global IdentityServerParams serializedParams;
  }
  global class Response {
    @InvocableVariable
    global Integer code;
    @InvocableVariable
    global String message;
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
    @InvocableVariable
    global String idSub;
    @InvocableVariable
    global String idMobility;

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

  public static Map<String,String> buildParamsPOST(List<CalloutFlowParameter> params) {
    
    Map<String, String> paramsMap = new Map<String, String>();
    System.debug('PARAMS --> '+params);
    for (CalloutFlowParameter par : params) {
      if ((par.fieldName != null && par.fieldName != '') && (par.fieldValue != null && par.fieldValue != '')) {
        paramsMap.put(par.fieldName, par.fieldValue);
      }
    }
    System.debug('Input '+paramsMap);
    return paramsMap;
  }
}