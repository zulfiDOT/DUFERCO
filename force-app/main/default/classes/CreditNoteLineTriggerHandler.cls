/**
 * @TestClass: CreditNoteLineTriggerHandlerTest
 */
public with sharing class CreditNoteLineTriggerHandler {

    public static void setProgressivo(List<blng__CreditNoteLine__c> creditNoteLines) {

        CustomAutonumber__c lastDocId = CustomAutonumber__c.getValues('Progressive');
        for(blng__CreditNoteLine__c creditNoteLine : creditNoteLines){
            if (lastDocId != null) {
                creditNoteLine.Progressivo__c = String.valueOf(Integer.valueOf(lastDocId.ProgressiveNumber__c + 1)).leftPad(10,'0');
                lastDocId.ProgressiveNumber__c ++;
                lastDocId.Last_Autonumber__c= creditNoteLine.Progressivo__c;
            }    
        }
        //update creditNoteList;
        update lastDocId;
    }  


    public static void updateCreditNoteLineNumber (List<blng__CreditNoteLine__c> creditNoteLines){

        Set<Id> allCreditNoteIds = new Set<Id>();
        //get all the Invoice records for InvoiceLine
        for (blng__CreditNoteLine__c line : creditNoteLines) {
            allCreditNoteIds.add(line.blng__CreditNote__c);
        }

        //query Invoice to get roll up summary, here blng__NumberOfInvoiceLines__c is Roll up summary field  
        Map<Id,blng__CreditNote__c> creditNoteRecords = new Map<Id,blng__CreditNote__c>([Select NumberOfCreditNoteLines__c From blng__CreditNote__c Where Id IN:allCreditNoteIds]);
        //map contains Id of invoice to latest child number
        Map<Id,Integer> latestChild = new Map<Id,Integer>();

        for(blng__CreditNoteLine__c lineItem : creditNoteLines) {         
            if(latestChild.containsKey(lineItem.blng__CreditNote__c)) {
                lineItem.CreditNoteLineNumber__c = latestChild.get(lineItem.blng__CreditNote__c) + 1;
            }    
            else {

                lineItem.CreditNoteLineNumber__c = creditNoteRecords.get(lineItem.blng__CreditNote__c)?.NumberOfCreditNoteLines__c != null ? creditNoteRecords.get(lineItem.blng__CreditNote__c).NumberOfCreditNoteLines__c + 1 : 1;  
            }
            latestChild.put(lineItem.blng__CreditNote__c, (Integer)lineItem.CreditNoteLineNumber__c);
                
        }   
    }

    public static void resetExportStatus(List<blng__CreditNoteLine__c> creditNoteLines){
        for(blng__CreditNoteLine__c line : creditNoteLines){
            system.debug('line.ExportStatus__c: '+ line.ExportStatus__c);
            system.debug('line.ExportResult__c: '+ line.ExportResult__c);
            line.ExportStatus__c = null;
            line.ExportResult__c = null;
        }    
    }
}