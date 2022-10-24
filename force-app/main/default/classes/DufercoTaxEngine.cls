global class DufercoTaxEngine implements blng.TaxEngines {
    
    global static Void resetSObjectListofIds() {}

    global static Void resetLegalEntityReferences() {}

    global static Map<Id,blng.TaxResults> calculateTax(blng.TaxParameters taxParametersInstance) {

        System.debug('taxParametersInstance='+taxParametersInstance);

        Id objectId = taxParametersInstance.getLegalEntityReferences().substring(0,18);
        System.debug('objectId='+objectId);
        System.debug('object='+objectId.getSObjectType());

        Map<Id,blng.TaxResults> results = new Map<Id,blng.TaxResults>();

        if(objectId.getSObjectType() == Schema.Order.SObjectType) {
            List<OrderItem> orderItems = [SELECT UnitPrice FROM OrderItem WHERE OrderId = :objectId];
			System.debug('orderItems='+orderItems);

			blng.TaxResults result = new blng.TaxResults();
			result.setRate(22);
			result.setTax(100/*orderItems[0].UnitPrice*0.11*/);
			result.setIsSuccess(true);
			result.setId(orderItems[0].Id);
			System.debug('result='+result);

			results.put(orderItems[0].Id,result);
			System.debug('results='+results);
        } else if(objectId.getSObjectType() == Schema.blng__Invoice__c.SObjectType) {
            List<blng__InvoiceLine__c> invoiceLines = [SELECT blng__UnitPrice__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c = :objectId];
            System.debug('invoiceLines='+invoiceLines);

            blng.TaxResults result = new blng.TaxResults();
            result.setRate(22);
            result.setTax(100/*orderItems[0].UnitPrice*0.11*/);
            result.setIsSuccess(true);
            result.setId(invoiceLines[0].Id);
            System.debug('result='+result);

            results.put(invoiceLines[0].Id,result);
            System.debug('results='+results);
        }

        return results;

    }

}