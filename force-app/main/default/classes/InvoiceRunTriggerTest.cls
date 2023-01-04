@isTest
public class InvoiceRunTriggerTest {
    
    @isTest
    public static void testTrigger() {
        blng__InvoiceRun__c ir = new blng__InvoiceRun__c(
            blng__TargetDate__c = System.today()
        );
        insert ir;
        ir.blng__Status__c = 'Completed';
        update ir;
    }

}