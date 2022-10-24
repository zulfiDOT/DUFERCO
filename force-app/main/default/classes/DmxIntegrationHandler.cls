/*
 *   @TestClass  :   DmxIntegrationHandlerTest
*/
public class DmxIntegrationHandler {
    
    @future(callout=true)
    public static void syncWithDatamax(Set<Id> accountIds) {
        Map<Id,DmxAccount> dmxAccountPerAccountId = new Map<Id,DmxAccount>();
        Map<Id,Account> accountPerAccountId = new Map<Id,Account>();
        for(Account a : [SELECT IsPersonAccount, Agent__r.AgentCode__c, Company__c, Email__c, Fax, Phone2__c, Phone, PrivacyCommerciale__c, PrivacyCommercialeTerzi__c,
                            PrivacyProfilazioneConsumo__c, FaxPrefix__c, MobilePrefix__c, PhonePrefix__c, PEC__c, Nation__c, FiscalCode__c, Name, VatNumber__c,
                            FirstName, LastName, DatamaxCustomerCode__c, FormaAnagrafica__c
                        FROM Account
                        WHERE Id IN :accountIds]) {
            DmxAccount acc = setDmxAccount(a);
            if(a.IsPersonAccount) {
                DmxContact cnt = setDmxContact(a);
                acc.contacts = new List<DmxContact>{cnt};
            }
            dmxAccountPerAccountId.put(a.Id,acc);
            accountPerAccountId.put(a.Id,a);
        }

        Map<Id,Contact> contactPerAccountId = new Map<Id,Contact>();
        for(AccountContactRelation acr : [SELECT AccountId, Contact.Birthdate, Contact.Email, Contact.Fax, Contact.FirstName, Contact.Account.Nation__c,
                                            Contact.Account.FiscalCode__c, Contact.Id, Contact.LastName, Contact.MobilePhone, Contact.MobilePrefix__c,
                                            Contact.NascitaLuogo__c, Contact.NascitaProvincia__c, Contact.Phone, Contact.PhonePrefix__c
                                        FROM AccountContactRelation
                                        WHERE AccountId IN :accountIds AND Roles = 'RL']) {
            DmxContact cnt = setDmxContact(acr.Contact);
            DmxAccount acc = dmxAccountPerAccountId.get(acr.AccountId);
            acc.contacts = new List<DmxContact>{cnt};
            contactPerAccountId.put(acr.AccountId,acr.Contact);
        }
        
        Map<Id,Address__c> addressPerAccountId = new Map<Id,Address__c>();
        for(Address__c a : [SELECT AccountId__c, City__c, Country__c, Note__c, Province__c, StreetNumber__c, Type__c, ZipCode__c, Hamlet__c, StreetName__c
                            FROM Address__c
                            WHERE AccountId__c IN :accountIds AND (Type__c = '8' OR Type__c = '9')]) {
            DmxAddress address = setDmxAddress(a);
            DmxAccount acc = dmxAccountPerAccountId.get(a.AccountId__c);
            acc.addresses = new List<DmxAddress>{address};
            addressPerAccountId.put(a.AccountId__c,a);
        }

        List<Account> accountsToUpdate = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Address__c> addressesToUpdate = new List<Address__c>();
        for(Id accId : accountIds) {
            DmxAccount dmxAcc = dmxAccountPerAccountId.get(accId);
            Account acc = accountPerAccountId.get(accId);
            if(acc != null &&
                dmxAcc != null && dmxAcc.contacts != null && dmxAcc.contacts.size() > 0 && dmxAcc.addresses != null && dmxAcc.addresses.size() > 0) {
                
                MulesoftApiController.Request request = new MulesoftApiController.Request();
                request.acc = dmxAcc;

                List<MulesoftApiController.Response> response = MulesoftApiController.upsertAccount(new List<MulesoftApiController.Request>{request});

                acc.LastSyncDatetime__c = System.now();
                if(response != null && response.size() > 0) {
                    if(response.get(0).code == 200) {
                        acc.DatamaxCustomerCode__c = response.get(0).acc.account_iddatamax;
                        acc.SyncErrorMessage__c = null;
                        acc.SyncStatus__c = 'Sincronizzato';

                        if(response.get(0).cnt != null) {
                            if(acc.IsPersonAccount) {
                                acc.DatamaxContactCode__pc = response.get(0).cnt.contact_iddatamax;
                            } else {
                                Contact cnt = contactPerAccountId.get(accId);
                                if(cnt != null) {
                                    cnt.DatamaxContactCode__c = response.get(0).cnt.contact_iddatamax;
                                    contactsToUpdate.add(cnt);
                                }
                            }
                        }

                        if(response.get(0).adr != null) {
                            Address__c adr = addressPerAccountId.get(accId);
                            if(adr != null) {
                                adr.DatamaxId__c = response.get(0).adr.address_iddatamax;
                                addressesToUpdate.add(adr);
                            }
                        }
                    } else {
                        acc.SyncErrorMessage__c = response.get(0).message;
                        acc.SyncStatus__c = 'Errore';
                    }
                } else {
                    acc.SyncErrorMessage__c = 'No response from Mulesoft';
                    acc.SyncStatus__c = 'Errore';
                }
                accountsToUpdate.add(acc);
            }
        }

        MulesoftApiController.lockTriggers = true;

        if(accountsToUpdate != null && accountsToUpdate.size() > 0) update accountsToUpdate;
        if(contactsToUpdate != null && contactsToUpdate.size() > 0) update contactsToUpdate;
        if(addressesToUpdate != null && addressesToUpdate.size() > 0) update addressesToUpdate;
    }

