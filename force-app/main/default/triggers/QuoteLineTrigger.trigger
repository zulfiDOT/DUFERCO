trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update,after insert, after update, after delete) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            
            QuoteLineTriggerHandler.addFilesToQuote(Trigger.new);
        }else if (Trigger.isDelete) {
            
            QuoteLineTriggerHandler.removeFilesToQuote(Trigger.old);
        }
    }

}