/*
 *  @TestClass: BatchSchedulerCustomAutonumberTest
*/
global class BatchSchedulerCustomAutonumber implements Schedulable {
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        CustomAutonumberResetBatch batch = new CustomAutonumberResetBatch();
        Database.executebatch(batch, 200);
    }
}