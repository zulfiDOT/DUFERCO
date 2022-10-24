/*
 *   @TestClass  :   CreditNoteTriggerHandlerTest
*/
public with sharing class CreditNoteTriggerHandler {
    
    public static void setCustomAutonumber(List<blng__CreditNote__c> creditNoteList) {

        Set<Id> creditNoteStartingIds = new Set<Id>(); 
        List<blng__CreditNote__c> creditNoteToCheck = new List<blng__CreditNote__c>();
        Set<Id> creditNoteIdWithOrder = new Set<Id>();
        Set<Id> creditNoteIdWithoutOrder = new Set<Id>();
        Map<String, Set<blng__CreditNote__c>> areaToCreditNoteList = new Map<String, Set<blng__CreditNote__c>>();
        List<CustomAutonumber__c> autonumberList = new List<CustomAutonumber__c>();
        List<blng__CreditNote__c> creditNoteToUpdate = new List<blng__CreditNote__c>();
        Set<Id> invoiceIds = new Set<Id>();
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>();
        system.debug('inside setCustomAutonumber');

        for (blng__CreditNote__c creditNote : creditNoteList) {
            creditNoteStartingIds.add(creditNote.id);
        }    
        creditNoteToCheck = [SELECT Id, Name, blng__RelatedInvoice__r.Name, blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c, blng__CreditNote__c.ProgressivoNotaCredito__c, blng__RelatedInvoice__r.InvoiceLineCount__c  FROM blng__CreditNote__c WHERE id IN :creditNoteStartingIds];

        for (blng__CreditNote__c creditNote : creditNoteToCheck) {
            system.debug('creditNote.blng__RelatedInvoice__r.blng__Order__c: '+creditNote.blng__RelatedInvoice__r.blng__Order__c);
            
            if (creditNote.blng__RelatedInvoice__r.blng__Order__c != null && String.isBlank(creditNote.ProgressivoNotaCredito__c)) {
                creditNoteIdWithOrder.add(creditNote.Id);

            }else if (creditNote.blng__RelatedInvoice__r.blng__Order__c == null && creditNote.blng__RelatedInvoice__r.InvoiceLineCount__c > 0 && String.isBlank(creditNote.ProgressivoNotaCredito__c)) {
                creditNoteIdWithoutOrder.add(creditNote.Id);
                invoiceIds.add(creditNote.blng__RelatedInvoice__c);
            }
        }

        system.debug('creditNoteIdWithOrder: '+ creditNoteIdWithOrder);
        system.debug('creditNoteIdWithoutOrder: '+ creditNoteIdWithoutOrder);
        system.debug('invoiceIds: '+ invoiceIds);

        if (!creditNoteIdWithOrder.isEmpty()) {

            for (blng__CreditNote__c creditNote : [SELECT Id, Name, blng__RelatedInvoice__r.Name, blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c FROM blng__CreditNote__c WHERE Id IN : creditNoteIdWithOrder]) {             
                    
                if (!areaToCreditNoteList.containsKey(creditNote.blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c)) {
                    areaToCreditNoteList.put(creditNote.blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c, new Set<blng__CreditNote__c>());
                }
                areaToCreditNoteList.get(creditNote.blng__RelatedInvoice__r.blng__Order__r.Pricebook2.Area__c).add(creditNote);
            }   
        }

        if (!creditNoteIdWithoutOrder.isEmpty()) {

            invoiceLines = [SELECT Id,blng__OrderProduct__r.Order.Pricebook2.Area__c, blng__Invoice__c, blng__Invoice__r.Progressivo_fattura__c, blng__Invoice__r.Name FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :invoiceIds];
            for(String creditNoteId: creditNoteIdWithoutOrder){
                for (blng__InvoiceLine__c invLine : invoiceLines) {
                    if (!areaToCreditNoteList.containsKey(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c)) {
                        areaToCreditNoteList.put(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c, new Set<blng__CreditNote__c>());
                    }
                    areaToCreditNoteList.get(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c).add(new blng__CreditNote__c(id = creditNoteId));
                }            
            }
        }

        for (String area : areaToCreditNoteList.keySet()) {

            CustomAutonumber__c autonumber = CustomAutonumber__c.getValues(area);
            if (autonumber != null) {
                for (blng__CreditNote__c creditNote : areaToCreditNoteList.get(area)) {
                    
                    creditNote.ProgressivoNotaCredito__c = String.valueOf(Integer.valueOf(autonumber.ProgressiveNumber__c + 1)).leftPad(8,'0');
                    autonumber.ProgressiveNumber__c ++;
                    autonumber.Last_Autonumber__c= creditNote.ProgressivoNotaCredito__c;
                    creditNoteToUpdate.add(creditNote);
                }
            autonumberList.add(autonumber);
            }
        }

        if (!autonumberList.isEmpty()) {
            
            update autonumberList;
        }

        if(creditNoteToUpdate.size() > 0){
            for(blng__CreditNote__c creditNoteFromTrigger: creditNoteList){
                for(blng__CreditNote__c cNoteToUpdate: creditNoteToUpdate){
                    if(creditNoteFromTrigger.id == cNoteToUpdate.id){
                        creditNoteFromTrigger.ProgressivoNotaCredito__c = cNoteToUpdate.ProgressivoNotaCredito__c;
                    }
                }
            }
        }

        /*if (!creditNoteToUpdate.isEmpty()) {
            
            update creditNoteToUpdate;
        }*/
    }

    public static void setDocumentId(List<blng__CreditNote__c> creditNoteList) {

        CustomAutonumber__c lastDocId = CustomAutonumber__c.getValues('DocumentId');
        for(blng__CreditNote__c creditNote : creditNoteList){
            if (lastDocId != null) {
                creditNote.DocumentId__c = String.valueOf(-Integer.valueOf(lastDocId.ProgressiveNumber__c + 1));
                lastDocId.ProgressiveNumber__c ++;
                lastDocId.Last_Autonumber__c= creditNote.DocumentId__c;
            }    
        }
        //update creditNoteList;
        update lastDocId;
    }

    public static void resetStatusKoine(List<blng__CreditNote__c> creditNoteList){
        for(blng__CreditNote__c creditNote : creditNoteList){
            system.debug('creditNote ExportStatusKoine__c: '+creditNote.ExportStatusKoine__c);
            system.debug('creditNote ExportDetailsKoine__c: '+creditNote.ExportDetailsKoine__c);
            creditNote.ExportStatusKoine__c = null;
            creditNote.ExportDetailsKoine__c = null;
        }    
    }
    
     


}