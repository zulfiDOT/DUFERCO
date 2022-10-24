/*
 *   @TestClass  :   AccountDatamaxFormControllerTest
*/
public with sharing class AccountDatamaxFormController {

    @AuraEnabled
    public static Map<String,String> createObjFromDatamax(List<SObject> objParams){
        Map<String,String> result = new Map<String,String>();
        try {
            System.debug('PARAMS --> '+objParams);
            Database.SaveResult[] srList = Database.insert(objParams);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    result.put(sr.getId().getSobjectType().getDescribe().getName(), sr.getId());
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ritorna true se l'utente connesso è associato ad un'agenzia admin, storicizzato in un custom metadata type
    @AuraEnabled
    public static Boolean isAdminAgency(){
        User u = [SELECT AgencyCode__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(u != null && u.AgencyCode__c != null) {
            String agencyCode = null;
            if(u.AgencyCode__c.indexOfAny('0123456789') == 0) {
                agencyCode = 'X' + u.AgencyCode__c;
            } else {
                agencyCode = u.AgencyCode__c;
            }

            AdminAgency__mdt aa = AdminAgency__mdt.getInstance(agencyCode);
            if(aa != null) {
                return true;
            }
        }
        return false;
    }

}