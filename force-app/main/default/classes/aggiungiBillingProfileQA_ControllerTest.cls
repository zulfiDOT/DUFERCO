/*
 *   @Class  :   aggiungiBillingProfileQA_ControllerTest
*/
@istest
public with sharing class aggiungiBillingProfileQA_ControllerTest {
    @testSetup
    public static void setup() {

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc.Id;
        insert quote;

        Address__c address = new Address__c();
        address.Type__c = '4';
        address.AccountId__c = acc.Id;
        insert address;

    }

    @isTest
    public static void getBillingRecordsTest() {

        String quoteId = [Select id from SBQQ__Quote__c LIMIT 1].Id;
        Test.startTest();
        List<Account> accList = aggiungiBillingProfileQA_Controller.getBillingRecords(quoteId);
        Test.stopTest();

        System.assert(!accList.isEmpty());

    }

    @isTest
    public static void getPaymentMethodTest() {

        String quoteId = [Select id from SBQQ__Quote__c LIMIT 1].Id;
        Test.startTest();
        List<Account> accList = aggiungiBillingProfileQA_Controller.getPaymentMethod(quoteId);
        Test.stopTest();

        System.assert(!accList.isEmpty());

    }

    @isTest
    public static void getQuoteLinesTest() {

        String quoteId = [Select id from SBQQ__Quote__c LIMIT 1].Id;
        Test.startTest();
        List<SBQQ__QuoteLine__c> lines = aggiungiBillingProfileQA_Controller.getQuoteLines(quoteId);
        Test.stopTest();


    }

    @isTest
    public static void addBillingProfileTest() {


        Account acc = [Select Name from Account Limit 1];
        Address__c address = [Select Id, Type__c, AccountId__c From Address__c Limit 1];
        Map<String, Object> billingParams = new Map<String, Object>();
        billingParams.put('address',address);

        blng__PaymentMethod__c payment = new blng__PaymentMethod__c();
        payment.blng__PaymentType__c = '2';
        payment.blng__Account__c = acc.Id;
        billingParams.put('payment', payment);

        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '100';
        billing.AccountId__c = acc.Id;
        billingParams.put('billing', billing);

        String quoteId = [Select id from SBQQ__Quote__c LIMIT 1].Id;
        Test.startTest();
        String result = aggiungiBillingProfileQA_Controller.addBillingProfile(billingParams, quoteId);
        Test.stopTest();

        System.assertEquals(result, 'OK');
    }
}