/*
 *   @TestClass: WizardSetupUtility_Test
*/
public without sharing class WizardSetupUtility {
    
    @AuraEnabled
    public static Map<String,Object> queryAccountBeforeInsert(String whereConditions){
        /*String query = '';
        Map<String,Object> result = new Map<String,Object>();
        query += 'Select id, OwnerId From Account Where '+whereConditions;
        System.debug('Query --> '+query);
        try {
            List<Account> accList = Database.query(query);
            if (!accList.isEmpty()) {
                result.put('recordFound', true);
                UserRecordAccess checkpermissions = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: UserId AND RecordId =:accList[0].Id];
                if(checkpermissions.HasReadAccess==false){
                    result.put('records', null);
                }else{
                    result.put('records', accList);
                }
            }else{
                result.put('recordFound', false);
            }
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }
        return result;*/

        String query = '';
        Map<String,Object> result = new Map<String,Object>();
        query += 'Select id From Account Where '+whereConditions;
        System.debug('Query --> '+query);
        try {
            List<Account> accList = Database.query(query);
            if (!accList.isEmpty()) {
                result.put('recordFound', true);
                result.put('records', accList);
            }else {
                result.put('recordFound', false);
            }
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }
        return result;
    }
}