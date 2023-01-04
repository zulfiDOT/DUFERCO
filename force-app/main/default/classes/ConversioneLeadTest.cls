/*
 *   @Class  :   ConversioneLead
*/
@isTest
 public with sharing class ConversioneLeadTest 
{
    @TestSetup
    static void testsetup()
    {
        settings__c sett = new Settings__c();
        insert sett;

        Lead sobj = new Lead(
            FirstName = 'eww',
            LastName = 'test',
            Company__c = '8',// Company
            Company = 'tre',
            Email = 'testff@ftest.it.ewe',   // Email
            FiscalCode__c = null,            // Codice Fiscale
            VatNumber__c = '10810700152',    // Partita IVA
            Nation__c = 'IT'            // Nazione
            );
        insert sobj;

        account sobj2 = new account(
            Name = 'eww',
            Company__c = '1',// Company
            Email__c = 'testff@ftest.it.ewe',   // Email
            FiscalCode__c = null,            // Codice Fiscale
            VatNumber__c = '10810700152',    // Partita IVA
            Nation__c = 'IT',            // Nazione
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId()
            );
        insert sobj2;
    }

    @IsTest
    static void testConversione()
    {
        lead lid = [select id, FirstName, LastName, Company, Company__c, Email, FiscalCode__c, VatNumber__c, Nation__c from lead limit 1];
        account acc = [select RecordTypeId, id from account limit 1];
        Test.startTest();
        ConversioneLead.getCustomSettings();
        ConversioneLead.GetLead(lid.id);
        ConversioneLead.CheckDataLead(lid);
        ConversioneLead.checkAccount(lid);
        lid.Status = 'To contact';
        update lid;
        lid.Status = 'Demo to do';
        update lid;
        lid.Status = 'Waiting for customer';
        update lid;
        lid.Status = 'Offer to do';
        update lid;
        ConversioneLead.ConvertLead(acc.id, lid);
        Test.stopTest();
    }
}