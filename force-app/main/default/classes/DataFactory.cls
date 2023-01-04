/*
 *   @Class: IndividualManageClass
*/

public class DataFactory {
    
    public static Account create_PersonAccount() {
        String personAccountRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account result = new Account(
            FirstName = 'TestName',
            LastName = 'TestSurname',
            PersonEmail =  'personalEmail@gmail.com',
            Phone = '12345679',
            PersonMobilePhone = '16844838',
            RecordTypeId = personAccountRecordType,
            PrivacyCommerciale__c = true,
            PrivacyProfilazioneConsumo__c = true
        );
        
        return result;
    }
    
    public static Account create_BusinessAccount() {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType where SobjectType='Account' and Developername != 'PersonAccount' Limit 1];
        
        Account result = new Account(
            Name = 'RagioneSociale',
            Phone = '12345679',
            RecordTypeId = personAccountRecordType.Id,
            PrivacyCommerciale__c = false,
            PrivacyProfilazioneConsumo__c = false
        );
        
        return result;
    }
    
 
    public static Contact create_Contact(String TestAccount) {
        Contact result = new Contact(
            FirstName = 'AAAATest2',
            LastName = 'AAATest2',
            Phone = '0255555566',
            Email =  'medicoontactemail@gmail.com',
            AccountId = TestAccount
        );
        
        return result;
    }
    
    public static Case create_Case(String TestAccount, String TestContact) {   
        Case result = new Case(
            AccountId = TestAccount,
            ContactId = TestContact
        ); 
        
        return result;
    }

    public static Opportunity create_Opportunity(String TestAccount) {   
        Opportunity result = new Opportunity(
            AccountId = TestAccount,
            Name = 'Test Opportunity',
            StageName = 'New',
            CloseDate = System.today() + 10
        ); 
        
        return result;
    }

    public static SBQQ__Quote__c create_Quote(String TestAccount, String TestOpportunity) {   
        SBQQ__Quote__c result = new SBQQ__Quote__c(
            SBQQ__Account__c = TestAccount,
            SBQQ__Opportunity2__c =  +TestOpportunity,
            PrivacyB__c = true,
            PrivacyC__c = true,
            CommunicationMobile__c = '3334545666',
            CommunicationEmail__c = 'test@test.it'
        ); 
        
        return result;
    }
    

}