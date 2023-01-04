@istest
public with sharing class CreateUsageSummaryForDailyInvoicingTest {
    @testSetup
    public static void setup() {
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                                                    BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                                                    BillingCountry = 'Test Country', Phone = '123456',recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;

        //Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'Qualification');
        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New');
        insert opp;

        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = '9';
        paymentMethod.blng__Account__c = objAccount.Id;
        Insert paymentMethod;

        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '100';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        insert billing;

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
                                            blng__RevenueRecognitionRule__c = revenue.Id, DailyBilling__c = true);
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
        insert quote;

        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quote.Id;
        quoteLineItem.SBQQ__Quantity__c = 1;
        quoteLineItem.SBQQ__RegularPrice__c = 100;
        quoteLineItem.SBQQ__CustomerPrice__c = 50;
        quoteLineItem.SBQQ__Product__c = objProduct.Id;
        insert quoteLineItem;


        Order ord = new Order();
        ord.SBQQ__Quote__c = quote.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = Date.today() - 1;
        ord.EndDate = Date.today();
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
        ordItem.ServiceDate = Date.today() - 1;
        ordItem.EndDate = Date.today();
        insert ordItem;
        
        ConsumptionSchedule ConSch = new ConsumptionSchedule(Name = 'Test', 
                                                             RatingMethod ='Tier',
                                                             Type = 'Slab',
                                                             SBQQ__Category__c = 'Rates', 
                                                             BillingTerm = 1, 
                                                             BillingTermUnit= 'Month', 
                                                             UnitOfMeasure = 'Kwh',  
                                                             MatchingAttribute = 'Kwh');
        Insert ConSch;

        SBQQ__OrderItemConsumptionSchedule__c SBQQ_OItem = new SBQQ__OrderItemConsumptionSchedule__c(Name = 'Test',
                                                                                                     SBQQ__RatingMethod__c ='Tier',
                                                                                                     SBQQ__Type__c = 'Slab',
                                                                                                     SBQQ__ConsumptionSchedule__c = ConSch.id,
                                                                                                     SBQQ__Category__c = 'Rates',
                                                                                                     SBQQ__OrderItem__c = ordItem.id,
                                                                                                     SBQQ__BillingTerm__c = 1,
                                                                                                     SBQQ__BillingTermUnit__c = 'Month',
                                                                                                     SBQQ__UnitOfMeasure__c = 'Kwh', 
                                                                                                     SBQQ__MatchingAttribute__c = 'Kwh');
        Insert SBQQ_OItem;
            
        blng__UsageSummary__c us = new blng__UsageSummary__c();
        us.blng__Account__c = objAccount.Id;
        us.blng__Order__c = ord.Id;
        us.blng__OrderProduct__c = ordItem.Id;
        us.blng__SummaryStartDate__c = Date.today() - 1;
        us.blng__SummaryEndDate__c = Date.today() - 1;
        us.blng__UnbilledQuantity__c = 0;
        us.blng__Subtotal__c = 0;
        us.blng__NextBillingDate__c = Date.today() - 1;
        us.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
        us.blng__Status__c = 'Queued For Invoice';
        us.blng__Source__c = 'External';
        insert us;

        blng__UsageSummary__c us1 = new blng__UsageSummary__c();
        us1.blng__Account__c = objAccount.Id;
        us1.blng__Order__c = ord.Id;
        us1.blng__OrderProduct__c = ordItem.Id;
        us1.blng__SummaryStartDate__c = Date.today() + 1;
        us1.blng__SummaryEndDate__c = Date.today() + 1;
        us1.blng__UnbilledQuantity__c = 0;
        us1.blng__Subtotal__c = 0;
        us1.blng__NextBillingDate__c = Date.today() + 1;
        us1.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
        us1.blng__Source__c = 'External';
        insert us1;
        
    }
    @IsTest
    static void createUStest(){
        
        Test.startTest();
        SchedulableContext sc = null;
        
        CreateUSForDailyInvoicingScheduleClass ravc = new CreateUSForDailyInvoicingScheduleClass();
        ravc.execute(sc);
         //String sch = '0 0 23 * * ?';
        //system.schedule('Test check', sch, ravc);
        Test.stopTest();
        
    }
    
    @IsTest
    static void createUStest2(){
        
        Test.startTest();
        SchedulableContext sc = null;
        UsageSummaryWillNotInvoiceSchedule ravc = new UsageSummaryWillNotInvoiceSchedule();
        ravc.execute(sc);
        Test.stopTest();
        
    }
}