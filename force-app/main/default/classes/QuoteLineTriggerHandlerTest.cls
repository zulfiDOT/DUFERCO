/*
 *   @Class  :   QuoteLineTriggerHandler
 * 
*/
@isTest
public with sharing class QuoteLineTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                                                    BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                                                    BillingCountry = 'Test Country', Phone = '123456',
                                         recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;

        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        insert objProduct;

        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                        Product2Id = objProduct.Id, IsActive = true);                                                            
        insert objPBE;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = objAccount.Id;
        quote.PrevistoInvioPDF__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = '2';
        insert quote;

        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quote.Id;
        quoteLineItem.SBQQ__Quantity__c = 1;
        quoteLineItem.SBQQ__RegularPrice__c = 100;
        quoteLineItem.SBQQ__CustomerPrice__c = 50;
        quoteLineItem.SBQQ__Product__c = objProduct.Id;
        insert quoteLineItem;
    
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objProduct.Id;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        insert contentlink;
    
    }

    @isTest
   public static void addFilesToQuoteTest(){


        List<SBQQ__QuoteLine__c> qLines = [Select SBQQ__Quote__c, SBQQ__Product__c From SBQQ__QuoteLine__c];
        Test.startTest();
        QuoteLineTriggerHandler.addFilesToQuote(qLines);
        Test.stopTest();

        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
        List<ContentDocumentLink> documentLinkProduct = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                        FROM ContentDocumentLink WHERE LinkedEntityId =: quote.Id];
        System.assert(!documentLinkProduct.isEmpty());

    }

    @isTest
    public static void removeFilesToQuoteTest(){


        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
        ContentVersion content = [select contentdocumentid from contentversion];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = quote.Id;
        contentlink.contentdocumentid = content.contentdocumentid;
        insert contentlink;

         List<SBQQ__QuoteLine__c> qLines = [Select SBQQ__Quote__c, SBQQ__Product__c From SBQQ__QuoteLine__c];
         
         Test.startTest();
         QuoteLineTriggerHandler.removeFilesToQuote(qLines);
         Test.stopTest();

         List<ContentDocumentLink> documentLinkProduct = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                 FROM ContentDocumentLink WHERE LinkedEntityId =: quote.Id];

        
     }
}