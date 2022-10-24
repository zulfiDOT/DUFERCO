trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update,after insert, after update) {
    
 	if(trigger.isBefore){
        if(trigger.isInsert){
        	QuoteTriggerHandler.getValidPromoCode(trigger.new);
            
    	}else if(trigger.isUpdate){
        	QuoteTriggerHandler.getValidPromoCode(trigger.newMap,trigger.OldMap);
    	}
    }else if(Trigger.isAfter){
        if(Trigger.isUpdate) QuoteTriggerHandler.DeletePromotion();
        QuoteTriggerHandler.CreateQuotePromotion();
    }
}