/***
 * Name         :   UpdateCustomerAddress
 * Author       :   Ezio Dal Bo @TEN
 * Create       :   2022-08-04
 * @TestClass: AddressTriggerHandlerTest
 */ 
global class UpdateCustomerAddress  implements Database.Batchable<sObject>, Database.Stateful {

    global Map<Id,Address__c> mAddress = new Map<Id,Address__c>();
    global List<String> queryFields = new List<String>{
        'Id',
        'ZipCode__c',
        'City__c',
        'StreetName__c',
        'StreetNumber__c',
        'Country__c',
        'Province__c',
        'Type__c',
        'AccountId__r.ParentId' 
    };

    /**
     * Name     :   UpdateCustomerAddress
     */
    global UpdateCustomerAddress(Map<Id,Address__c> addresses) {
        mAddress = addresses;
    }

    /**
     * Name     :   start
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> keys = mAddress.keySet();
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM Address__c ';
        query += 'WHERE AccountId__r.ParentId IN:keys AND Type__c=\'9\'';
        return Database.getQueryLocator(query);
    }
    
    /**
     * Name     :   execute
     */ 
    global void execute(Database.BatchableContext BC, List<Address__c> scope) {

        try {
            for (Address__c address : scope) {
                if (mAddress.containsKey(address.AccountId__r.ParentId)) {
                    Address__c a = mAddress.get(address.AccountId__r.ParentId);
                    address.ZipCode__c = a.ZipCode__c;
                    address.City__c = a.City__c;
                    address.StreetName__c = a.StreetName__c;
                    address.StreetNumber__c = a.StreetNumber__c;
                    address.Country__c = a.Country__c;
                    address.Province__c = a.Province__c;
                }
            }

            update scope;
        }
        catch(Exception exc) {
            System.debug('An exception occurred during execution : '+exc.getMessage());
            throw exc;
        }
    }

    /**
     * Name     :   finish
     */
    global void finish(Database.BatchableContext BC) {
    }
}