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
    }
}