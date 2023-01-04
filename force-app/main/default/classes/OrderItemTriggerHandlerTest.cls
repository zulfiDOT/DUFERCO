@isTest public with sharing class OrderItemTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                                                    BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                                                    BillingCountry = 'Test Country', Phone = '123456',
                                         recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;

        //Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'Qualification');
        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New');
        insert opp;

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

        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
                                            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione');
        insert objProduct;

        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                        Product2Id = objProduct.Id, IsActive = true);                                                            
        insert objPBE;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = objAccount.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.PrevistoInvioPDF__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = '2';
        quote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('EfficienzaEnergetica').getRecordTypeId();
        insert quote;

        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quote.Id;
        quoteLineItem.SBQQ__Quantity__c = 1;
        quoteLineItem.SBQQ__RegularPrice__c = 100;
        quoteLineItem.SBQQ__CustomerPrice__c = 50;
        quoteLineItem.SBQQ__Product__c = objProduct.Id;
        quoteLineItem.ClonedSignificantAsset__c = false;
        insert quoteLineItem;


        Order ord = new Order();
        ord.SBQQ__Quote__c = quote.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = Date.today();
        ord.Status = 'Draft';
        //ord.OpportunityId = opp.Id;
        insert ord;

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
        insert ordItem;
    }

    @isTest public static void createWorkOrderTest(){

        List<WorkOrderLineItem> woItem = [Select id from WorkOrderLineItem];

        System.assert(!woItem.isEmpty());
    }
}