/*
 *   @TestClass: AttachmentBehaviorSettingsControllerTEST
*/
public class ContentDocumentLinkTriggerHandler {

    public static void makeProductDocumentVisible(List<ContentDocumentLink> docLinkList) {
        for (ContentDocumentLink doc : docLinkList) {
            String sObjectName = doc.LinkedEntityId.getSobjectType().getDescribe().getName();
            if (sObjectName == 'Product2' || sObjectName == 'SBQQ__Quote__c') {
                doc.Visibility = 'AllUsers';
                doc.ShareType = 'I';
            }
        }
    }

    /* quando viene creato un documento su una quote baslab, viene messo il flag per la generazione della envelope namirial */
    public static void createNamirialEnvelope(List<ContentDocumentLink> docLinkList) {
        Set<Id> quoteIds = new Set<Id>();
        for(ContentDocumentLink doc : docLinkList) {
            String sObjectName = doc.LinkedEntityId.getSobjectType().getDescribe().getName();
            if (sObjectName == 'SBQQ__Quote__c') {
                quoteIds.add(doc.LinkedEntityId);
            }
        }
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : [SELECT SBQQ__Status__c, DocumentsGenerated__c, PricebookType__c, PrevistoInvioPDF__c, ParentQuote__c, ParentQuote__r.PrevistoInvioPDF__c
                                    FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
            /* nel caso di offerta baslab, che ancora non ha il flag DocumentsGenerated__c, se è parent deve avere il flag firma digitale, altrimenti il padre deve averlo */
            if(quote.SBQQ__Status__c == '1' && quote.PricebookType__c == 'Bsb' && !quote.DocumentsGenerated__c && ((quote.ParentQuote__c == null && quote.PrevistoInvioPDF__c) || (quote.ParentQuote__c != null && quote.ParentQuote__r.PrevistoInvioPDF__c))) {
                quote.DocumentsGenerated__c = true;
                quotesToUpdate.add(quote);
            }
        }
        update quotesToUpdate;
    }

}