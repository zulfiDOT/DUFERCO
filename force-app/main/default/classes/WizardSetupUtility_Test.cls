@isTest
public with sharing class WizardSetupUtility_Test {
    @isTest
    public static void queryAccountBeforeInsert_Test() {
        Account acct = new Account(Name = 'test');
        insert acct;

        Map<String,Object> result = WizardSetupUtility.queryAccountBeforeInsert('Id != null');
        result = WizardSetupUtility.queryAccountBeforeInsert('Id =: \"'+acct.Id+'\"');

    }
}