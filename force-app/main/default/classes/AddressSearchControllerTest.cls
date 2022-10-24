/*
 *   @Class  :   AddressSearchController
 *   @MockClass  :   AddressSearchControllerMock
*/

@isTest
public with sharing class AddressSearchControllerTest {

    @TestSetup
    static void makeData(){
        GoogleApi__c autocomplete = new GoogleApi__c();
        autocomplete.Key__c = '0000';
        autocomplete.End_Point__c = 'http://example.com/example/autocomplete';
        autocomplete.Name = 'Autocomplete';

        insert autocomplete;

        GoogleApi__c details = new GoogleApi__c();
        details.Key__c = '0000';
        details.End_Point__c = 'http://example.com/example/details';
        details.Name = 'Details';
        
        insert details;

    }


    @isTest static void placeSearchTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressSearchControllerMock());

        List<LookupSearchResult> results = AddressSearchController.placeSearch('Via Roma');

        Test.stopTest();
    }

    @isTest static void getAddressComponentTest() {
        // Set mock callout class 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressSearchControllerMock());

        String result = AddressSearchController.getAddressComponent('00000000');

        Test.stopTest();
    }
}