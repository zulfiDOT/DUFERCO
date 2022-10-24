global class UsageSummaryWillNotInvoiceSchedule implements Schedulable {

    global void execute(SchedulableContext ctx) {
        UsageSummaryWillNotInvoiceBatch batch = new UsageSummaryWillNotInvoiceBatch();
        Database.executebatch(batch);
    }

}