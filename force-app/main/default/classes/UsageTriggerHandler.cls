public with sharing class UsageTriggerHandler {
    

    public static void createCustomUsageSummary(List<blng__Usage__c> usageRecords) {

        List<blng__UsageSummary__c> usList = new List<blng__UsageSummary__c>();
        Set<Id> orderItemSetId = new Set<Id>();
        for (blng__Usage__c usage : usageRecords) {
            
            orderItemSetId.add(usage.blng__OrderProduct__c);
        }

        Map<Id, OrderItem> orderItemMapQuery = new Map<Id, OrderItem>([SELECT Product2.ProductCode, ( SELECT Id FROM SBQQ__OrderItems__r ) FROM OrderItem WHERE Id IN :orderItemSetId]);

        for (blng__Usage__c usage : usageRecords) {
            
            if (orderItemMapQuery?.get(usage.blng__OrderProduct__c)?.Product2.ProductCode == 'TESTCONSUMOUS') {
                blng__UsageSummary__c us = new blng__UsageSummary__c();
                us.blng__Account__c = usage.blng__Account__c;
                us.blng__Order__c = usage.blng__Order__c;
                us.blng__OrderProduct__c = usage.blng__OrderProduct__c;
                us.blng__OrderItemConsumptionSchedule__c = orderItemMapQuery.get(usage.blng__OrderProduct__c)?.SBQQ__OrderItems__r?.get(0).Id;
                us.blng__MatchingId__c = usage.blng__Order__c +'-'+usage.blng__OrderProduct__c +'-'+String.valueofGmt(usage.blng__EndDateTime__c);
                usage.blng__MatchingId__c = usage.blng__Order__c +'-'+usage.blng__OrderProduct__c +'-'+String.valueofGmt(usage.blng__EndDateTime__c);
                us.blng__MatchingAttribute__c = usage.blng__MatchingAttribute__c;
                us.blng__UnitOfMeasure__c = usage.blng__UnitOfMeasure__c;
                us.blng__Status__c = 'Queued For Invoice';
                us.blng__SummaryStartDate__c = Date.newinstance(usage.blng__StartDateTime__c.year(), usage.blng__StartDateTime__c.month(), usage.blng__StartDateTime__c.day());
                us.blng__SummaryEndDate__c = Date.newinstance(usage.blng__EndDateTime__c.year(), usage.blng__EndDateTime__c.month(), usage.blng__EndDateTime__c.day());
                us.blng__UnbilledQuantity__c = 0;
                us.blng__Subtotal__c = 0;
                us.blng__NextBillingDate__c = Date.today(); // chiedere conferma
                us.blng__InvoiceRunProcessingStatus__c = 'Pending Billing';
                us.CreatedFromBilling__c = false;

                usList.add(us);
            }
        }

        if (!usList.isEmpty()) {

            insert usList;
        }

        Map<String,blng__UsageSummary__c> matchingIdToUSMap = New Map<String,blng__UsageSummary__c>();
        for (blng__UsageSummary__c usCreated : [SELECT Id, blng__MatchingId__c FROM blng__UsageSummary__c WHERE Id IN : usList]) {
            
            matchingIdToUSMap.put(usCreated.blng__MatchingId__c, usCreated);
        }

        for (blng__Usage__c usage : usageRecords) {

            if (matchingIdToUSMap.get(usage.blng__MatchingId__c) != null) {
                usage.blng__UsageSummary__c = matchingIdToUSMap.get(usage.blng__MatchingId__c).Id;
                
            }         
        }

    }
}