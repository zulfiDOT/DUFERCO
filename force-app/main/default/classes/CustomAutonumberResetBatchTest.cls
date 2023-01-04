@isTest
Private Class CustomAutonumberResetBatchTest {

   Static testMethod void testBatchExecuteMethod()
   {
    CustomAutonumber__c autonumber = new CustomAutonumber__c(Name = 'MO' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
    insert autonumber;

     Test.startTest();

     CustomAutonumberResetBatch batchTest = new CustomAutonumberResetBatch ();
     Id jobid = Database.executeBatch(batchTest,5);

     Test.stopTest();

     //Account acc = [Select Industry from Account where id=: a.Id];

     //System.assertEquals('Household', acc.Industry);
    }

    @isTest
    static void ScheduleCustomAutonumberResetBatch(){
        Test.startTest();
        ScheduleCustomAutonumberResetBatch abs= new ScheduleCustomAutonumberResetBatch();
        abs.execute(null);
        Test.stopTest();
    }
}