/*
 *   @Class  :   TransactionLogUtility
*/
@isTest
public class TransactionLogUtilityTest {
    
    @isTest static void insertAsyncLogTest() {

        List<TransactionLog__c> logs = new List<TransactionLog__c>();
        TransactionLog__c log = new TransactionLog__c();
        log.Status__c = 'Failed';

        logs.add(log);
        TransactionLogUtility.insertAsyncLog(logs);
    }
    
}