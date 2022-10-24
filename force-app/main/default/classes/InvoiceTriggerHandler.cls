/*
 *   @TestClass  :   InvoiceTriggerHandlerTest
*/
public class InvoiceTriggerHandler {
    
    public static void setInvoiceOnPayment (List<blng__Invoice__c> invoiceList){
    
        Set<Id> quoteId = new Set<Id>();
        Set<Id> orderId = new Set<Id>();
        Set<Id> usageSummaryId = new Set<Id>();
        Set<Id> invoiceIdWithOrder = new Set<Id>();
        Set<Id> invoiceIdWithoutOrder = new Set<Id>();
        List<blng__Payment__c> paymentList = new List<blng__Payment__c>();
        Map<Id,blng__Invoice__c> orderIdToInvoiceMap = new Map<Id,blng__Invoice__c>();
        Map<Id,blng__Invoice__c> quoteIdToInvoiceMap = new Map<Id,blng__Invoice__c>();
        Map<Id,blng__InvoiceLine__c> orderIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,blng__InvoiceLine__c> usageSummaryIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,blng__InvoiceLine__c> quoteIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,Id> usageIdToMainIdMap = new Map<Id,Id>();

        for(blng__Invoice__c invoice : invoiceList) {
            if(invoice.blng__Order__c != null) {
                invoiceIdWithOrder.add(invoice.Id);
            }else if (invoice.blng__Order__c == null && invoice.InvoiceLineCount__c > 0) {
                invoiceIdWithoutOrder.add(invoice.Id);
            }
        }

        if(!invoiceIdWithOrder.isEmpty()) {
            for(blng__Invoice__c inv : [SELECT blng__Order__r.SBQQ__Quote__c, blng__Order__c, Id
                                        FROM blng__Invoice__c
                                        WHERE Id IN : invoiceIdWithOrder
                                        AND BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '9']) {
                orderId.add(inv.blng__Order__c);
                quoteId.add(inv.blng__Order__r.SBQQ__Quote__c);
                orderIdToInvoiceMap.put(inv.blng__Order__c, inv);
                quoteIdToInvoiceMap.put(inv.blng__Order__r.SBQQ__Quote__c, inv);
            }
        }

        System.debug('orderIdToInvoiceMap --> '+orderIdToInvoiceMap);
        System.debug('quoteIdToInvoiceMap --> '+quoteIdToInvoiceMap);

        if(!invoiceIdWithoutOrder.isEmpty()) {
            for(blng__InvoiceLine__c invLine : [SELECT blng__Invoice__c, blng__OrderProduct__c, blng__OrderProduct__r.OrderId,
                                                        blng__OrderProduct__r.Order.SBQQ__Quote__c, blng__UsageSummary__c
                                                FROM blng__InvoiceLine__c
                                                WHERE blng__Invoice__c IN :invoiceIdWithoutOrder
                                                AND (blng__Invoice__r.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '9' 
                                                OR blng__Invoice__r.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '10')]) {
                if(invLine.blng__UsageSummary__c != null) {
                    usageSummaryId.add(invLine.blng__UsageSummary__c);
                    usageSummaryIdToInvoiceLineMap.put(invLine.blng__UsageSummary__c, invLine);
                }
                if(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c != null) {
                    quoteId.add(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c);
                    quoteIdToInvoiceLineMap.put(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c, invLine);
                }
            }
        }

        if(!usageSummaryId.isEmpty()) {
            for(blng__Usage__c usage : [SELECT blng__UsageSummary__c, MainUsage__c, MainUsage__r.blng__UsageSummary__c
                                        FROM blng__Usage__c
                                        WHERE blng__UsageSummary__c IN :usageSummaryId]) {
                if(usage.MainUsage__c != null) {
                    usageSummaryId.add(usage.MainUsage__r.blng__UsageSummary__c);
                    usageSummaryIdToInvoiceLineMap.put(usage.MainUsage__r.blng__UsageSummary__c, usageSummaryIdToInvoiceLineMap.get(usage.blng__UsageSummary__c));
                    usageIdToMainIdMap.put(usage.Id, usage.MainUsage__c);
                }
            }
        }

        System.debug('usageSummaryIdToInvoiceLineMap --> '+usageSummaryIdToInvoiceLineMap);
        System.debug('quoteIdToInvoiceLineMap --> '+quoteIdToInvoiceLineMap);

        for(blng__Payment__c payment : [SELECT Id, Order__c, Quote__c, Usage__c, Usage__r.blng__UsageSummary__c, Usage__r.MainUsage__r.blng__UsageSummary__c
                                        FROM blng__Payment__c
                                        WHERE blng__Invoice__c = null
                                        AND blng__Status__c = 'Draft'
                                        AND (Order__c IN : orderId OR Quote__c IN : quoteId OR Usage__r.blng__UsageSummary__c IN : usageSummaryId)]) {
            if (payment.Order__c != null && orderIdToInvoiceMap.get(payment.Order__c) != null) {
                payment.blng__Invoice__c = orderIdToInvoiceMap.get(payment.Order__c).Id;
                paymentList.add(payment);
            } else if (payment.Quote__c != null && quoteIdToInvoiceMap.get(payment.Quote__c) != null) {
                payment.blng__Invoice__c = quoteIdToInvoiceMap.get(payment.Quote__c).Id;
                paymentList.add(payment);
            } else if (payment.Usage__r?.blng__UsageSummary__c != null && usageIdToMainIdMap.get(payment.Usage__c) != null && usageSummaryIdToInvoiceLineMap.get(usageIdToMainIdMap.get(payment.Usage__c)) != null) {
                payment.blng__Invoice__c = usageSummaryIdToInvoiceLineMap.get(usageIdToMainIdMap.get(payment.Usage__c)).blng__Invoice__c;
                paymentList.add(payment);
            } else if (payment.Usage__r?.blng__UsageSummary__c != null && usageSummaryIdToInvoiceLineMap.get(payment.Usage__r.blng__UsageSummary__c) != null) {
                payment.blng__Invoice__c = usageSummaryIdToInvoiceLineMap.get(payment.Usage__r.blng__UsageSummary__c).blng__Invoice__c;
                paymentList.add(payment);
            } else if (payment.Quote__c != null && quoteIdToInvoiceLineMap.get(payment.Quote__c) != null) {
                payment.blng__Invoice__c = quoteIdToInvoiceLineMap.get(payment.Quote__c).blng__Invoice__c;
                paymentList.add(payment);
            }
        }
        
        if(!paymentList.isEmpty()) {
            update paymentList;
        }
    }

