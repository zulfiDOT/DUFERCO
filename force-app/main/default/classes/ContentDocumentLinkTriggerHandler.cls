public with sharing class ContentDocumentLinkTriggerHandler {


    public static void makeProductDocumentVisible(List<ContentDocumentLink> docLinkList) {

        for (ContentDocumentLink doc : docLinkList) {
            String sObjectName = doc.LinkedEntityId.getSobjectType().getDescribe().getName();
            if (sObjectName == 'Product2' || sObjectName == 'SBQQ__Quote__c') {
                doc.Visibility = 'AllUsers';
                doc.ShareType = 'I';
            }
        }
    }

}