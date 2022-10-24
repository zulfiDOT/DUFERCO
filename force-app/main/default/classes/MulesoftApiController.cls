global class MulesoftApiController {
    
  public static Boolean lockTriggers = false;

  @AuraEnabled(cacheable=true)
  public static String retrieveAccount(Map<String,String> accParams) {

    HttpRequest req = new HttpRequest();
    //String url = 'http://mule-worker-duferco-salesforce-exp-api.de-c1.eu1.cloudhub.io:8081/api/RetrieveAccount';
    //String username = 'salesforce_usr';
    //String password = '$O5p!5EAjs%3'; 
    String url = MulesoftApi__c.getValues('RetrieveAccount').End_Point__c;
    url += '?'+buildParams(accParams);
    String username = MulesoftApi__c.getValues('RetrieveAccount').Username__c;
    String password = MulesoftApi__c.getValues('RetrieveAccount').Password__c;

    req.setEndpoint(url);
    req.setMethod('GET');
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'Basic ' +
    EncodingUtil.base64Encode(headerValue);
    req.setHeader('Authorization', authorizationHeader); 
    req.setTimeout(120000);
    Http http = new Http();
    System.debug('Request : '+req);

    HTTPResponse res = http.send(req);
    System.debug('Response : '+res);
    System.debug(res.getBody());
    return res.getBody();
  }

  /*public static String upsertAccount(Map<String,String> accParams) {

    HttpRequest req = new HttpRequest();

    String url = MulesoftApi__c.getValues('UpsertAccount').End_Point__c;
    String username = MulesoftApi__c.getValues('UpsertAccount').Username__c;
    String password = MulesoftApi__c.getValues('UpsertAccount').Password__c;
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'Basic ' +
    EncodingUtil.base64Encode(headerValue);
    req.setHeader('Authorization', authorizationHeader);
    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setBody(JSON.serialize(accParams));
    req.setTimeout(120000);
    Http http = new Http();
    System.debug('Request : '+req);

    HTTPResponse res = http.send(req);
    System.debug('Response : '+res);
    System.debug(res.getBody());
    return res.getBody();
  }*/

  @InvocableMethod(label='Upsert Account in Datamax' description='Invocazione asincrona del metodo Mulesoft per eseguire un upsert anagrafica in Mulesoft')
  public static List<Response> upsertAccount(List<Request> requests) {

    Response r = new Response();
    if(requests == null || requests.size() == 0) {
      r.code = 400;
      r.message = 'Request is empty';
      return new List<Response>{r};
    }

    HttpRequest req = new HttpRequest();

    String url = MulesoftApi__c.getValues('UpsertAccount').End_Point__c;
    String username = MulesoftApi__c.getValues('UpsertAccount').Username__c;
    String password = MulesoftApi__c.getValues('UpsertAccount').Password__c;
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'Basic ' +
    EncodingUtil.base64Encode(headerValue);
    req.setHeader('Authorization', authorizationHeader);
    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
    req.setEndpoint(url);
    req.setMethod('POST');
    System.debug('BODY --> '+JSON.serialize(requests[0].acc,true));
    req.setBody(JSON.serialize(requests[0].acc,true));
    req.setTimeout(120000);
    Http http = new Http();
    System.debug('Request : '+req);

    HTTPResponse res = http.send(req);
    System.debug('Response : '+res);
    System.debug(res.getBody());
    
    r.code = res.getStatusCode();
    if(r.code == 200) {
      r.acc = (DmxAccount)JSON.deserialize(res.getBody(), DmxAccount.class);
      r.cnt = r.acc.contacts != null && r.acc.contacts.size()>0 ? r.acc.contacts[0] : null;
      r.adr = r.acc.addresses != null && r.acc.addresses.size()>0 ? r.acc.addresses[0] : null;
    } else {
      r.message = res.getBody();
    }
    return new List<Response>{r};
  }

  global class Request {
    @InvocableVariable
    global DmxAccount acc;
  }
  global class Response {
    @InvocableVariable
    global Integer code;
    @InvocableVariable
    global String message;
    @InvocableVariable
    global DmxAccount acc;
    @InvocableVariable
    global DmxContact cnt;
    @InvocableVariable
    global DmxAddress adr;
  }

  public static String buildParams(Map<String,String> params) {
    
    String input='';
    for (String par : params.keySet()) {
      
      if (params.get(par) != null && params.get(par) != '') {
        input += input != '' ? '&'+par +'='+params.get(par) : par +'='+params.get(par);
        //input += par +'='+params.get(par);
      }
    }
    System.debug('Input '+input);
    return input;
  }

  public static Boolean isActive(String apiName) {
    MulesoftApi__c mapi = MulesoftApi__c.getValues(apiName);
    Boolean disabled = mapi==null?false:mapi.Disabled__c;
    return !lockTriggers && !disabled;
  }

}