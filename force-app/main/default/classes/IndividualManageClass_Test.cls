/*
 *   @Class: IndividualManageClass
*/
@istest
public with sharing class IndividualManageClass_Test {
    @IsTest
    public static void IndividualManageClassMethod1() {
        Account accountTest1 = DataFactory.create_PersonAccount();
        insert accountTest1;
        Account accountTest2 = DataFactory.create_BusinessAccount();
        insert accountTest2;
        Contact contactTest1 = DataFactory.create_Contact(accountTest2.Id);
        insert contactTest1;
        accountTest1.PrivacyCommerciale__c = false;
        update accountTest1;
        Opportunity opportunityTest = DataFactory.create_Opportunity(accountTest1.Id);
        insert opportunityTest;
        SBQQ__Quote__c quoteTest = DataFactory.create_Quote(accountTest1.Id, opportunityTest.Id);
        insert quoteTest;
        quoteTest.SBQQ__Status__c = '3';
        update quoteTest;

    }

}