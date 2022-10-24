global class CreateUSForDailyInvoicingScheduleClass implements Schedulable{

    global void execute(SchedulableContext ctx) {
        CreateUsageSummaryForDailyInvoicingBatch batch = new CreateUsageSummaryForDailyInvoicingBatch();
        database.executebatch(batch);
    }

}