    public static void setCustomAutonumber(List<blng__Invoice__c> invoiceList) {
        
        Set<Id> invoiceIdWithOrder = new Set<Id>();
        Set<Id> invoiceIdWithoutOrder = new Set<Id>();
        Map<String, Set<blng__Invoice__c>> areaToInvoiceList = new Map<String, Set<blng__Invoice__c>>();
        List<CustomAutonumber__c> autonumberList = new List<CustomAutonumber__c>();
        List<blng__Invoice__c> invoiceToUpdate = new List<blng__Invoice__c>();

        for (blng__Invoice__c invoice : invoiceList) {
            
            if (invoice.blng__Order__c != null && String.isBlank(invoice.Progressivo_fattura__c)) {
                invoiceIdWithOrder.add(invoice.Id);

            }else if (invoice.blng__Order__c == null && invoice.InvoiceLineCount__c > 0 && String.isBlank(invoice.Progressivo_fattura__c)) {
                invoiceIdWithoutOrder.add(invoice.Id);
            }
        }

        if (!invoiceIdWithOrder.isEmpty()) {

            for (blng__Invoice__c inv : [SELECT Id, Name, blng__Order__r.Pricebook2.Area__c FROM blng__Invoice__c WHERE Id IN : invoiceIdWithOrder]) {             
                    
                if (!areaToInvoiceList.containsKey(inv.blng__Order__r.Pricebook2.Area__c)) {
                    areaToInvoiceList.put(inv.blng__Order__r.Pricebook2.Area__c, new Set<blng__Invoice__c>());
                }
                areaToInvoiceList.get(inv.blng__Order__r.Pricebook2.Area__c).add(inv);
            }   
        }

        if (!invoiceIdWithoutOrder.isEmpty()) {
            
            for (blng__InvoiceLine__c invLine : [SELECT Id,blng__OrderProduct__r.Order.Pricebook2.Area__c, blng__Invoice__c, blng__Invoice__r.Progressivo_fattura__c, blng__Invoice__r.Name FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :invoiceIdWithoutOrder]) {
       
                if (!areaToInvoiceList.containsKey(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c)) {
                    areaToInvoiceList.put(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c, new Set<blng__Invoice__c>());
                }
                areaToInvoiceList.get(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c).add(invLine.blng__Invoice__r);
            }
        }

        for (String area : areaToInvoiceList.keySet()) {

            CustomAutonumber__c autonumber = CustomAutonumber__c.getValues(area);
            if (autonumber != null) {
                for (blng__Invoice__c invoice : areaToInvoiceList.get(area)) {
                    
                    invoice.Progressivo_fattura__c = String.valueOf(Integer.valueOf(autonumber.ProgressiveNumber__c + 1)).leftPad(8,'0');
                    autonumber.ProgressiveNumber__c ++;
                    autonumber.Last_Autonumber__c= invoice.Progressivo_fattura__c;
                    invoiceToUpdate.add(invoice);
                }
            autonumberList.add(autonumber);
            }
        }

        if (!autonumberList.isEmpty()) {
            
            update autonumberList;
        }

        if (!invoiceToUpdate.isEmpty()) {
            
            update invoiceToUpdate;
        }
    }
    
