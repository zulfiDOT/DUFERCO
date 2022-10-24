/*
 *   @Test  :   CreditNoteTriggerHandler
*/
@isTest
public with sharing class CreditNoteTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
        BillingStreet = 'Test Street', BillingPostalCode = '12345', 
        BillingCountry = 'Test Country', Phone = '123456');
        insert objAccount;

        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'Qualification');
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
        insert quote;

        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quote.Id;
        quoteLineItem.SBQQ__Quantity__c = 1;
        quoteLineItem.SBQQ__RegularPrice__c = 100;
        quoteLineItem.SBQQ__CustomerPrice__c = 50;
        quoteLineItem.SBQQ__Product__c = objProduct.Id;
        insert quoteLineItem;

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Area__c = 'MO'
        );
        
        update standardPricebook;
        Order ord = new Order();
        ord.SBQQ__Quote__c = quote.Id;
        ord.Pricebook2Id = standardPricebook.id;
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

        CustomAutonumber__c lastDocId = new CustomAutonumber__c(Name = 'DocumentId' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastDocId;

        CustomAutonumber__c lastProgr = new CustomAutonumber__c(Name = 'Progressive' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastProgr;

        blng__Payment__c payment = new blng__Payment__c(Order__c = ord.Id, blng__Account__c=objAccount.Id, blng__Amount__c=100);
        insert payment;

        blng__Invoice__c inv = new blng__Invoice__c( blng__Account__c=objAccount.Id, blng__Order__c = ord.Id, BillingProfile__c = billing.Id, blng__InvoiceStatus__c = 'Posted');
        insert inv;

        blng__Payment__c payment1 = new blng__Payment__c(Quote__c = quote.Id, blng__Account__c=objAccount.Id, blng__Amount__c=100);
        insert payment1;

        blng__Invoice__c inv1 = new blng__Invoice__c( blng__Account__c=objAccount.Id, BillingProfile__c = billing.Id, blng__InvoiceStatus__c = 'Posted');
        insert inv1;

        blng__CreditNote__c creditNote1 = new blng__CreditNote__c(blng__Account__c=objAccount.Id,  blng__RelatedInvoice__c =  inv.id, blng__CreditNoteDate__c = Date.today());
        insert creditNote1;

        blng__CreditNote__c creditNote2 = new blng__CreditNote__c(blng__Account__c=objAccount.Id,  blng__RelatedInvoice__c =  inv1.id, blng__CreditNoteDate__c = Date.today());
        insert creditNote2;

    }

    @isTest public static void setCustomAutonumberTest() {
        

        List<blng__CreditNote__c> creditNoteList = [SELECT Id, Name, blng__RelatedInvoice__r.Name,blng__RelatedInvoice__r.blng__Order__c, blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c, blng__CreditNote__c.ProgressivoNotaCredito__c, blng__RelatedInvoice__r.InvoiceLineCount__c  FROM blng__CreditNote__c];
		Test.startTest();
        CreditNoteTriggerHandler.setCustomAutonumber(creditNoteList);
        Test.stopTest();
    }
}