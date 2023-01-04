@isTest
public with sharing class WizardSetupUtility_Test {
    @isTest
    public static void queryAccountBeforeInsert_Test() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acct = new Account(Name = 'test');
        acct.RecordTypeId = recordTypeId;
        insert acct;

        Map<String,Object> result = WizardSetupUtility.queryAccountBeforeInsert('Id != null');
        result = WizardSetupUtility.queryAccountBeforeInsert('Id =: \"'+acct.Id+'\"');

    }
}