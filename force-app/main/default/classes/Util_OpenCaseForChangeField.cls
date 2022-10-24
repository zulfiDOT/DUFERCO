/*
 *   @Author : Carmine Romano
 *   @TestClass  :   Util_OpenCaseForChangeFieldTest
*/
public with sharing class Util_OpenCaseForChangeField {
    
    
    public static void createFieldChange(Map<Id, SObject> oldMap, List<SObject> newList) {


        Boolean isIntegrationUser = [Select IntegrationUser__c from User Where Id = :UserInfo.getUserId()][0].IntegrationUser__c;
        String sObjName = newList.get(0).Id.getSObjectType().getDescribe().getName();
        WrapperSchema wrapSchema = getFieldSet('FieldNotEditable_'+sObjName.removeEnd('__c'),sObjName);
        Map<Id, List<FieldChange__c>> accFieldChangedMap = new Map<Id, List<FieldChange__c>>();
        List<Case> casesToInsert = new List<Case>();
        Set<Id> accountWithCase = new Set<Id>();
        List<String> AccountIdList = new List<String>();
        String query = 'SELECT id, DatamaxCustomerCode__c, UpdateFromDatamax__c, (SELECT Id from Cases WHERE Reason = \'Richiesta Aggiornamento Anagrafica\' AND Status != \'Closed\') FROM Account WHERE Id IN';
        //AMS - FIX #47085 INIZIO
        String queryObj='';
        //String queryObj = wrapSchema.isAccount ? ': newList' : ' (Select '+wrapSchema.accField+' from '+sObjName+' where Id IN:newList)';
        if (wrapSchema.isAccount) {
            queryObj =  ': newList' ;
        } else {
            for (SObject obj : newList) {
                AccountIdList.add((String)obj.get(wrapSchema.accField));
                System.debug('@GO wrapSchema.accField Value: '+(String)obj.get(wrapSchema.accField));
            }
            queryObj =  ': AccountIdList' ;
        } 
        //AMS - FIX #47085 FINE
        query+= queryObj;
        Map<Id,SObject> accToCase = new Map<Id,SObject>(Database.query(query));

        for (SObject obj : newList) {
            Id accId = wrapSchema.isAccount ? obj.Id : (Id)obj.get(wrapSchema.accField);
            System.debug('@GO wrapSchema.isAccount '+wrapSchema.isAccount);
            System.debug('@GO obj.Id '+obj.Id);
            System.debug('@GO wrapSchema.accField '+wrapSchema.accField);
            System.debug('@GO query '+query);
            System.debug('@GO queryObj '+queryObj);
            System.debug('@GO accId '+accId);
            System.debug('@GO accToCase '+accToCase);
            Boolean isDatamax = (Boolean)accToCase.get(accId).get('UpdateFromDatamax__c');
            System.debug('@GO isDatamax '+isDatamax);
            if (!accountWithCase.contains(accId) && accToCase.get(accId).getSObjects('Cases') == null && accToCase.get(accId).get('DatamaxCustomerCode__c') != null && isIntegrationUser && !isDatamax) {
                Case c = new Case();
                c.AccountId = accId;
                c.Reason = 'Richiesta Aggiornamento Anagrafica';
                c.Subject = 'Richiesta Aggiornamento Anagrafica';
                casesToInsert.add(c);
                accountWithCase.add(accId);
            }        
            for(Schema.FieldSetMember fieldSetMemberObj : wrapSchema.fieldSet){    
                
                if(obj.get(fieldSetMemberObj.getFieldPath()) != oldMap.get(obj.Id).get(fieldSetMemberObj.getFieldPath()) && accToCase.get(accId).get('DatamaxCustomerCode__c') != null && isIntegrationUser && !isDatamax){
                    FieldChange__c fc = new FieldChange__c();
                    fc.Label__c = fieldSetMemberObj.getLabel();
                    fc.ApiName__c = fieldSetMemberObj.getFieldPath();
                    fc.Value__c = (String)obj.get(fieldSetMemberObj.getFieldPath());
                    fc.Object__c = sObjName;
                    obj.put(fieldSetMemberObj.getFieldPath(), oldMap.get(obj.Id).get(fieldSetMemberObj.getFieldPath()));

                    if (!accFieldChangedMap.containsKey(accId)) {
                        accFieldChangedMap.put(accId, new List<FieldChange__c>());
                    }
                    accFieldChangedMap.get(accId).add(fc);
                    
                }
            }
        }
        System.debug('@@ Map Change Field '+accFieldChangedMap);
        if (!casesToInsert.isEmpty() && !accFieldChangedMap.isEmpty()) {
            insert casesToInsert;
        }

        String queryOnCase = 'Select Id, AccountId From Case Where  Reason = \'Richiesta Aggiornamento Anagrafica\' AND Status != \'Closed\' AND AccountId IN'+queryObj;
        List<FieldChange__c> fcToInsert = new List<FieldChange__c>();
        if (!accFieldChangedMap.isEmpty()) {
            for (Case caseItem : Database.query(queryOnCase)) {
                for (FieldChange__c fc : accFieldChangedMap?.get(caseItem.AccountId)) {
                    fc.Case__c = caseItem.Id;
                }
                fcToInsert.addAll(accFieldChangedMap.get(caseItem.AccountId));
            }
            
        }
        System.debug('@@ List Change Field '+fcToInsert);
        if (fcToInsert != null) {
            insert fcToInsert;
        }

    }

    public static WrapperSchema getFieldSet(String fieldSetName, String objectName) {
        WrapperSchema wr = new WrapperSchema();
        wr.isAccount = objectName == 'Account';
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = SObjectTypeObj.getDescribe();
        wr.isCustom = DescribeSObjectResultObj.isCustom();
        wr.accField = wr.isCustom ? 'AccountId__c' : 'AccountId';
        wr.fieldSet = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName).getFields();
    
        return wr; 
    }

    public with sharing class WrapperSchema{
        Boolean isAccount;
        Boolean isCustom;
        String accField;
        List<Schema.FieldSetMember> fieldSet;
    }
}