@isTest
public class BatchCloseQuoteCondomini_Test {
    
    @isTest
    public static void BatchTest() {
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country', Phone = '123456',FiscalCode__c= '91234567891',
                                        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;        
               
        list<Opportunity> oppList = new list<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New');
        oppList.add(opp);
        
        Opportunity opp2 = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New');
        oppList.add(opp2);
        insert oppList;

        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = '2';
        paymentMethod.blng__Account__c = objAccount.Id;
        Insert paymentMethod;

        list<BillingProfile__c> billingList = new list<BillingProfile__c>();
        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '4';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        billingList.add(billing);

        BillingProfile__c billing2 = new BillingProfile__c();
        billing.PaymentConditions__c = '0';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        billingList.add(billing2);
        insert billingList;

        blng__BillingRule__c billRule = new blng__BillingRule__c();
        billRule.blng__GenerateInvoices__c = 'No';
        billRule.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        insert billRule;

        blng__RevenueRecognitionRule__c revenue = new blng__RevenueRecognitionRule__c();
        revenue.Name = 'Test';
        revenue.blng__CreateRevenueSchedule__c = 'No';
        insert revenue;

        blng__TaxRule__c tax = new blng__TaxRule__c();
        tax.Name = 'Tax Test';
        tax.blng__TaxableYesNo__c = 'No';
        insert tax;

        list<Product2> ProductList = new list<Product2>();
        Product2 objProduct = new Product2(Name = 'Test product1', family = '24', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,Withholding_Tax__c = true,
                                            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione');
        ProductList.add(objProduct);

        Product2 objProduct1 = new Product2(Name = 'Arrotondamento',productcode='ARR', family = '24', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
                                            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione');
        ProductList.add(objProduct1);

        Product2 objProductSconto = new Product2(Name = 'SCONTOINFATTURA', family = '24', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
        blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione', ProductCode = 'SCONTOINFATTURA');
        ProductList.add(objProductSconto);

        insert ProductList;

        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
        Product2Id = objProduct.Id, IsActive = true);                                                            
        insert objPBE;

        PriceBookEntry objPBESconto = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
        Product2Id = objProductSconto.Id, IsActive = true);                                                            
        insert objPBESconto;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = objAccount.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.PrevistoInvioPDF__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = '2';
        insert quote;
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
        quote2.SBQQ__Account__c = objAccount.Id;
        quote2.SBQQ__Opportunity2__c = opp.Id;
        quote2.PrevistoInvioPDF__c = false;
        quote2.SBQQ__Primary__c = true;
        quote2.SBQQ__Status__c = '2';
        quote2.ParentQuote__c =quote.Id; 
        insert quote2;

        Order ord = new Order();
        ord.SBQQ__Quote__c = quote2.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = Date.today();
        ord.Status = 'Draft';
        insert ord;

        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quote.Id;
        quoteLineItem.SBQQ__Quantity__c = 1;
        quoteLineItem.SBQQ__RegularPrice__c = 100;
        quoteLineItem.SBQQ__CustomerPrice__c = 50;
        quoteLineItem.SBQQ__Product__c = objProduct.Id;
        quoteLineItem.SBQQ__ChargeType__c = 'Recurring';
        quoteLineItem.SBQQ__BillingType__c = 'Advance';
        quoteLineItem.SBQQ__BillingFrequency__c = 'Annual';
        quoteLineItem.SBQQ__PricebookEntryId__c = objPBE.Id;
        insert quoteLineItem;

        SBQQ__QuoteLine__c quoteLineItem2 = new SBQQ__QuoteLine__c();
        quoteLineItem2.SBQQ__Quote__c = quote2.Id;
        quoteLineItem2.SBQQ__Quantity__c = 1;
        quoteLineItem2.SBQQ__RegularPrice__c = 100;
        quoteLineItem2.SBQQ__CustomerPrice__c = 50;
        quoteLineItem2.SBQQ__Product__c = objProduct.Id;
        quoteLineItem2.SBQQ__ChargeType__c = 'Recurring';
        quoteLineItem2.SBQQ__BillingType__c = 'Advance';
        quoteLineItem2.SBQQ__BillingFrequency__c = 'Annual';
        quoteLineItem2.SBQQ__PricebookEntryId__c = objPBE.Id;
        insert quoteLineItem2;

        OrderItem ordItem = new OrderItem();
        ordItem.OrderId = ord.Id;
        ordItem.Product2Id = objProduct.Id;
        ordItem.SBQQ__ChargeType__c = 'One-Time';
        ordItem.PricebookEntryId = objPBE.Id;
        ordItem.UnitPrice = 10000.00;
        ordItem.blng__BillingRule__c = billRule.Id;
        ordItem.blng__RevenueRecognitionRule__c = revenue.Id;
        ordItem.blng__TaxRule__c = tax.Id;
        ordItem.Quantity = 1;
        ordItem.SBQQ__QuoteLine__c = quoteLineItem.id;
        insert ordItem;
        
        Set<Id> queteSetId = new Set<Id>();
        queteSetId.add(quote.Id);
        
        BatchCloseQuoteCondomini btch = new BatchCloseQuoteCondomini(queteSetId);
        Database.executeBatch(btch);  
 
        
    }
   
    


}