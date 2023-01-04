/*
 *   @TestClass: CustomAutonumberResetBatchTest
*/

global class ScheduleCustomAutonumberResetBatch implements Schedulable {
    global void execute(SchedulableContext sc){
        CustomAutonumberResetBatch runBatch = new CustomAutonumberResetBatch();   
        Database.executeBatch(runBatch); 
    }
}