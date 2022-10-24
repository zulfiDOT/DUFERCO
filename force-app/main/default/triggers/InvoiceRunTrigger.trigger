trigger InvoiceRunTrigger on blng__InvoiceRun__c (after update) {

    for(blng__InvoiceRun__c ir : Trigger.new) {
        System.debug('ir.blng__Status__c='+ir.blng__Status__c);
        if(ir.blng__Status__c == 'Completed' || ir.blng__Status__c == 'Completed with errors') {
            Database.executeBatch(new InvoiceManagementBatch(ir.Id));
        }
    }

}