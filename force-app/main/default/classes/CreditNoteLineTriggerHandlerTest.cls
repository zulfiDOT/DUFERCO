@isTest
public with sharing class CreditNoteLineTriggerHandlerTest {
    @isTest static void myTest() {
        RecordType rtAcc = [SELECT Id FROM RecordType WHERE IsActive = true AND DeveloperName = 'Business' AND SobjectType = 'Account'];
        
        Account acc = new Account( Name = 'prova', RecordTypeId = rtAcc.Id );
        insert acc;

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

        CustomAutonumber__c lastDocId = new CustomAutonumber__c(Name = 'DocumentId' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastDocId;

        CustomAutonumber__c lastProgr = new CustomAutonumber__c(Name = 'Progressive' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastProgr;

        blng__Invoice__c inv = new blng__Invoice__c( blng__Account__c=acc.Id, blng__InvoiceStatus__c = 'Posted');
        insert inv;

        blng__InvoiceLine__c invline = new blng__InvoiceLine__c( blng__Invoice__c = inv.Id );
        insert invline;

        blng__CreditNote__c creditNote1 = new blng__CreditNote__c(blng__Account__c=acc.Id,  blng__RelatedInvoice__c =  inv.id, blng__CreditNoteDate__c = Date.today());
        insert creditNote1;

        blng__CreditNoteLine__c cnL = new blng__CreditNoteLine__c(blng__CreditNote__c = creditNote1.id, blng__Product__c = objProduct.id);
        insert cnL;

    }
}