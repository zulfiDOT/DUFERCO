global class InvoiceManagementBatchSchd implements Schedulable {
    
    global String invoiceRunId;

    global InvoiceManagementBatchSchd(String invoiceRunId) {
        this.invoiceRunId = invoiceRunId;
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new InvoiceManagementBatch(invoiceRunId));
        System.abortJob(SC.getTriggerId());
    }

}