@isTest
public class InvoiceRunTriggerTest {
    
    @isTest
    public static void testTrigger() {
        blng__InvoiceRun__c ir = new blng__InvoiceRun__c(
            blng__TargetDate__c = System.today(),
            blng__Status__c = 'Completed'
        );
        insert ir;
        update ir;
    }

}