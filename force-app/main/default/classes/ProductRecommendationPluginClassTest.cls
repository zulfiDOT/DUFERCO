@isTest
public with sharing class ProductRecommendationPluginClassTest {
    
    @TestSetup
    static void makeData(){
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                                                    BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                                                    BillingCountry = 'Test Country', Phone = '123456');
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
    }

    @isTest
    public static void pluginTest() {

        SBQQ__Quote__c quote = [Select SBQQ__PriceBookId__c from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLines = [Select SBQQ__Product__c from SBQQ__QuoteLine__c];
        ProductRecommendationPluginClass plugin = new ProductRecommendationPluginClass();
        PricebookEntry[] result = plugin.recommend(quote,quoteLines);
    }
}