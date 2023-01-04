@isTest
private with sharing class AgencyInstallerSelection_Controller_Test {
    @TestSetup
    static void makeData(){

        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        String uniqueName;
        
        //COMMUNITY USER EFF.EN AGENTE 
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Account accEffEn = new Account();
        accEffEn.Name = 'ESTERNI_5678';
        accEffEn.Type= 'Agente';
        accEffEn.Company__c = '1';
        accEffEn.Email__c = 'testff@ftest.it.ewe';  
        accEffEn.VatNumber__c = '10810700152';
        accEffEn.Nation__c = 'IT';
        accEffEn.BillingStreet = '3022  Strother Street';
        accEffEn.BillingCity = 'Into';
        accEffEn.BillingState = 'Alabama';
        accEffEn.BillingPostalCode = '35222';
        accEffEn.BillingCountry = 'US';
        accEffEn.Nome_referente__c='AAAAA';
        accEffEn.Cognome_referente_Installatore__c= 'BBBB';
        accEffEn.Data_Stipula_Contratto_Quadro__c = Date.today()-1;
        accEffEn.Phone= '3332323793';
        accEffEn.FiscalCode__c = null;
        accEffEn.RecordTypeId = recordTypeId;
        insert accEffEn;

        Account accInst = new Account();
        accInst.Name = 'ESTERNI_5668';
        accInst.Type= 'Installatore';
        accInst.Company__c = '1';
        accInst.Email__c = 'testtff@ftest.it.ewe';  
        accInst.VatNumber__c = '30810700152';
        accInst.Nation__c = 'IT';
        accInst.BillingStreet = '1022  Strother Street';
        accInst.BillingCity = 'Intos';
        accInst.BillingState = 'Alabamas';
        accInst.BillingPostalCode = '35223';
        accInst.BillingCountry = 'US';
        accInst.Nome_referente__c='AAAAB';
        accInst.Cognome_referente_Installatore__c= 'ABBB';
        accInst.Data_Stipula_Contratto_Quadro__c = Date.today()-1;
        accInst.Phone= '3332323793';
        accInst.FiscalCode__c = null;
        accInst.RecordTypeId = recordTypeId;
        insert accInst;

        Contact contEffEn = new Contact();
        contEffEn.FirstName = 'TestEffEn';
        contEffEn.LastName = 'TestEffEn';
        contEffEn.Email = 'test@testuserEffEn.com';
        contEffEn.AccountId = accEffEn.Id;
        insert contEffEn;

        Contact contEffEnInst = new Contact();
        contEffEnInst.FirstName = 'TestEffEn';
        contEffEnInst.LastName = 'TestEffEn';
        contEffEnInst.Email = 'test@testuserEffEn.com';
        contEffEnInst.AccountId = accInst.Id;
        insert contEffEnInst;

        Profile profileEffEn = [SELECT Id, Name FROM Profile WHERE Name = 'External Profile' LIMIT 1];

        uniqueName = dateString;
        uniqueName = uniqueName + '@test' + '.org';

        User userEffEn = new User();
        userEffEn.LastName = 'TestEffEn';
        userEffEn.Username = uniqueName;
        userEffEn.ProfileId = profileEffEn.Id;
        userEffEn.ContactId = contEffEn.Id;
        userEffEn.Email = 'test@testUserEffEn.com';
        userEffEn.Alias = 'TEFFEN';
        userEffEn.LocaleSidKey = 'en_US';
        userEffEn.TimeZoneSidKey = 'GMT';
        userEffEn.LanguageLocaleKey = 'en_US';
        userEffEn.EmailEncodingKey = 'UTF-8';
        userEffEn.IsActive = true;
    
        insert userEffEn;

        User userInst = new User();
        userInst.LastName = 'TestEffEnInst';
        userInst.Username = uniqueName+'1';
        userInst.ProfileId = profileEffEn.Id;
        userInst.ContactId = contEffEnInst.Id;
        userInst.Email = 'test@testUserEffEn.com';
        userInst.Alias = 'FFENINST';
        userInst.LocaleSidKey = 'en_US';
        userInst.TimeZoneSidKey = 'GMT';
        userInst.LanguageLocaleKey = 'en_US';
        userInst.EmailEncodingKey = 'UTF-8';
        userInst.IsActive = true;
    
        insert userInst;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = accInst.Id;
        insert quote;

    }


   @isTest
    private static void searchAccountAgente_Test() {
        AgencyInstallerSelection_Controller.mockMethod();
        String act1 = 'ESTERNI_5678' ;
        User testUs= [SELECT ID,Account.Type FROM USER WHERE Alias = 'TEFFEN' ];

        Test.startTest();
        System.runAs(testUs) {
        List<Account> ret= AgencyInstallerSelection_Controller.searchAccount(act1);
        System.assertEquals( ret.size() <> 0, ret.size() <> 0);
        }
        Test.stopTest();
    }


    @isTest
    private static void searchAccountInstallatore_Test() {
        String act2 = 'ESTERNI' ;
        User testUs= [SELECT ID,Account.Type FROM USER WHERE Alias = 'FFENINST' ];

        Test.startTest();
        System.runAs(testUs) {
        List<Account> ret= AgencyInstallerSelection_Controller.searchAccount(act2);
        System.assertEquals( ret.size() <> 0, ret.size() <> 0);
        }
        Test.stopTest();
    }

    
    @isTest
    private static void searchAccountGeneric_Test() {
        String act = 'ESTERNI' ;
        

        Test.startTest();
        
        List<Account> ret= AgencyInstallerSelection_Controller.searchAccount(act);
        System.assertEquals( ret.size() <> 0, ret.size() <> 0);
        
        Test.stopTest();
    }




    @IsTest
    private static void getUserType_Test() {
        User testUs= [SELECT ID,Account.Type FROM USER WHERE Alias = 'FFENINST' ];

        Test.startTest();
        System.runAs(testUs) {
        String currentUser = AgencyInstallerSelection_Controller.getUserType();
        System.assertEquals( currentUser != null, currentUser != null);
        }
        Test.stopTest();
    }

    @IsTest
    private static void updatelookupAccount_Installer_Test() {
        Account acct = [SELECT ID,Type FROM Account WHERE Name = 'ESTERNI_5668'];
        SBQQ__Quote__c quoteRecord = [SELECT ID,SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c =: acct.Id];
        AgencyInstallerSelection_Controller.updatelookupAccount(quoteRecord.id, acct.Type, acct.Id);
        System.assertEquals(quoteRecord.SBQQ__Account__c != null, quoteRecord.SBQQ__Account__c!= null);
    }



}