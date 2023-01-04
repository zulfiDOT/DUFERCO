/*
 *   @TestClass: IndividualManageClass_Test
*/
public with sharing class IndividualManageClass {

    public static void manageTrigger(List<Object> triggerNewRecord, String typeList) {
        Map<String, String> mapDataUse = new Map<String, String>();
        Map<String, String> mapAccountIndividualMatchTemp = new Map<String, String>();
        Map<String, String> mapAccountIndividualMatchUpdate = new Map<String, String>();
        Map<String, String> mapAccountIndividualMatch = new Map<String, String>();
        Map<String, SBQQ__Quote__c> accountSingleQuoteMap = new Map<String, SBQQ__Quote__c>();
        Set<String> individualIdsSet = new Set<String>();
        List<DataUsePurpose> dataUseList = new List<DataUsePurpose>();
        List<Individual> individualListInsert = new List<Individual>();
        List<Individual> individualListUpdate = new List<Individual>();
        List<ContactPointTypeConsent> ontactPointTypeConsentListInsert = new List<ContactPointTypeConsent>();
        WrapperIndividual wrapperResult;
        List<Account> listAccountTriggerNew = new List<Account>();
        dataUseList = [Select Id, Company__c, FieldMatch__c From DataUsePurpose];
        for(DataUsePurpose itemDataUse : dataUseList) 
            mapDataUse.put(itemDataUse.Company__c+itemDataUse.FieldMatch__c, itemDataUse.Id);

        if(typeList == 'Account'){
            wrapperResult = createIndividual(triggerNewRecord, typeList);
            individualListInsert = wrapperResult.listIndividuals;
            mapAccountIndividualMatchTemp = wrapperResult.accIndividualMap;
        }else if(typeList == 'SBQQ__Quote__c'){
            List<Account> updateAccountFromQuote = new List<Account>();
            for(SBQQ__Quote__c itemQuote : (List<SBQQ__Quote__c>)triggerNewRecord){
                accountSingleQuoteMap.put(itemQuote.SBQQ__Account__c, itemQuote);
            }
            if(!accountSingleQuoteMap.isEmpty() && accountSingleQuoteMap.size() > 0){
                for(String itemStringMap : accountSingleQuoteMap.keyset()){
                    Account updateSingleAccout = new Account(Id = itemStringMap);
                    updateSingleAccout.PrivacyCommerciale__c = accountSingleQuoteMap.get(itemStringMap).PrivacyB__c;
                    updateSingleAccout.PrivacyProfilazioneConsumo__c = accountSingleQuoteMap.get(itemStringMap).PrivacyC__c;
                    updateAccountFromQuote.add(updateSingleAccout);
                }     
            }
            if(!updateAccountFromQuote.isEmpty() && updateAccountFromQuote.size() > 0)
                update updateAccountFromQuote;    
        }else if(typeList == 'Contact'){
            wrapperResult = createIndividual(triggerNewRecord, typeList);
            individualListInsert = wrapperResult.listIndividuals;
            mapAccountIndividualMatchTemp = wrapperResult.accIndividualMap;
        }
        
        if(individualListInsert.size() > 0){
            upsert individualListInsert;
            for(Individual itemIndividual : individualListInsert){
                if(!mapAccountIndividualMatchTemp.isEmpty() && mapAccountIndividualMatchTemp.containsKey(itemIndividual.FirstName+itemIndividual.LastName+itemIndividual.Company__c))
                    mapAccountIndividualMatch.put(mapAccountIndividualMatchTemp.get(itemIndividual.FirstName+itemIndividual.LastName+itemIndividual.Company__c), itemIndividual.Id);
            }
        }

        if(!mapAccountIndividualMatchUpdate.isEmpty() && mapAccountIndividualMatchUpdate.size() > 0)
            mapAccountIndividualMatch.putAll(mapAccountIndividualMatchUpdate);

        if(!mapAccountIndividualMatch.isEmpty() && mapAccountIndividualMatch.size() > 0){
            ManageIndividual invidualManage = new ManageIndividual(mapAccountIndividualMatch, mapDataUse, typeList);
            ID jobcreateEvent = System.enqueueJob(invidualManage);
        }          
    }

    public static WrapperIndividual createIndividual(List<Object> upsertIndividualList, String ObjectType){
        Map<String, String> mapAccountIndividualMatchMethod = new Map<String, String>();
        List<Individual> individualListInsertList = new List<Individual>();
        Map<String, String> invidualIds = new Map<String, String>();
        if(ObjectType == 'Account'){
            for(Account itemAccount : (List<Account>)upsertIndividualList){
                if(itemAccount.IsPersonAccount){
                    if(String.isBlank(itemAccount.PersonIndividualId)){
                        Individual singleInsert = new Individual();
                        singleInsert.FirstName = itemAccount.FirstName;
                        singleInsert.LastName = itemAccount.LastName;
                        singleInsert.Company__c = itemAccount.Company__c;
                        individualListInsertList.add(singleInsert);
                        mapAccountIndividualMatchMethod.put(singleInsert.FirstName+singleInsert.LastName+singleInsert.Company__c, itemAccount.Id);
                    }else{
                        invidualIds.put(itemAccount.PersonIndividualId, itemAccount.Id);
                    }    
                }
            }
        }
        if(ObjectType == 'Contact'){
            System.debug('upsertIndividualList::: '+upsertIndividualList);
            List<AccountContactRelation> completeField = new List<AccountContactRelation>();
            completeField = [Select AccountId, ContactId, Account.Company__c, Contact.FirstName, Contact.LastName, Contact.IndividualId From AccountContactRelation Where Id IN: (List<String>)upsertIndividualList];
            for(AccountContactRelation itemContact : completeField){
                System.debug('itemContact.Contact.IndividualId::: '+itemContact.Contact.IndividualId);
                if(String.isBlank(itemContact.Contact.IndividualId)){
                    Individual singleInsert = new Individual();
                    singleInsert.FirstName = itemContact.Contact.FirstName;
                    singleInsert.LastName = itemContact.Contact.LastName;
                    singleInsert.Company__c = itemContact.Account.Company__c;
                    individualListInsertList.add(singleInsert);
                    mapAccountIndividualMatchMethod.put(singleInsert.FirstName+singleInsert.LastName+singleInsert.Company__c, itemContact.AccountId);
                }else{
                    invidualIds.put(itemContact.Contact.IndividualId, itemContact.AccountId);
                }
            }   
        }

        if(invidualIds.size() > 0){
            List<Individual> listIndividual = new List<Individual>();
            listIndividual = [Select Id, FirstName, LastName, Company__c From Individual Where Id IN: invidualIds.keyset()];
            System.debug('listIndividual::: '+listIndividual);
            for(Individual indItem : listIndividual){
                individualListInsertList.add(indItem);
                mapAccountIndividualMatchMethod.put(indItem.FirstName+indItem.LastName+indItem.Company__c, invidualIds.get(indItem.Id));
            }
        }
        WrapperIndividual callWrapper = new WrapperIndividual(individualListInsertList, mapAccountIndividualMatchMethod);
        return callWrapper;
    }

    public class ManageIndividual implements Queueable {
        Map<String, String> mapMatchAccountIndividual = new Map<String, String>();
        Map<String, String> mapDataUse = new Map<String, String>();
        String objectContext;
        public ManageIndividual(Map<String, String> mapMatchAccountIndividualQueue, Map<String, String> mapDataUseQueue, String objectContextQueue){
            mapMatchAccountIndividual = mapMatchAccountIndividualQueue;
            mapDataUse = mapDataUseQueue;
            objectContext = objectContextQueue;
        }
        public void execute(QueueableContext context) {
            Set<String> matchUpdateCPTC = new Set<String>();
            Map<String,Account> updateAcountPrivacy = new Map<String,Account>();
            List<Account> updateAcount = new List<Account>();
            List<Contact> updateContact = new List<Contact>();
            List<ContactPointTypeConsent> insertContactPointTypeConsent = new List<ContactPointTypeConsent>();
            Map<String, AccountContactRelation> contactMap = new Map<String, AccountContactRelation>();
            Map<String, AccountContactRelation> updateContactMap = new Map<String, AccountContactRelation>();
            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, Individual> individualMap = new Map<String, Individual>();
            contactMap = new Map<String, AccountContactRelation>([Select AccountId, ContactId, Account.Company__c, Contact.IndividualId, Contact.FirstName, Contact.LastName, Account.PersonIndividualId From AccountContactRelation Where AccountId IN: mapMatchAccountIndividual.keyset() And Roles = 'RL']);
            for(AccountContactRelation itemContactJunction : contactMap.values())
                updateContactMap.put(itemContactJunction.AccountId, itemContactJunction);  
            accountMap = new Map<String, Account>([Select Id, PrivacyProfilazioneConsumo__c, PrivacyCommerciale__c, Company__c, PersonIndividualId From Account Where Id IN: mapMatchAccountIndividual.keyset()]);
            individualMap = new Map<String, Individual>([Select Name, FirstName, LastName, Company__c From Individual Where Id IN: mapMatchAccountIndividual.values()]);
            for(String item : mapMatchAccountIndividual.keyset()){
                System.debug('item::: '+item);
                System.debug('accountMap::: '+accountMap);
                System.debug('mapMatchAccountIndividual::: '+mapMatchAccountIndividual);
                System.debug('contactMap::: ');
                if((accountMap.containsKey(item) || contactMap.containsKey(item)) && individualMap.containsKey(mapMatchAccountIndividual.get(item))){
                    if(accountMap != null && accountMap.size() > 0 && !String.isBlank(accountMap.get(item).PersonIndividualId)){
                        System.debug('11111::: ');
                        matchUpdateCPTC.add(accountMap.get(item).PersonIndividualId); 
                        updateAcountPrivacy.put(accountMap.get(item).PersonIndividualId, accountMap.get(item));
                    }else if(updateContactMap != null && updateContactMap.size() > 0 && !String.isBlank(updateContactMap.get(item).Contact.IndividualId)){
                        System.debug('22222::: ');
                        matchUpdateCPTC.add(updateContactMap.get(item).Contact.IndividualId); 
                        updateAcountPrivacy.put(updateContactMap.get(item).Contact.IndividualId, accountMap.get(item));           
                    }else{
                        System.debug('33333::: ');
                        ContactPointTypeConsent contactPointTypeConsentInsertComm = new ContactPointTypeConsent();
                        contactPointTypeConsentInsertComm = upsertContactPointTypeConsent(accountMap.get(item).Company__c,mapMatchAccountIndividual.get(item),individualMap.get(mapMatchAccountIndividual.get(item)).Name,mapDataUse.get(individualMap.get(mapMatchAccountIndividual.get(item)).Company__c+'PrivacyCommerciale__c'),accountMap.get(item).PrivacyCommerciale__c == true ? 'OptIn': 'OptOut');
                        insertContactPointTypeConsent.add(contactPointTypeConsentInsertComm);
                        ContactPointTypeConsent contactPointTypeConsentInsertProf = new ContactPointTypeConsent();
                        contactPointTypeConsentInsertProf = upsertContactPointTypeConsent(accountMap.get(item).Company__c,mapMatchAccountIndividual.get(item),individualMap.get(mapMatchAccountIndividual.get(item)).Name,mapDataUse.get(individualMap.get(mapMatchAccountIndividual.get(item)).Company__c+'PrivacyProfilazioneConsumo__c'),accountMap.get(item).PrivacyProfilazioneConsumo__c == true ? 'OptIn': 'OptOut');
                        insertContactPointTypeConsent.add(contactPointTypeConsentInsertProf);
                        
                        if(objectContext == 'Account'){
                            Account updateSigleAccount = new Account(Id = item);
                            updateSigleAccount.PersonIndividualId = mapMatchAccountIndividual.get(item);
                            updateAcount.add(updateSigleAccount);
                        }else if(objectContext == 'Contact'){
                            for(AccountContactRelation itemSingle : contactMap.values()){
                                if(itemSingle.AccountId == item){
                                    Contact updateSigleContact = new Contact(Id = itemSingle.ContactId);
                                    updateSigleContact.IndividualId = mapMatchAccountIndividual.get(item);
                                    updateContact.add(updateSigleContact);
                                }    
                            }    
                        }  
                    }
                }    
            }

            if(!updateAcount.isEmpty() && updateAcount.size() > 0)
                update updateAcount;
            if(!updateContact.isEmpty() && updateContact.size() > 0) 
                update updateContact;       
            if(!insertContactPointTypeConsent.isEmpty() && insertContactPointTypeConsent.size() > 0)
                insert insertContactPointTypeConsent; 
                
            if(matchUpdateCPTC.size() > 0) 
                updateCPTC(matchUpdateCPTC, updateAcountPrivacy, objectContext);        
        }
    }

    public static void updateCPTC(Set<String> setCheck, Map<String,Account> mapFor, String objectContext){
        List<ContactPointTypeConsent> listUpdate = new List<ContactPointTypeConsent>();
        listUpdate = [Select PartyId, DataUsePurposeId, DataUsePurpose.FieldMatch__c, PrivacyConsentStatus From ContactPointTypeConsent Where PartyId IN: setCheck];
        for(ContactPointTypeConsent itemCPTC : listUpdate){
            if(itemCPTC.DataUsePurpose.FieldMatch__c == 'PrivacyCommerciale__c')
                itemCPTC.PrivacyConsentStatus = mapFor.get(itemCPTC.PartyId).PrivacyCommerciale__c == true ? 'OptIn': 'OptOut';
            else if(itemCPTC.DataUsePurpose.FieldMatch__c == 'PrivacyProfilazioneConsumo__c')
                itemCPTC.PrivacyConsentStatus = mapFor.get(itemCPTC.PartyId).PrivacyProfilazioneConsumo__c == true ? 'OptIn': 'OptOut'; 
        }

        update listUpdate;
    }

    public static String convertCompanyValue(String picklistName, String picklistValueLabel, String typeReturn){
        Schema.DescribeFieldResult fieldResult = null;
        if(picklistName == 'Company__c')
            fieldResult = Account.Company__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple) {
            if(typeReturn == 'Label'){
                if(picklistValueLabel == pickListVal.getValue())
                    return pickListVal.getLabel();
            }else{
                if(picklistValueLabel == pickListVal.getLabel())
                    return pickListVal.getValue(); 
            }        
        }
        return null;
    }

    public static ContactPointTypeConsent upsertContactPointTypeConsent(String companyString, String idividualId, String nameString, String dataUseID, String status){
        ContactPointTypeConsent contactPointTypeConsentInsert = new ContactPointTypeConsent();
        contactPointTypeConsentInsert.Company__c = companyString;
        contactPointTypeConsentInsert.PartyId = idividualId;
        contactPointTypeConsentInsert.Name = nameString;
        contactPointTypeConsentInsert.DataUsePurposeId = dataUseID;
        contactPointTypeConsentInsert.PrivacyConsentStatus = status;
        return contactPointTypeConsentInsert;
    }

    public class WrapperIndividual{
        public List<Individual> listIndividuals;
        public Map<String,String> accIndividualMap =  new Map<String,String> ();
        public WrapperIndividual(){}
        
        public WrapperIndividual(List<Individual> listMethod, Map<String,String> mapMethod) {
            listIndividuals = listMethod;
            accIndividualMap = mapMethod;
        }
    }    
}