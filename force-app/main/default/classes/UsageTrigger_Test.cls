@isTest
public with sharing class UsageTrigger_Test {
    @isTest
    public static void UsageTrigger_Test() {

        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
        BillingStreet = 'Test Street', BillingPostalCode = '12345', 
        BillingCountry = 'Test Country', Phone = '123456',
        Nation__c ='IT', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;

        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New');
        insert opp;

        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = '2';
        paymentMethod.blng__Account__c = objAccount.Id;
        Insert paymentMethod;

        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '4';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        insert billing;

        BillingProfile__c billing2 = new BillingProfile__c();
        billing.PaymentConditions__c = '0';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        insert billing2;

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

        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe',ProductCode= 'TESTCONSUMOUS', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione');
        insert objProduct;

        Product2 objProduct1 = new Product2(Name = 'Arrotondamento',productcode='TESTCONSUMOUS', family = 'Cafe', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione');
        insert objProduct1;

        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                        Product2Id = objProduct.Id, IsActive = true);                                                            
        insert objPBE;

        Product2 objProductSconto = new Product2(Name = 'SCONTOINFATTURA', family = 'Cafe', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
        blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione', ProductCode= 'TESTCONSUMOUS');
        insert objProductSconto;

        PriceBookEntry objPBESconto = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
        Product2Id = objProductSconto.Id, IsActive = true);                                                            
        insert objPBESconto;

        blng__TaxIntegration__c taxIntegration = new blng__TaxIntegration__c(blng__TaxEngine__c = 'Standard', blng__Active__c = true, blng__Default__c = true);
        insert taxIntegration;

        blng__TaxTreatment__c taxTreatment = new blng__TaxTreatment__c(blng__TaxRule__c = objProductSconto.blng__TaxRule__c, blng__TaxIntegration__c = taxIntegration.id);
        insert taxTreatment;

        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c (blng__Active__c = true, blng__City__c = 'Genova', blng__Country__c = 'Italy', 
            blng__County__c= 'GE', blng__State__c = 'GE', blng__Street1__c= 'via', blng__ZipPostalCode__c = '20100');

        insert legalEntity;

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
        ord.EffectiveDate = Date.today();
        ord.Status = 'Draft';
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

        CustomAutonumber__c lastDocId = new CustomAutonumber__c(Name = 'DocumentId' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastDocId;

        CustomAutonumber__c lastProgr = new CustomAutonumber__c(Name = 'Progressive' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastProgr;

        blng__Payment__c payment = new blng__Payment__c(Order__c = ord.Id, blng__Account__c=objAccount.Id, blng__Amount__c=100);
        insert payment;

        blng__Invoice__c inv = new blng__Invoice__c(blng__Account__c=objAccount.Id, blng__Order__c = ord.Id, BillingProfile__c = billing.Id, blng__InvoiceDate__c = System.today());
        insert inv;

        blng__UsageSummary__c usSum = new blng__UsageSummary__c(
        blng__Account__c = objAccount.Id,
        blng__Order__c = ord.Id,
        blng__Invoice__c = inv.id,
        blng__OrderProduct__c = ordItem.Id,
        blng__SummaryStartDate__c = System.today()-2,
        blng__SummaryEndDate__c = System.today()-2,
        blng__UnbilledQuantity__c = 0,
        blng__Subtotal__c = 0,
        blng__NextBillingDate__c = System.today()-1,
        blng__InvoiceRunProcessingStatus__c = 'Pending Billing',
        blng__MatchingId__c=ord.Id+'-'+ordItem.Id+'-'+System.today().year()+'-'+System.today().month(),
        blng__MatchingAttribute__c = 'Kwh',
        blng__UnitOfMeasure__c = 'kWh',
        blng__Source__c = 'External');
        insert usSum;


        blng__Usage__c us = new blng__Usage__c(
        blng__UsageSummary__c =usSum.id,
        blng__Status__c = 'Processed',
        blng__Account__c = objAccount.Id,
        blng__ProcessingDate__c = System.today()-2,
        //blng__Quantity__c = 400,
        blng__PreratedQuantity__c = 10,
        blng__PreratedAmount__c = 50,
        //Vehicle_Efficiency__c = 200,
        //Emission_Avg__c = 78,
        blng__MatchingAttribute__c = 'Kwh',
        blng__UnitOfMeasure__c = 'kWh',
        blng__MatchingId__c=ord.Id+'-'+ordItem.Id+'-'+System.today().year()+'-'+System.today().month(),
        blng__StartDateTime__c = Datetime.now(),
        blng__EndDateTime__c = Datetime.now()
        );
        insert us;

        UsageTriggerHandler.createCustomUsageSummary(new List<blng__Usage__c>{us});


    }
}