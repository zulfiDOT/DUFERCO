@istest
public with sharing class BillingProfileTriggerTest {

    @istest
    public static void BillingProfileTriggerTest() {

        
        Account acc = new Account();
        acc.Name = 'Test Account amministratore';
        acc.Tipologia_Parent_Account__c='Amministratore di condominio';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        insert acc;

        blng__PaymentMethod__c payment = new blng__PaymentMethod__c();
        payment.blng__PaymentType__c = '1';
        payment.blng__Account__c = acc.Id;
        insert payment;

        CustomAutonumber__c numeromandatobaslab = new CustomAutonumber__c(Name = 'Numero Mandato' , ProgressiveNumber__c = 1 , Total_Length__c = 8, Prefix__c = 'ADT');
        insert numeromandatobaslab;
        CustomAutonumber__c numeromandatomob = new CustomAutonumber__c(Name = 'Numero Mandato Baslab' , ProgressiveNumber__c = 1 , Total_Length__c = 8, Prefix__c = 'MOB');
        insert numeromandatomob;

        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '100';
        billing.AccountId__c = acc.Id;
        billing.PaymentMethod__c = payment.id;
        billing.Company__c = '1';
        insert billing;

        BillingProfile__c billing2 = new BillingProfile__c();
        billing2.PaymentConditions__c = '100';
        billing2.AccountId__c = acc.Id;
        billing2.PaymentMethod__c = payment.id;
        billing2.Company__c = '8';
        insert billing2;


    }
}