    public static DmxAccount setDmxAccount(Account a) {
        DmxAccount acc = new DmxAccount();
        acc.account_agent                   = a.Agent__r.AgentCode__c;
        acc.account_company                 = a.Company__c;
        acc.account_email                   = a.Email__c;
        acc.account_fax                     = a.Fax;
        acc.account_faxprefix               = a.FaxPrefix__c;
        acc.account_fiscalcode              = a.Nation__c=='IT'?a.FiscalCode__c:null;
        acc.account_formaanagrafica         = a.IsPersonAccount?null:a.FormaAnagrafica__c;
        acc.account_id                      = a.Id;
        acc.account_mobile                  = a.Phone2__c;
        acc.account_mobileprefix            = a.MobilePrefix__c;
        acc.account_name                    = a.IsPersonAccount?null:a.Name;
        acc.account_pec                     = a.PEC__c;
        acc.account_phone                   = a.Phone;
        acc.account_phoneprefix             = a.PhonePrefix__c;
        acc.account_privacycommerciale      = a.PrivacyCommerciale__c;
        acc.account_privacycommercialeterzi = a.PrivacyCommercialeTerzi__c;
        acc.account_privacycontratto        = true;
        acc.account_privacyprofilazione     = a.PrivacyProfilazioneConsumo__c;
        acc.account_recordtype              = a.IsPersonAccount?'1':'2';
        acc.account_vatnumber               = a.IsPersonAccount==false&&a.Nation__c=='IT'?a.VatNumber__c:null;
        return acc;
    }

    public static DmxContact setDmxContact(Account a) {
        DmxContact cnt = new DmxContact();
        cnt.contact_firstname   = a.FirstName;
        cnt.contact_lastname    = a.LastName;
        return cnt;
    }

    public static DmxContact setDmxContact(Contact c) {
        DmxContact cnt = new DmxContact();
        cnt.contact_birthdate           = c.Birthdate;
        cnt.contact_email               = c.Email;
        cnt.contact_fax                 = c.Fax;
        cnt.contact_firstname           = c.FirstName;
        cnt.contact_fiscalcode          = c.Account.Nation__c=='IT'?c.Account.FiscalCode__c:null;
        cnt.contact_id                  = c.Id;
        cnt.contact_lastname            = c.LastName;
        cnt.contact_mobile              = c.MobilePhone;
        cnt.contact_mobileprefix        = c.MobilePrefix__c;
        cnt.contact_nascitaluogo        = c.NascitaLuogo__c;
        cnt.contact_nascitaprovincia    = c.NascitaProvincia__c;
        cnt.contact_phone               = c.Phone;
        cnt.contact_phoneprefix         = c.PhonePrefix__c;
        cnt.contact_type                = '1';
        return cnt;
    }

    public static DmxAddress setDmxAddress(Address__c a) {
        DmxAddress address = new DmxAddress();
        address.address_city            = a.City__c;
        address.address_country         = a.Country__c;
        address.address_hamlet          = a.Hamlet__c;
        address.address_id              = a.Id;
        address.address_note            = a.Note__c;
        address.address_province        = a.Province__c;
        address.address_streetname      = a.StreetName__c;
        address.address_streetnumber    = a.StreetNumber__c;
        address.address_type            = a.Type__c;
        address.address_zipcode         = a.ZipCode__c;
        return address;
    }

}