@isTest
private class BatchSchedulerCustomAutonumberTest {
    @isTest
    public static void BatchSchedulerCustomAutonumberTest() {

        CustomAutonumber__c autonumber = new CustomAutonumber__c(Name = 'MO' , ProgressiveNumber__c = 1 , Total_Length__c = 8);
        insert autonumber;   

        Test.startTest();
        system.schedule('test job', '0 0 0 1 1 ?', new BatchSchedulerCustomAutonumber());
        Test.stopTest();

    }
}