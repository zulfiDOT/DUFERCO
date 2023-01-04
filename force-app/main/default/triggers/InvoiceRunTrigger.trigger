/*
 *   @TestClass: InvoiceRunTriggerTest
*/
trigger InvoiceRunTrigger on blng__InvoiceRun__c (after update) {

    for(blng__InvoiceRun__c ir : Trigger.new) {
        System.debug('ir.blng__Status__c='+ir.blng__Status__c);
        if((ir.blng__Status__c == 'Completed' || ir.blng__Status__c == 'Completed with errors') && Trigger.oldMap.get(ir.Id).blng__Status__c != 'Completed' && Trigger.oldMap.get(ir.Id).blng__Status__c != 'Completed with errors') {
            //Database.executeBatch(new InvoiceManagementBatch(ir.Id));
            InvoiceManagementBatchSchd m = new InvoiceManagementBatchSchd(ir.Id);
            Datetime dtNow = System.now().addMinutes(15);
            String sch = dtNow.second()+' '+dtNow.minute()+' '+dtNow.hour()+' '+'* * ?';
            String jobID = System.schedule('InvoiceManagementBatchSchd-'+System.now()+'-'+ir.Id, sch, m);
        }
    }

}