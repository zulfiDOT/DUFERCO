/**
 * @TestClass: CreateUsageSummaryForDailyInvoicingTest
 */
public class CreateUsageSummaryForDailyInvoicingBatch implements Database.Batchable<sObject>{
    

    String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        Date today = Date.today();

        query = 'SELECT Order.AccountId, OrderId, Product2.DailyBilling__c, OrderItemNumber, Order.OrderNumber, EndDate, '+
                '( SELECT Id, SBQQ__UnitOfMeasure__c, SBQQ__MatchingAttribute__c FROM SBQQ__OrderItems__r ) '+
                'FROM OrderItem '+ 
                'WHERE Product2.DailyBilling__c = true AND (EndDate >=:today OR EndDate = Null) Order by OrderItemNumber';
                return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, List<OrderItem> scope){

    List<TransactionLog__c> logs = new List<TransactionLog__c>();
    List<blng__UsageSummary__c> usListToInsert = new List<blng__UsageSummary__c>();
    try {

        for (OrderItem oItem : scope) {

            for (SBQQ__OrderItemConsumptionSchedule__c oItemSchedule : oItem.SBQQ__OrderItems__r) {
                blng__UsageSummary__c us = new blng__UsageSummary__c();
                us.blng__Account__c = oItem.Order.AccountId;
                us.blng__Order__c = oItem.OrderId;
                us.blng__OrderProduct__c = oItem.Id;
                us.blng__OrderItemConsumptionSchedule__c = oItemSchedule.Id;
                us.blng__MatchingAttribute__c = oItemSchedule.SBQQ__MatchingAttribute__c;
                us.blng__UnitOfMeasure__c = oItemSchedule.SBQQ__UnitOfMeasure__c;
                us.blng__Status__c = 'Queued For Invoice';
                us.blng__Source__c = 'External';
                us.blng__SummaryStartDate__c = Date.today() + 1;
                us.blng__SummaryEndDate__c = Date.today() + 1;
                us.blng__NextBillingDate__c = Date.today() + 1;
                us.blng__Status__c = 'New';
                us.blng__UnbilledQuantity__c = 0;
                us.blng__Subtotal__c = 0;
                us.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
                us.blng__MatchingId__c = us.blng__Order__c +'-'+us.blng__OrderProduct__c +'-'+String.valueOf(us.blng__SummaryEndDate__c.year())+'-'+String.valueOf(us.blng__SummaryEndDate__c.month())+'-'+String.valueOf(us.blng__SummaryEndDate__c.day());
                
                usListToInsert.add(us);
            }
            
        }
        if (!usListToInsert.isEmpty()) {

            System.debug('US LIST TO INSERT ' +usListToInsert);
            Database.SaveResult[] srList = Database.insert(usListToInsert,false);

                for (Integer i = 0; i < srList.size(); i++) {
                    if (!srList.get(i).isSuccess()){
                        // Operation failed, so get all errors                
                        for(Database.Error err : srList.get(i).getErrors()) {
                            System.debug('The following error has occurred.');                    
                            TransactionLog__c log = new TransactionLog__c();
                            log.Status__c = 'Failed';
                            log.Log_Detail__c = err.getStatusCode() + ': ' + err.getMessage();
                            log.Record__c = JSON.serializePretty(usListToInsert.get(i));
                            log.ProcessName__c = 'CreateUsageSummaryForDailyInvoicingBatch';
                            logs.add(log);
                        }
                    }
                }
            
            TransactionLogUtility.insertAsyncLog(logs);
            
        }
    } catch (Exception e) {

        TransactionLog__c log = new TransactionLog__c();
            log.Status__c = 'Failed';
            log.Log_Detail__c = e.getTypeName() +' - '+e.getStackTraceString();
            log.ProcessName__c = 'CreateUsageSummaryForDailyInvoicingBatch';
            logs.add(log);
        
            TransactionLogUtility.insertAsyncLog(logs);
        }
    }
   
    public void finish(Database.BatchableContext BC){

        DeleteUsageSummaryForDailyInvoicingBatch batch = new DeleteUsageSummaryForDailyInvoicingBatch();
        database.executebatch(batch);
    }
}