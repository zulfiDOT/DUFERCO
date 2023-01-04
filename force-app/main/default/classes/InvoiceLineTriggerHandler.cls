/*
 *   @TestClass: BatchAPITest
*/
public with sharing class InvoiceLineTriggerHandler {
    

    public static void updateInvoiceLineNumber (List<blng__InvoiceLine__c> invoiceLineList){

        Set<Id> allInvoiceIds = new Set<Id>();
        //get all the Invoice records for InvoiceLine
        for (blng__InvoiceLine__c line : invoiceLineList) {
            allInvoiceIds.add(line.blng__Invoice__c);
        }

        //query Invoice to get roll up summary, here blng__NumberOfInvoiceLines__c is Roll up summary field  
        Map<Id,blng__Invoice__c> invoiceRecords = new Map<Id,blng__Invoice__c>([Select blng__NumberOfInvoiceLines__c From blng__Invoice__c Where Id IN:allInvoiceIds]);
        //map contains Id of invoice to latest child number
        Map<Id,Integer> latestChild = new Map<Id,Integer>();

        for(blng__InvoiceLine__c lineItem : invoiceLineList) {         
            if(latestChild.containsKey(lineItem.blng__Invoice__c)) {
                lineItem.InvoiceLineNumber__c = latestChild.get(lineItem.blng__Invoice__c) + 1;
            }    
            else {

                lineItem.InvoiceLineNumber__c = invoiceRecords.get(lineItem.blng__Invoice__c)?.blng__NumberOfInvoiceLines__c != null ? invoiceRecords.get(lineItem.blng__Invoice__c).blng__NumberOfInvoiceLines__c + 1 : 1;  
            }
            latestChild.put(lineItem.blng__Invoice__c, (Integer)lineItem.InvoiceLineNumber__c);
                
        }   
    }

    public static void setProgressivo(List<blng__InvoiceLine__c> invoiceLineList) {

        CustomAutonumber__c lastDocId = CustomAutonumber__c.getValues('Progressive');
        for(blng__InvoiceLine__c invoiceLine : invoiceLineList){
            if (lastDocId != null) {
                invoiceLine.Progressivo__c = String.valueOf(Integer.valueOf(lastDocId.ProgressiveNumber__c + 1)).leftPad(10,'0');
                lastDocId.ProgressiveNumber__c ++;
                lastDocId.Last_Autonumber__c= invoiceLine.Progressivo__c;
            }    
        }
        //update creditNoteList;
        update lastDocId;
    }
}