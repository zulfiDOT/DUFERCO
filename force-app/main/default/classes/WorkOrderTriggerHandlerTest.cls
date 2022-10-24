@isTest
private class WorkOrderTriggerHandlerTest {
    @isTest static void myTest() {
        RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business' AND SobjectType = 'Account' AND IsActive = true];
        Account acc = new Account(
            RecordTypeId = rtBusiness.Id,
            Name = 'TestAccount'
        );
        insert acc;
        
        RecordType rtBrandizzazione = [SELECT Id FROM RecordType WHERE DeveloperName = 'Brandizzazione' AND SObjectType = 'WorkOrder' AND IsActive = true];
        WorkOrder wo = new WorkOrder(
            RecordTypeId = rtBrandizzazione.Id,
            AccountId = acc.Id,
            Status = 'In attesa logo'
        );
        insert wo;

        wo.Status = 'Logo caricato';
        update wo;
    }
}