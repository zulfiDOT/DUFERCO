@isTest
public class Batch_AccountContactRelation_InsertTest {
	@isTest
    public static void createAcr(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account parentAccount = new Account(Name = 'Test parentAccount',DatamaxCustomerCode__c='abcd1234',
                                            BillingCity = 'Test City', BillingState = 'Test State', 
                                            BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                            BillingCountry = 'Test Country', Phone = '123456', RecordTypeId = recordTypeId);
        insert parentAccount;
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', ParentId=parentAccount.Id,
                                         BillingCountry = 'Test Country', Phone = '123456',FiscalCode__c= '91234567891', RecordTypeId = recordTypeId);
        insert objAccount;
        
        Account objAccountPartner = new Account(Name = 'Test Acc2', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId(),
                                         BillingCountry = 'Test Country', AgencyCodeDatamax__c = '123456',FiscalCode__c= '91234567881');
        insert objAccountPartner;
        
        Contact con = new Contact(FirstName='Test',LastName='Cont',DatamaxContactCode__c='abc003',AccountId =parentAccount.Id);
        insert con;

        Set<Id> accuntSet = new Set<Id>();
        accuntSet.add(parentAccount.Id);
        Batch_AccountContactRelation_Insert btch = new Batch_AccountContactRelation_Insert(accuntSet);
        Database.executeBatch(btch); 

        
    }
}