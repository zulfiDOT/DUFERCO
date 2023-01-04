@isTest
public with sharing class MyCallback_Test {
    @isTest
    public static void MyCallback_Test() {
        String json = '{"saver": "SBQQ.QuoteAPI.QuoteSaver", "model": "{\"record\":{\"attributes\":{\"type\":\"SBQQ__Quote__c\",\"url\":\"/services/data/v41.0/sobjects/SBQQ__Quote__c/a0l61000003kUlVAAU\"},\"Name\":\"Q-00681\",\"Id\":\"a0l61000003kUlVAAU\"},\"nextKey\":2,\"netTotal\":0.00,\"lineItems\":[],\"lineItemGroups\":[],\"customerTotal\":0.00}"}';
        MyCallback call = new MyCallback();
        call.callback(json);
    }
}