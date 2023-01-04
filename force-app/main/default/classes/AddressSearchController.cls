/*
 *   @TestClass: AddressSearchControllerTest
 *   @MockClass  :   AddressSearchControllerMock
*/
public with sharing class AddressSearchController {

  @AuraEnabled(cacheable=true)
  public static List<LookupSearchResult> placeSearch(String searchPhrase) {
    System.debug('#### Called! ' + searchPhrase);
    String url = getURL('Autocomplete');
      //'https://maps.googleapis.com/maps/api/place/autocomplete/json?' +
    url +=  'input=' +
      EncodingUtil.urlEncode(searchPhrase, 'UTF-8') +
      '&types=geocode' + '&language=it' +
      getKey('Autocomplete');
      
    list<LookupSearchResult> results = new List<LookupSearchResult>();

    List<PlaceFinder.Address> sugg = getPlaceId(url);
    for (PlaceFinder.Address s : sugg) {
      results.add(
        new LookupSearchResult(
          s.placeId,
          '',
          'utility:checkin',
          s.description,
          ''
        )
      );
    }
    return results;
  }

  public static List<PlaceFinder.Address> getPlaceId(string strURL) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    req.setMethod('GET');
    req.setEndpoint(strURL);
    req.setTimeout(120000);
    res = h.send(req);
    String responseBody = res.getBody();
    System.debug('Response Debug '+responseBody);
    List<PlaceFinder.Address> aList = PlaceFinder.parse(responseBody);
    // for (PlaceFinder.Address a : aList) {
    //   System.debug('@@@' + a);
    // }
    return aList;
  }

  @AuraEnabled
  public static String getAddressComponent(String placeId){

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    //String strURL = 'https://maps.googleapis.com/maps/api/place/details/json?'  +
    String strURL = getURL('Details');
    strURL += '&place_id='+placeId + '&fields=address_component' +
    '&language=it' +
    getKey('Details');

    req.setMethod('GET');
    req.setEndpoint(strURL);
    req.setTimeout(120000);
    res = h.send(req);

    System.debug('Response '+res.getBody());
    return res.getBody();

  }

  public static string getKey(String serviceName) {

    //string key = 'AIzaSyCzuOQzsZKCtwxnn98qfDM4OR-9OHbwtjc';
    string key = GoogleApi__c.getValues(serviceName).Key__c;
    string output = '&key=' + key;
    return output;
  }

  public static string getURL(String serviceName) {
    
    return GoogleApi__c.getValues(serviceName).End_Point__c;
  }
}