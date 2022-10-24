public class DeleteUsageSummaryForDailyInvoicingBatch implements Database.Batchable<sObject>{
    

    String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        Date today = Date.today().addDays(-10);
        query = 'SELECT blng__Account__c, blng__Order__c, blng__OrderProduct__c, blng__OrderItemConsumptionSchedule__c, blng__MatchingId__c, '+ 
                'blng__NextBillingDate__c, blng__UnitOfMeasure__c, blng__Status__c, blng__Source__c, blng__SummaryStartDate__c, ' +
                'blng__SummaryEndDate__c, blng__InvoiceRunProcessingStatus__c ' +
                'FROM blng__UsageSummary__c WHERE blng__SummaryStartDate__c < :today AND blng__SummaryEndDate__c < :today AND blng__Source__c = \'External\' AND '+
                'blng__OrderProduct__r.Product2.DailyBilling__c = true AND Id NOT IN (Select blng__UsageSummary__c From blng__Usage__c) Order by blng__Order__r.OrderNumber';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, List<blng__UsageSummary__c> scope){
        
        if (!scope.isEmpty()) {
            
            delete scope;
        }
    }
   
    public void finish(Database.BatchableContext BC){

    }
}