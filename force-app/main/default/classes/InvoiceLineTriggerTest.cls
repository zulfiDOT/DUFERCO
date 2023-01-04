@isTest
private class InvoiceLineTriggerTest {
    @isTest static void myTest() {
        RecordType rtAcc = [SELECT Id FROM RecordType WHERE IsActive = true AND DeveloperName = 'Business' AND SobjectType = 'Account'];
        
        Account acc = new Account( Name = 'prova', RecordTypeId = rtAcc.Id );
        insert acc;

        CustomAutonumber__c lastDocId = new CustomAutonumber__c(Name = 'DocumentId' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastDocId;

        CustomAutonumber__c lastProgr = new CustomAutonumber__c(Name = 'Progressive' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert lastProgr;

        blng__Invoice__c inv = new blng__Invoice__c( blng__Account__c=acc.Id );
        insert inv;

        blng__InvoiceLine__c invline = new blng__InvoiceLine__c( blng__Invoice__c = inv.Id );
        insert invline;

        blng__InvoiceScheduler__c is = new blng__InvoiceScheduler__c(
            blng__InvoiceDate__c = System.today(),
            blng__StartDateTime__c = System.now().addMinutes(10),
            blng__TargetDate__c = System.today(),
            blng__Type__c = 'Once',
            Name = 'Scheduler test'
        );
        insert is;

        blng__InvoiceRun__c ir = new blng__InvoiceRun__c(
            blng__InvoiceDate__c = is.blng__InvoiceDate__c,
            blng__InvoiceScheduler__c = is.Id,
            blng__StartTime__c = is.blng__StartDateTime__c,
            blng__TargetDate__c = is.blng__TargetDate__c,
            Name = is.Name
        );
        insert ir;

        ir.Name = 'Test';
        update ir;
    }
}