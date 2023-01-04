/*
 *  @TestClass: BillingProfileTriggerTest
*/
public with sharing class BillingProfileTriggerHandler {

    public static void setMandateCode(List<BillingProfile__c> listBilling){
        system.debug('TRIGGER BILLING PROFILE SET MANDATE CODE****: ');
        Set<Id> paymentsToQuery = new Set<Id>();

        for(BillingProfile__c billingProfile : listBilling){
            if(!String.isBlank(billingProfile.Company__c) && !String.isBlank(billingProfile.PaymentMethod__c)){
                paymentsToQuery.add(billingProfile.PaymentMethod__c);
            }
        }    

        system.debug('payments To query: '+paymentsToQuery);
        List<blng__PaymentMethod__c> listPayments = [select id from blng__PaymentMethod__c where id =: paymentsToQuery and blng__PaymentType__c = '1' and MandateCode__c = null];
        List<CustomAutonumber__c> listCustomAutonumberMob = [select id, ProgressiveNumber__c, Last_Autonumber__c,Prefix__c from CustomAutonumber__c where Name = 'Numero Mandato'];
        List<CustomAutonumber__c> listCustomAutonumberBaslab = [select id, ProgressiveNumber__c, Last_Autonumber__c,Prefix__c from CustomAutonumber__c where Name = 'Numero Mandato Baslab'];
       
        if(listCustomAutonumberMob.size() > 0 && listCustomAutonumberBaslab.size() > 0 && listPayments.size() > 0){
            for(blng__PaymentMethod__c payment: listPayments){
                for(BillingProfile__c billingProfile : listBilling){
                    if(billingProfile.PaymentMethod__c == payment.id){
                        if(billingProfile.Company__c == '1'){
                            payment.MandateCode__c = listCustomAutonumberMob[0].Prefix__c + String.valueOf(Integer.valueOf(listCustomAutonumberMob[0].ProgressiveNumber__c + 1)).leftPad(12,'0');
                            payment.MandateSubscriptionDate__c = date.today();
                            listCustomAutonumberMob[0].ProgressiveNumber__c ++;
                            listCustomAutonumberMob[0].Last_Autonumber__c= payment.MandateCode__c;
                        } 
                        if(billingProfile.Company__c == '8'){
                            payment.MandateCode__c = listCustomAutonumberBaslab[0].Prefix__c + String.valueOf(Integer.valueOf(listCustomAutonumberBaslab[0].ProgressiveNumber__c + 1)).leftPad(12,'0');
                            payment.MandateSubscriptionDate__c = date.today();
                            listCustomAutonumberBaslab[0].ProgressiveNumber__c ++;
                            listCustomAutonumberBaslab[0].Last_Autonumber__c= payment.MandateCode__c;
                        } 

                    }
                }
            }
        }

        update listCustomAutonumberBaslab;
        update listCustomAutonumberMob;
        update listPayments;
    }
}