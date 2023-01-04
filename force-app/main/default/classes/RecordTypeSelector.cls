/*
 *   @TestClass: RecordTypeSelectorTest
*/
public class RecordTypeSelector{

    public static Map<Id, String> recordtypemap;

    @AuraEnabled(cacheable=true)
    public static Map<Id, String> fetchRecordTypeValues(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.getName() != 'Principale' && rt.getName().trim() != '')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap;

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFieldSet(String rType){
        try {
            
            String fldSetName = rType == 'Persona Fisica' ? 'PersonAccountHiddenField' : 'BusinessHiddenField';
            List<String> fieldSetList = new List<String>();
            for (Schema.FieldSetMember fs : Schema.SObjectType.Account.fieldSets.getMap().get(fldSetName).getFields()) {
                
                fieldSetList.add(fs.getFieldPath());
            }

            return fieldSetList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> queryRecords(String query){

        return Database.query(query);
    }

    @AuraEnabled
    public static Map<String,Object> queryAccountBeforeInsert(String whereConditions){
        //Effettuiamo la ricerca preliminare dell'account without sharing
        return WizardSetupUtility.queryAccountBeforeInsert(whereConditions);
    }

}