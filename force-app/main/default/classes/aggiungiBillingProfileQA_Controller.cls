/*
 *   @TestClass: aggiungiBillingProfileQA_ControllerTest
*/
public with sharing class aggiungiBillingProfileQA_Controller {
    
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true)
    public static List<Account> getBillingRecords(String quoteId) {
        
        List<Account> billingList = [Select id, Name, FormaAnagrafica__c, FiscalCode__c, PEC__c, PEC__pc,  Email__c,PersonEmail, SdiCode__c, RecordType.DeveloperName, FirstName, LastName,
                                         (Select AccountId__c, BillingEmail__c, BillingAddress__c, PECEmail__c, PaymentMethod__c, 
                                            toLabel(PaymentConditions__c), DefaultBillingProfile__c, IsActive__c, Indirizzo_di_fatturazione__c,PaymentMode__c,
                                            toLabel(PaymentMethod__r.blng__PaymentType__c)  from Billing_Profiles__r where PaymentMethod__r.blng__PaymentType__c != null order by CreatedDate DESC) 
                                        from account where id IN (Select SBQQ__Account__c from SBQQ__Quote__c where id =: quoteId) Limit 1];

        return billingList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getPaymentMethod(String quoteId) {
        
        List<Account> paymentList = [Select id, Customer_Address_Numero_Civico__c, Customer_Address_Street__c, Customer_Address_City__c, Customer_Address_Postal_Code__c, Customer_Address_State__c, Customer_Address_Country__c,
                                        (Select Id, blng__BillingCountry__c, toLabel(blng__PaymentType__c), IBAN__c, Sottoscrittore_e_Debitore_coincidono__c, blng__Active__c   from blng__AccountPaymentMethods__r where blng__BillingCountry__c != Null order by CreatedDate DESC) 
                                        from account where id IN (Select SBQQ__Account__c from SBQQ__Quote__c where id =: quoteId)];

        return paymentList;
    }

    @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQuoteLines(String quoteId) {
        
        return [Select id, Name from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId];
        
    }

    @AuraEnabled(cacheable=true)
    public static List<SBQQ__Quote__c> getRecordTypeQuote (String quoteId) {
        
        return [Select id, RecordType.DeveloperName from SBQQ__Quote__c where id =: quoteId LIMIT 1];
        
    }



    @AuraEnabled
    public static string addBillingProfile(Map<String, Object> billingParams, String quoteId){
        String result;

            Address__c address = (Address__c) JSON.deserialize(JSON.serialize(billingParams.get('address')), Address__c.class);
            blng__PaymentMethod__c payment = (blng__PaymentMethod__c) JSON.deserialize(JSON.serialize(billingParams.get('payment')), blng__PaymentMethod__c.class);
            BillingProfile__c billing = (BillingProfile__c) JSON.deserialize(JSON.serialize(billingParams.get('billing')), BillingProfile__c.class);
            SBQQ__Quote__c quote = new SBQQ__Quote__c();

            SBQQ__Quote__c getBPCompany = [Select Company__c, RecordType.Name from SBQQ__Quote__c where id =: quoteId WITH SECURITY_ENFORCED Limit 1];

            if (address.Id != null) {
                if (address.Type__c != 'Indirizzo Fatturazione') {
                    address.Type__c = '4';
                    address.Id = null;
                    billing.BillingAddress__c = insertSobject(address);
                }else {
                    billing.BillingAddress__c = address.Id;
                }
            }else{
                billing.BillingAddress__c = insertSobject(address);
            }

            if (payment.Id != null) {
                billing.PaymentMethod__c = payment.Id;
            }else {
                billing.PaymentMethod__c = insertSobject(payment);
            }
            billing.Company__c = getBPCompany.Company__c;

            quote.Billing_Profile__c = insertSobject(billing);
            quote.Id = quoteId;

            update quote;

            result = getBPCompany.RecordType.Name;

        return result;
    }

    public static String insertSobject(SObject record) {
        
         String result;
         Database.SaveResult saveResult = Database.insert(record);

         if (saveResult.isSuccess()) {
            result = saveResult.getId();
         }else {
            for(Database.Error err : saveResult.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }
         }

         return result;
         
    }

    @AuraEnabled(cacheable=true)
    public static String getRecorTypeName(String quoteId) {
        String returnString;
        List<SBQQ__Quote__c> billingList = [Select id, Name, RecordTypeId, RecordType.Name From SBQQ__Quote__c Where Id =: quoteId Limit 1];
        if(!billingList.isEmpty() && !String.isBlank(billingList[0].RecordTypeId)){
            returnString = billingList[0].RecordType.Name;
        }
        return returnString;
    }
}