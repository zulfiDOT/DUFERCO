global class ResetAssetValueBatchScheduleClass implements Schedulable {

    global void execute(SchedulableContext ctx) {
        ResetAssetValueBatch batch = new ResetAssetValueBatch();
        database.executebatch(batch);
    }
}