@isTest
public with sharing class CustomAutonumberResetBatch_Test {
    @isTest
    public static void CustomAutonumber_Test() {

        CustomAutonumber__c lastProgr = new CustomAutonumber__c(Name = 'MO' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastProgr;

        Test.startTest();
        Database.executeBatch(new CustomAutonumberResetBatch());
        Test.stopTest();
    }
}