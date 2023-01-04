/*
 *   @Class  :   RecordTypeSelector
*/
@isTest
public with sharing class RecordTypeSelectorTest {
   
    @TestSetup
    static void makeData(){

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recordTypeId;
        insert acc;
    }

    @isTest public static void getFieldSetTest() {

        List<String> results = RecordTypeSelector.getFieldSet('Persona Fisica');
    }

    @isTest public static void queryRecordsTest() {

        List<Object> results = RecordTypeSelector.queryRecords('Select Id From Account');
    }

    @isTest public static void queryAccountBeforeInsertTest() {


        Map<String,Object> results = RecordTypeSelector.queryAccountBeforeInsert('Id != Null');
    }

    
    @isTest public static void fetchRecordTypeValuesTest() {


        Map<Id, String> results = RecordTypeSelector.fetchRecordTypeValues('Account');
    }
}