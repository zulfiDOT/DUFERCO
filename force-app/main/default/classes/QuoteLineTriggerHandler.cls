/*
 *   @TestClass: QuoteLineTriggerHandlerTest
 * 
*/
public without sharing class QuoteLineTriggerHandler {

    public static void addFilesToQuote(List<SBQQ__QuoteLine__c> quoteLineList) {

    Set<Id> productIds = new Set<Id>();
    Set<Id> quoteIds = new Set<Id>();
    
        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            productIds.add(ql.SBQQ__Product__c);
            quoteIds.add(ql.SBQQ__Quote__c);
        }
    List<ContentDocumentLink> documentLinkProduct = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                FROM ContentDocumentLink WHERE LinkedEntityId IN: productIds];
    System.debug('Document Product '+documentLinkProduct);

    Set<Id> documentIds = new Set<Id>();
    Map<Id,List<String>> productToDocumentMap = new Map<Id,List<String>>();
        for (ContentDocumentLink doc : documentLinkProduct) {
            documentIds.add(doc.ContentDocumentId);
            if (!productToDocumentMap.containsKey(doc.LinkedEntityId)) {
                productToDocumentMap.put(doc.LinkedEntityId, new List<String>());
            }
            productToDocumentMap.get(doc.LinkedEntityId).add(doc.ContentDocumentId);
        }

    List<ContentDocumentLink> documentLinkQuote = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
        FROM ContentDocumentLink WHERE LinkedEntityId IN: quoteIds];

        System.debug('Document Quote '+documentLinkQuote);

        Map<Id,List<String>> quoteToDocumentMap = new Map<Id,List<String>>();
        for (ContentDocumentLink docQ : documentLinkQuote) {
            documentIds.add(docQ.ContentDocumentId);
            if (!quoteToDocumentMap.containsKey(docQ.LinkedEntityId)) {
                quoteToDocumentMap.put(docQ.LinkedEntityId, new List<String>());
            }
            quoteToDocumentMap.get(docQ.LinkedEntityId).add(docQ.ContentDocumentId);
        }

        Map<Id, List<ContentDocumentLink>> quoteToDocForInsertMap = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> documentToInsert = new List<ContentDocumentLink>();
        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            
            
            if (!quoteToDocForInsertMap.containsKey(ql.SBQQ__Quote__c)) {
                quoteToDocForInsertMap.put(ql.SBQQ__Quote__c, new List<ContentDocumentLink>());
            }
            System.debug('Product To document MAP '+productToDocumentMap);
            
            //skip product senza documenti
            if (!productToDocumentMap.containsKey(ql.SBQQ__Product__c)) continue;

            for (String prodDoc : productToDocumentMap.get(ql.SBQQ__Product__c)) {

                System.debug('Document To Insert MAP '+quoteToDocForInsertMap);
                Boolean temp = false;
                for (ContentDocumentLink docAdded : quoteToDocForInsertMap.get(ql.SBQQ__Quote__c)) {
                    
                    if (docAdded.ContentDocumentId == prodDoc) {
                        temp = true;
                        break;
                    }
                }
                if(temp) continue; 
                
                ContentDocumentLink contentDoc = new ContentDocumentLink();

                /*la quote non contiene nemmeno 1 documento oppure non contiente il documento che sto scorrendo*/
                if (!quoteToDocumentMap.containsKey(ql.SBQQ__Quote__c) ||
                    !quoteToDocumentMap.get(ql.SBQQ__Quote__c).contains(prodDoc)) {
                        contentDoc.LinkedEntityId = ql.SBQQ__Quote__c;
                        contentDoc.ContentDocumentId = prodDoc;
                        contentDoc.ShareType = 'I';
                        contentDoc.Visibility = 'AllUsers';

                        quoteToDocForInsertMap.get(ql.SBQQ__Quote__c).add(contentDoc);
                        documentToInsert.add(contentDoc);  
                    }

                
            }
        }

        System.debug('Document da inserire '+documentToInsert);
        if (!documentToInsert.isEmpty()) {
            
            insert documentToInsert;

        }
    }

    public static void removeFilesToQuote(List<SBQQ__QuoteLine__c> quoteLineList) {

        Set<Id> productIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        
            for (SBQQ__QuoteLine__c ql : quoteLineList) {
                productIds.add(ql.SBQQ__Product__c);
                quoteIds.add(ql.SBQQ__Quote__c);
            }

            
            Map<Id, List<String>> prodIdToDocLink = new Map<Id, List<String>>();
            //Document link dei prodotti le cui quote line sono state eliminate
            for (ContentDocumentLink docProdRemoved : [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                        FROM ContentDocumentLink WHERE LinkedEntityId IN: productIds]) {
                if (!prodIdToDocLink.containsKey(docProdRemoved.LinkedEntityId)) {
                    prodIdToDocLink.put(docProdRemoved.LinkedEntityId, new List<String>());
                }
                prodIdToDocLink.get(docProdRemoved.LinkedEntityId).add(docProdRemoved.ContentDocumentId);
            }

            //Document link delle quote
            Map<Id, List<String>> quoteIdToDoc = new Map<Id, List<String>>();
            // docId ContentDocument
            Map<Id, ContentDocumentLink> docIdToDocLinkQuote = new Map<Id, ContentDocumentLink>();                          
            for (ContentDocumentLink docProd : [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                        FROM ContentDocumentLink WHERE LinkedEntityId IN (Select Id from SBQQ__Quote__c where Id IN: quoteIds)]) {
                if (!quoteIdToDoc.containsKey(docProd.LinkedEntityId)) {
                    quoteIdToDoc.put(docProd.LinkedEntityId, new List<String>());
                }
                
                docIdToDocLinkQuote.put(docProd.ContentDocumentId, docProd);
                quoteIdToDoc.get(docProd.LinkedEntityId).add(docProd.ContentDocumentId);

            }                                    

            //Document link dei prodotti le cui quote line non sono state eliminate
            Map<Id, List<String>> prdNotCancelledToDocId = new Map<Id, List<String>>();                                   
            for (ContentDocumentLink docProd : [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility 
                                                        FROM ContentDocumentLink WHERE LinkedEntityId IN (Select SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIds)]) {
                if (!prdNotCancelledToDocId.containsKey(docProd.LinkedEntityId)) {
                    prdNotCancelledToDocId.put(docProd.LinkedEntityId, new List<String>());
                }
                prdNotCancelledToDocId.get(docProd.LinkedEntityId).add(docProd.ContentDocumentId);
            }

            Map<Id, List<String>> quoteIdProductDocNotCancelled = new Map<Id, List<String>>();
            for (SBQQ__QuoteLine__c qlNotCancelled : [SELECT id, SBQQ__Quote__c, SBQQ__Product__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIds]) {
                
                if (!quoteIdProductDocNotCancelled.containsKey(qlNotCancelled.SBQQ__Quote__c)) {
                    quoteIdProductDocNotCancelled.put(qlNotCancelled.SBQQ__Quote__c, new List<String>());
                }
                System.debug('Prodotti -> Doc ID '+ prdNotCancelledToDocId.get(qlNotCancelled.SBQQ__Product__c));
                System.debug('Quote -> Doc ID '+ quoteIdProductDocNotCancelled.get(qlNotCancelled.SBQQ__Quote__c));
                if (prdNotCancelledToDocId.get(qlNotCancelled.SBQQ__Product__c) != null) {
                    quoteIdProductDocNotCancelled.get(qlNotCancelled.SBQQ__Quote__c).addAll(prdNotCancelledToDocId.get(qlNotCancelled.SBQQ__Product__c));
                }            
            }

            // List ContentDocument da eliminare
            List<ContentDocumentLink> docLinkToRemove = new List<ContentDocumentLink>();
            
            for (SBQQ__QuoteLine__c ql : quoteLineList) {

                if (prodIdToDocLink.get(ql.SBQQ__Product__c) == null) continue; 

                for (String docLink : prodIdToDocLink.get(ql.SBQQ__Product__c)) {
                
                    if (quoteIdToDoc.get(ql.SBQQ__Quote__c) != null && quoteIdToDoc.get(ql.SBQQ__Quote__c).contains(docLink) // check sulla mappa [quote id - lista Id documenti dei prodotti legati alle quote line eliminate]
                        && (quoteIdProductDocNotCancelled.get(ql.SBQQ__Quote__c) == null || // check sulla mappa [quote id - lista Id documenti dei prodotti legati alle quote line non eliminate] 
                            !quoteIdProductDocNotCancelled.get(ql.SBQQ__Quote__c).contains(docLink))) { // se è null oppure contiene l'id del document non cancello il contentDocumentLink
                            if(!docLinkToRemove.contains(docIdToDocLinkQuote.get(docLink)))
                                docLinkToRemove.add(docIdToDocLinkQuote.get(docLink));
                    }

                }              
            }

            System.debug('Document Link da eliminare '+docLinkToRemove);
            if (!docLinkToRemove.isEmpty()) {       
                delete docLinkToRemove;
            }
    }
}