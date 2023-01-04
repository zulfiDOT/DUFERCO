/*
 *   @TestClass: OrderItemTriggerHandlerTest
*/
trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update,after insert, after update) {
    
 	if(trigger.isBefore){
        if(trigger.isInsert){
        	QuoteTriggerHandler.getValidPromoCode(trigger.new);
            
    	}else if(trigger.isUpdate){
        	QuoteTriggerHandler.getValidPromoCode(trigger.newMap,trigger.OldMap);
    	}
    }else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            QuoteTriggerHandler.DeletePromotion();
            QuoteTriggerHandler.EfficienzaEnergeticaEngine(trigger.newMap,trigger.OldMap);

            List<SBQQ__Quote__c> updateIndividualList = new List<SBQQ__Quote__c>();
            Set<Id> parentQuoteIds = new Set<Id>();
            Set<Id> parentQuoteIdsDaFirmare = new Set<Id>();
            for(SBQQ__Quote__c itemQuote : Trigger.new){
                if(itemQuote.SBQQ__Status__c != Trigger.oldMap.get(itemQuote.Id).SBQQ__Status__c && itemQuote.SBQQ__Status__c == '3'){
                    updateIndividualList.add(itemQuote);

                    if(String.isBlank(itemQuote.ParentQuote__c) && itemQuote.PricebookType__c == 'Bsb')
                        parentQuoteIds.add(itemQuote.Id);
                }

                if(itemQuote.SBQQ__Status__c != Trigger.oldMap.get(itemQuote.Id).SBQQ__Status__c && itemQuote.SBQQ__Status__c == '1'
                    && String.isBlank(itemQuote.ParentQuote__c) && itemQuote.PricebookType__c == 'Bsb'){
                        parentQuoteIdsDaFirmare.add(itemQuote.Id);
                }
            }
            
            if(updateIndividualList.size() > 0)
                IndividualManageClass.manageTrigger(updateIndividualList, 'SBQQ__Quote__c');

            if(!parentQuoteIds.isEmpty()){
                BatchCloseQuoteCondomini btch = new BatchCloseQuoteCondomini(parentQuoteIds);
                Database.executeBatch(btch,1);
            }        

            if(!parentQuoteIdsDaFirmare.isEmpty()){
                BatchQuoteDaFirmare btch = new BatchQuoteDaFirmare(parentQuoteIdsDaFirmare);
                Database.executeBatch(btch,1);
            }        
        } 
        
        QuoteTriggerHandler.CreateQuotePromotion();
             
    }
}