/*
 *   @TestClass: TransactionLogUtilityTest
*/
public with sharing class TransactionLogUtility {

    public static void insertAsyncLog(List<TransactionLog__c> logs) {
        
        if (!logs.isEmpty()) {
            
            insert logs;
        }
    }
}