    public static void setDocumentId(List<blng__Invoice__c> invoiceList) {

        CustomAutonumber__c lastDocId = CustomAutonumber__c.getValues('DocumentId');
        for(blng__Invoice__c invoice : invoiceList){
            if (lastDocId != null) {
                invoice.DocumentId__c = String.valueOf(-Integer.valueOf(lastDocId.ProgressiveNumber__c + 1));
                lastDocId.ProgressiveNumber__c ++;
                lastDocId.Last_Autonumber__c= invoice.DocumentId__c;
            }    
        }
        //update creditNoteList;
        update lastDocId;
    }

    public static void setDueDate(List<blng__Invoice__c> invoiceList) {
        Map<String, InvoiceDueDateCalculation__mdt> iddcMap = InvoiceDueDateCalculation__mdt.getAll();
        System.debug('iddcMap='+iddcMap);

        for(blng__Invoice__c invoice : invoiceList) {
            System.debug('invoice.BillingProfile__c='+invoice.BillingProfile__c);
            if(invoice.BillingProfile__c != null) {
                System.debug('invoice.BillingProfile__r.PaymentConditions__c='+invoice.BillingProfile__r.PaymentConditions__c);
                if(invoice.BillingProfile__r.PaymentConditions__c != null) {
                    String paymentConditions = null;
                    if(invoice.BillingProfile__r.PaymentConditions__c.indexOfAny('0123456789') == 0) {
                        paymentConditions = 'X' + invoice.BillingProfile__r.PaymentConditions__c;
                    } else {
                        paymentConditions = invoice.BillingProfile__r.PaymentConditions__c;
                    }

                    System.debug('paymentConditions='+paymentConditions);
                    System.debug('invoice.blng__InvoiceDate__c='+invoice.blng__InvoiceDate__c);
                    InvoiceDueDateCalculation__mdt iddc = iddcMap.get(paymentConditions);
                    if(iddc != null) {
                        invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c.addDays(Integer.valueOf(iddc.NofDays__c));
                    } else {
                        invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
                    }
                } else {
                    invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
                }
            } else {
                invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
            }
            System.debug('invoice.blng__DueDate__c='+invoice.blng__DueDate__c);
        }

        update invoiceList;
    }

    //Lutech AT 07/09/2022  CR#44604 - Controlli pre fatturazione
    public static void setCustomAutonumberForStatusPosted(List<blng__Invoice__c> invoiceList,Map<Id,blng__Invoice__c> invoiceOldMap) {
        Set<Id> invoiceIds =  new Set<Id>();
        for(blng__Invoice__c bIn : invoiceList){
            if(invoiceOldMap.get(bIn.Id).blng__InvoiceStatus__c != bIn.blng__InvoiceStatus__c && bIn.blng__InvoiceStatus__c == 'Posted'){
                invoiceIds.add(bIn.Id);
            }
        }
        if(invoiceIds.size() > 0){
            system.debug('invoiceIds : '+invoiceIds.size());
            InvoiceAfterPostingLogicsBatch batch = new InvoiceAfterPostingLogicsBatch(invoiceIds);
            Database.executeBatch(batch);
            //Database.executeBatch(new InvoiceAfterPostingLogicsBatch(invoiceIds));
        }
    }

}