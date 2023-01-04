global class CustomTaxEngine implements blng.TaxEngines {
    
    global static void resetSObjectListofIds() {}

    global static void resetLegalEntityReferences() {}

    global static map<Id,blng.TaxResults> calculateTax(blng.TaxParameters taxParametersInstance) {

        System.debug('taxParametersInstance='+taxParametersInstance);

        String legalEntityReferences = taxParametersInstance.getLegalEntityReferences();
        System.debug('legalEntityReferences='+legalEntityReferences);

        List<Id> sObjectListofIds = taxParametersInstance.getSObjectListofIds();
        System.debug('sObjectListofIds='+sObjectListofIds);

        Set<Id> invoiceIds = new Set<Id>();

        if(legalEntityReferences != null) {
            List<String> references = legalEntityReferences.split(',');
            System.debug('references='+references);
            for(String reference : references) {
                System.debug('reference='+reference);
                List<String> recordIds = reference.split('-');
                System.debug('recordIds='+recordIds);
                invoiceIds.add(recordIds[0]);
            }
        }
        System.debug('invoiceIds with legalEntityReferences='+invoiceIds);

        if(sObjectListofIds != null && sObjectListofIds.size() > 0) {
            for(Id sObjectId : sObjectListofIds) {
                invoiceIds.add(sObjectId);
            }
        }
        System.debug('invoiceIds with sObjectListofIds='+invoiceIds);

        Map<Id,blng.TaxResults> results = new Map<Id,blng.TaxResults>();
        if(invoiceIds != null && invoiceIds.size() > 0) {
            if(taxParametersInstance.getSObjectType() == Schema.blng__InvoiceLine__c.SObjectType) {
                for(blng__InvoiceLine__c invoiceLine : [SELECT blng__TaxAmount__c, blng__TaxPercentageApplied__c
                                                        FROM blng__InvoiceLine__c
                                                        WHERE blng__Invoice__c IN :invoiceIds
                                                        AND blng__TaxTreatment__r.blng__TaxIntegration__r.blng__TaxEngine__c = 'Internal Custom Tax Engine']) {
                    System.debug('invoiceLine='+invoiceLine);

                    blng.TaxResults result = new blng.TaxResults();
                    result.setRate(invoiceLine.blng__TaxPercentageApplied__c);
                    result.setTax(invoiceLine.blng__TaxAmount__c);
                    result.setIsSuccess(true);
                    result.setId(invoiceLine.Id);

                    System.debug('result='+result);

                    results.put(invoiceLine.Id,result);
                }
                System.debug('results in invoiceLines='+results);
            }

            if(taxParametersInstance.getSObjectType() == Schema.blng__Invoice__c.SObjectType) {
                for(Id invoiceId : invoiceIds) {
                    blng.TaxResults result = new blng.TaxResults();
                    result.setIsSuccess(true);
                    result.setId(invoiceId);

                    System.debug('result='+result);

                    results.put(invoiceId,result);
                }
                System.debug('results in invoices='+results);
            }
        }

        return results;
    }

}