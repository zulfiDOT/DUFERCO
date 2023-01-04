/*
 *  @TestClass: caricatoreCondominiManageCtrl_Test
*/
public with sharing class CaricatoreCondominiManageCtrl{
    
    //retrieves CaricatoreCondomini__c records 
    @AuraEnabled(cacheable=true)
    public static List<DatatableQuote> getCCList() { 
        List<DatatableQuote> listReturn = new List<DatatableQuote>();
        List<CaricatoreCondomini__c> listcaricatoreCondomini = new List<CaricatoreCondomini__c>();
        listcaricatoreCondomini = queryCondomini('Da elaborare');
        if(!listcaricatoreCondomini.isEmpty()){
            for(CaricatoreCondomini__c item : listcaricatoreCondomini){
                DatatableQuote singleWrapper = new DatatableQuote(null, item);
                listReturn.add(singleWrapper);
            }      
        }                                                        
        return listReturn;
    }
    //deletes CaricatoreCondomini__c records 
    @AuraEnabled
    public static void deleteCCList() {
        boolean execute = true;
        try{
            List<CaricatoreCondomini__c> listcaricatoreCondomini = [SELECT Id, Name
                                                                    FROM CaricatoreCondomini__c
                                                                    WHERE OwnerId =:UserInfo.getUserId()
                                                                    AND Status__c != 'Elaborato'];
            delete listcaricatoreCondomini;            
        }Catch(Exception excep){
            system.debug('Exception : '+ excep);
        }
    }

    public static List<CaricatoreCondomini__c> queryCondomini(String statusfilter) {
        List<CaricatoreCondomini__c> listQuery = new List<CaricatoreCondomini__c>();
        String userId = UserInfo.getUserId();
        String listcaricatoreCondomini = 'SELECT Id, Name,StreetNameCustomerAddress__c, Status__c, Email__c, MobilePrefix__c, Phone2__c, AgencyCode__c,AdminCode__c,ProductCode__c,FiscalCode__c, AgentCode__c,ValidationResult__c,QuoteId__c, BillingEmail__c, BillingFrequency__c, BillingPEC__c,CityCustomerAddress__c, CountryCustomerAddress__c, PaymentTerms__c, PaymentType__c, Price__c, ProvinceCustomerAddress__c, SendingMethod__c,StartDate__c, StreetNumberCustomerAddress__c , SubscriptionTerm__c, ZipCodeCustomerAddress__c, Iban__c, BillingCountry__c, BillingStreet__c,StreetNumber__c, BillingCity__c, BillingZipPostal__c, BillingStateProvince__c, SubscriptionAccountFirstName__c, SubscriptionAccountLastName__c,SubscriptionFiscalCode__c FROM CaricatoreCondomini__c WHERE OwnerId =: userId AND Status__c =:statusfilter order by FiscalCode__c';
        listQuery = Database.query(listcaricatoreCondomini);
        system.debug('listQuery--->'+listQuery);
        return listQuery;
    }


    //Verify/insertation of account/address/blng__PaymentMethod__c/BillingProfile/SBQQ__Quote__c/SBQQ__QuoteLine__c From CaricatoreCondomini__c records 
    @AuraEnabled
    public static List<DatatableQuote> insertCCListAsSobjects() {
        List<CaricatoreCondomini__c> listcaricatoreCondomini = new List<CaricatoreCondomini__c>();
        List<DatatableQuote> listReturn = new List<DatatableQuote>();

        listcaricatoreCondomini = queryCondomini('Da elaborare');
        system.debug('listcaricatoreCondomini : '+ listcaricatoreCondomini);
        WrapperRes result = new WrapperRes ();
        Savepoint sp = Database.setSavepoint();
        try{
            result =  verificaListcaricatoreCondomini(listcaricatoreCondomini);
            if(result.toProcess){

                //insert account
                result =  upsertAccount(result);
                //insert blng__PaymentMethod__c
                result = createBlng_PaymentMethod(result);
            
                
                
                
               /* //insert account
                result =  upsertAccount(result);
                //insert address
                createAddress(result.listcaricatoreCondomini , result.accMapInSfFiscalCode);
                //insert blng__PaymentMethod__c
                result = createBlng_PaymentMethod(result);
                //insert createBillingProfile
                result = createBillingProfile(result);
                //insert SBQQ__Quote__c
                result = createSBQQQuote(result);
                //insert SBQQ__QuoteLine__c
                createSBQQQuoteLine(result);*/
                
                for(CaricatoreCondomini__c cc : listcaricatoreCondomini){
                    cc.ValidationResult__c =  'OK' ;
                    cc.Status__c = 'In Elaborazione';
                    /*if(!result.quoteCaricatoreMap.isEmpty() && result.quoteCaricatoreMap.containsKey(cc.Id)){
                        cc.Quote__c = result.quoteCaricatoreMap.get(cc.Id).Id;
                    }*/
                }
                update listcaricatoreCondomini;
                 result.processed =  true; 

                if(!Test.isRunningTest()){
                    BatchCaricatoreCondomini btch = new BatchCaricatoreCondomini(result);
                    Database.executeBatch(btch,1);
                }
               // System.enqueueJob(new QueueableCaricatoreCondomini(result, 0 ));
                    
               
            }
            
            
        }Catch(Exception ex){
            System.debug('Error CaricatoreCondominiManageCtrl: '+ex.getMessage()+ ' at line: '+ex.getLineNumber()+' stack trace: '+ex.getStackTraceString());
            Database.rollback(sp);
            for(CaricatoreCondomini__c cc : listcaricatoreCondomini){
                cc.ValidationResult__c =  ex.getMessage()+';' +'\n'+ ex.getTypeName() + '\n'+ ex.getLineNumber();
                cc.Status__c = 'In errore';
                system.debug('cc : '+cc);
            }
           
            update listcaricatoreCondomini;
            result.processed =  true;
        }
        if(!result.listcaricatoreCondomini.isEmpty()){
            for(CaricatoreCondomini__c item : result.listcaricatoreCondomini){
                DatatableQuote singleWrapper = new DatatableQuote(result.quoteCaricatoreMap.get(item.Id), item);
                listReturn.add(singleWrapper);
            }      
        } 
        return listReturn;  
        
    }
    //verify CaricatoreCondomini__c records 
    public static WrapperRes verificaListcaricatoreCondomini(List<CaricatoreCondomini__c> listcaricatoreCondomini){
        Boolean isError =  false;
        system.debug('listcaricatoreCondomini 12212121212212121 '+listcaricatoreCondomini);
        WrapperRes wr = new WrapperRes();
        String keyPrefixSBQuote = SBQQ__Quote__c.SObjectType.getDescribe().getKeyPrefix();
        
        
        Set<String> ccFiscalCodeSet = new Set<String>();
        Set<String> ccAdminCodeSet = new Set<String>();
        Set<String> ccAgenteCodeSet = new Set<String>();
        Set<String> ccAgencyCodeSet = new Set<String>();
        Set<String> prodottoCodeSet = new Set<String>();
        Map<String,Account> accMapInSfFiscalCode =  new Map<String,Account> ();
        Map<String,Account> accMapInSfCustomerCode =  new Map<String,Account> ();
        Map<String,Contact> contMapInSf =  new Map<String,Contact> ();
        Map<String,Account> accMapInSfAgencyCode =  new Map<String,Account> ();
        Set<String> prodottoCodeExistinSFSet = new Set<String>();
        Map<String, String> quoteAdministratorMap = new Map<String, String>();
        
        for(CaricatoreCondomini__c cc : listcaricatoreCondomini){
            ccFiscalCodeSet.add(cc.FiscalCode__c);
            ccAdminCodeSet.add(cc.AdminCode__c);
            ccAgenteCodeSet.add(cc.AgentCode__c);
            ccAgencyCodeSet.add(cc.AgencyCode__c);
            prodottoCodeSet.add(cc.ProductCode__c);
            if(!String.isBlank(cc.QuoteId__c))
                quoteAdministratorMap.put(cc.Id, cc.QuoteId__c);
        }
        
        List<Account> accountInSFRSC = [SELECT Id, Name,DatamaxCustomerCode__c, DatamaxContactCode__pc, SFCustomerCode__c, 
                                        AgencyCodeDatamax__c,FiscalCode__c, ParentId, (Select Id, Company__c, AccountId__c, StreetName__c, StreetNumber__c, City__c, 
                                        Province__c, ZipCode__c, Country__c, Type__c From  Indirizzi__r),
                                        (Select Id, PaymentMethod__c, PaymentMethod__r.blng__PaymentType__c, PaymentMethod__r.Iban__c, PaymentConditions__c, SendingMethod__c, AccountId__c From Billing_Profiles__r)
                                        FROM ACCOUNT
                                        WHERE (FiscalCode__c IN :ccFiscalCodeSet OR SFCustomerCode__c IN :ccAdminCodeSet )
                                        AND RecordType.DeveloperName ='Business'];
        List<Contact> contactInSF    = [SELECT Id, Name,AgentCode__c  
                                        FROM Contact
                                        WHERE AgentCode__c IN :ccAgenteCodeSet];
        List<Account> accountInSFAgency = [SELECT Id, Name, AgencyCodeDatamax__c,FiscalCode__c
                                           FROM ACCOUNT
                                           WHERE RecordType.DeveloperName ='Partner'
                                           AND AgencyCodeDatamax__c IN :ccAgencyCodeSet];
        PriceBook2 baslabPR =[SELECT Id, Name, Company__c  FROM PriceBook2 WHERE Name ='Baslab' LIMIT 1];
        
        List<PriceBookEntry> priceBEList =  [SELECT Id, Name, ProductCode, Product2.Name,Pricebook2.Name
                                             FROM PriceBookEntry 
                                             WHERE Pricebook2Id = :baslabPR.Id 
                                             AND ProductCode IN :prodottoCodeSet];
        system.debug('priceBEList : '+priceBEList);

        List<ProductsSameInvoice__mdt> listMetadata = new List<ProductsSameInvoice__mdt>();
        listMetadata = [Select Id, Products__c From ProductsSameInvoice__mdt];
        List<String> productSameInvoice = new List<String>();
        for(ProductsSameInvoice__mdt itemMetadata : listMetadata){
            productSameInvoice.addAll(itemMetadata.Products__c.split(';')); 
        }
        
        for(Account acc : accountInSFRSC){
            if(ccFiscalCodeSet.contains(acc.FiscalCode__c)){
                accMapInSfFiscalCode.put(acc.FiscalCode__c, acc);
            }
            if(ccAdminCodeSet.contains(acc.SFCustomerCode__c)){
                accMapInSfCustomerCode.put(acc.SFCustomerCode__c, acc);
            }
        }
        for(Contact con : contactInSF){
            contMapInSf.put(con.AgentCode__c,con);
        }
        for(Account acc : accountInSFAgency){
            accMapInSfAgencyCode.put(acc.AgencyCodeDatamax__c,acc);
        }
        for(PriceBookEntry pbe : priceBEList ){
            prodottoCodeExistinSFSet.add(pbe.ProductCode);
        }
        for(CaricatoreCondomini__c cc : listcaricatoreCondomini){
            String errorMsg =  '';
            //Codice fiscale condominio: valore numerico di 11 cifre, che inizia con 8 o 9.
            if(cc.FiscalCode__c.length() == 11 && (cc.FiscalCode__c.startsWith('8') || cc.FiscalCode__c.startsWith('9')) && cc.FiscalCode__c.isNumeric()){
            }else{
               errorMsg += ' Codice fiscale condominio non è valido'+';' +'\n';
               isError =  true; 
            }
            //Id Quote Amministratore di condominio: se popolato, valore alfanumerico di 18 caratteri, 
            //che inizia con la prefix key dell’oggetto SBQQ__Quote__c (attenzione perché varia tra sandbox e produzione).
            if(!String.isEmpty(cc.QuoteId__c) && !cc.QuoteId__c.startsWith(keyPrefixSBQuote)){
                errorMsg += ' Quote Id non è valido'+';' +'\n';
                isError =  true;
            }
            // non serve perchè se non esiste va creata un account nuovo
            if(accMapInSfFiscalCode.containsKey(cc.FiscalCode__c)){
            }
            //Codice cliente Amministratore di condominio: se popolato, il valore di questo campo deve corrispondere al campo DatamaxCustomerCode__c 
            //di un Account a sistema con Record Type developer name  Business.
            if(accMapInSfCustomerCode.containsKey(cc.AdminCode__c) 
               && accMapInSfCustomerCode.get(cc.AdminCode__c).SFCustomerCode__c != cc.AdminCode__c){
                   errorMsg += ' Codice cliente Amministratore di condominio è diverso'+';' +'\n';
                   isError =  true;
               }
            //Agente: il valore di questo campo deve corrispondere al campo DatamaxContactCode__c di un Contact a sistema.
            if(!contMapInSf.containsKey(cc.AgentCode__c)){
                errorMsg += ' Agente non esiste'+';' +'\n';
                isError =  true;
            }
            //Agenzia: il valore di questo campo deve corrispondere al campo AgencyCodeDatamax__c di un Account a
            // sistema con Record Type developer name Partner.
            if(!accMapInSfAgencyCode.containsKey(cc.AgencyCode__c)){
                errorMsg += ' Agenzia non esiste'+';' +'\n';
                isError =  true;
            }
            // prodotti  se popolato, il valore di questo campo deve corrispondere al campo ProductCode di un Product a sistema, presente nel Pricebook Baslab
            if(!String.isBlank(cc.ProductCode__c) && !prodottoCodeExistinSFSet.contains(cc.ProductCode__c)){
                errorMsg += ' Il prodotto non esiste'+';' +'\n';
                isError =  true;
            }
            if(!String.isBlank(errorMsg)){
                cc.ValidationResult__c =  errorMsg;
                cc.Status__c = 'In errore';
            }
        }
        //if error updates CaricatoreCondomini__c with cc.ValidationResult__c =  errorMsg; cc.Status__c = 'In errore';
        if(isError){
            update listcaricatoreCondomini;
            wr.listcaricatoreCondomini =  listcaricatoreCondomini;
            wr.toProcess = false;
        }else{
            //creates wrapper for utilising in insertion of objects 
            wr.listcaricatoreCondomini =  listcaricatoreCondomini;
            wr.accMapInSfFiscalCode  = accMapInSfFiscalCode;
            wr.accMapInSfCustomerCode  = accMapInSfCustomerCode;
            wr.contMapInSf  = contMapInSf;
            wr.accMapInSfAgencyCode  = accMapInSfAgencyCode;
            wr.baslabPriceBook = baslabPR;
            wr.toProcess = true;
            wr.quoteAdministratorMap = quoteAdministratorMap;
            wr.productSameInvoice = productSameInvoice;
        }
        
        return wr;
    }
    
    public static WrapperRes upsertAccount(WrapperRes wr){
        
        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini){
            Account acc =  new Account();
            if(wr.accMapInSfFiscalCode.containsKey(cc.FiscalCode__c)){
                acc =  wr.accMapInSfFiscalCode.get(cc.FiscalCode__c);
                // Da verificare se aggiorna ParentId nel update
                //acc.ParentId = wr.accMapInSfCustomerCode.containsKey(cc.AdminCode__c) ? wr.accMapInSfCustomerCode.get(cc.AdminCode__c).Id : null;
                acc.Company__c = '8';
                acc.Email__c = cc.Email__c;
                acc.MobilePrefix__c = cc.MobilePrefix__c;
                acc.Phone2__c = cc.Phone2__c;
            }else{
                acc.Nation__c = 'IT';
                acc.Email__c = cc.Email__c;
                acc.MobilePrefix__c = cc.MobilePrefix__c;
                acc.Phone2__c = cc.Phone2__c;
                acc.Name = cc.Name;
                acc.FiscalCode__c = cc.FiscalCode__c;
                //acc.VatNumber__c = cc.;   // non trovo VatNumber__c nel Account
                acc.ParentId = wr.accMapInSfCustomerCode.containsKey(cc.AdminCode__c) ? wr.accMapInSfCustomerCode.get(cc.AdminCode__c).Id : null;
                acc.Agent__c = wr.contMapInSf.containsKey(cc.AgentCode__c) ? wr.contMapInSf.get(cc.AgentCode__c).Id : null;
                acc.Agency__c = wr.accMapInSfAgencyCode.containsKey(cc.AgencyCode__c) ? wr.accMapInSfAgencyCode.get(cc.AgencyCode__c).Id : null;
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
                acc.FormaAnagrafica__c = 'CONDOMINIO';
                acc.Company__c = '8';
            }
            wr.accMapInSfFiscalCode.put(acc.FiscalCode__c,acc);
        }
        upsert wr.accMapInSfFiscalCode.values();
        
        return wr;
        
    }
    public static void createAddress(List<CaricatoreCondomini__c> listcaricatoreCondomini,Map<String,Account> accMapInSfFiscalCode){
        List<Address__c> addressList =  new List<Address__c>();
        Set<String> accIdSetAvoidDup = new Set<String>();
        List<CaricatoreCondomini__c> insertAddressList = new List<CaricatoreCondomini__c>();
        for(CaricatoreCondomini__c cc : listcaricatoreCondomini){
            Boolean addressCheck = false;
            if(!accMapInSfFiscalCode.get(cc.FiscalCode__c).Indirizzi__r.isEmpty())
                for(Address__c itemAddress : accMapInSfFiscalCode.get(cc.FiscalCode__c).Indirizzi__r){
                    if(itemAddress.StreetName__c == cc.StreetNameCustomerAddress__c && itemAddress.StreetNumber__c == cc.StreetNumberCustomerAddress__c && itemAddress.City__c == cc.CityCustomerAddress__c && itemAddress.ZipCode__c == cc.ZipCodeCustomerAddress__c)
                        addressCheck = true;
                }
            if(!addressCheck)
                insertAddressList.add(cc);   
        }
        if(insertAddressList.size() > 0){
            for(CaricatoreCondomini__c cc : insertAddressList){
                Address__c address =  new Address__c();
                address.IsActive__c = true;
                address.Company__c = '8';
                address.AccountId__c = accMapInSfFiscalCode.get(cc.FiscalCode__c).id;
                address.StreetName__c = cc.StreetNameCustomerAddress__c;
                address.StreetNumber__c = cc.StreetNumberCustomerAddress__c;
                address.City__c = cc.CityCustomerAddress__c;
                address.Province__c = cc.ProvinceCustomerAddress__c;
                address.ZipCode__c = cc.ZipCodeCustomerAddress__c;
                address.Country__c = cc.CountryCustomerAddress__c;
                address.Type__c = '7';
                if(!accIdSetAvoidDup.contains(address.AccountId__c)){
                    Address__c addressSedeLegale =  new Address__c();
                    if(String.IsBlank(cc.AdminCode__c)){
                        addressSedeLegale = address.clone(false,true);
                        addressSedeLegale.Type__c = '9';
                        addressList.add(addressSedeLegale);
                    }    
                    addressList.add(address);
                    accIdSetAvoidDup.add(address.AccountId__c);
                }
            }
        }    
        if(addressList.size() > 0){
            insert addressList;
        }
    }
    public static WrapperRes createBlng_PaymentMethod(WrapperRes wr){
        Boolean recordsProcessed =  false;
        Map<String,String> blngPaymentMethodMap =  new Map<String,String> ();
        Set<String> accIdSetAvoidDup = new Set<String>();
        List<blng__PaymentMethod__c> bPMsList =  new List<blng__PaymentMethod__c>();
        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini){
            blng__PaymentMethod__c bpm =  new blng__PaymentMethod__c();
            bpm.blng__Account__c = wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id;
            bpm.blng__Active__c = true;
            bpm.blng__PaymentType__c = getPicklistValueName('PaymentType__c', cc.PaymentType__c);//String.isEmpty(cc.PaymentType__c) ? '2' : cc.PaymentType__c;
            if(!accIdSetAvoidDup.contains(bpm.blng__Account__c)){
                bPMsList.add(bpm);
                accIdSetAvoidDup.add(bpm.blng__Account__c);
            }
            //Caricatore Condomini - SDD
            bpm.Iban__c =  cc.Iban__c;
            bpm.blng__BillingCountry__c = cc.BillingCountry__c;
            bpm.blng__BillingStreet__c = cc.BillingStreet__c;
            bpm.StreetNumber__c = cc.StreetNumber__c;
            bpm.blng__BillingCity__c = cc.BillingCity__c;
            bpm.blng__BillingZipPostal__c = cc.BillingZipPostal__c;
            bpm.blng__BillingStateProvince__c = cc.BillingStateProvince__c;
            bpm.SubscriptionAccountFirstName__c = cc.SubscriptionAccountFirstName__c;
            bpm.SubscriptionAccountLastName__c = cc.SubscriptionAccountLastName__c;
            bpm.SubscriptionFiscalCode__c = cc.SubscriptionFiscalCode__c;
        }
        if(bPMsList.size() > 0){
            insert bPMsList;
            recordsProcessed = true;
            for(blng__PaymentMethod__c bpm : bPMsList){
                wr.blngPaymentMethodMap.put(bpm.blng__Account__c,bpm.Id);
            }
        }
        return wr;
    }
    public static WrapperRes createBillingProfile(WrapperRes wr){
        Set<Id> accParentIdSet = new Set<Id>();
        Map<String,String> addressParentAccMap =  new Map<String,String> ();
        //Map<String,String> bilProfAdminMap =  new Map<String,String> ();
        Set<String> accIdSetAvoidDup = new Set<String>();
        for(String key : wr.accMapInSfFiscalCode.keySet()){
            accParentIdSet.add(wr.accMapInSfFiscalCode.get(key).ParentId);
        }

        //FIX Caricatore Condomini - relazione BP
        /*List<BillingProfile__c> bilProfAdminList = [SELECT Id,AccountId__c FROM BillingProfile__c WHERE IsActive__c = true AND DefaultBillingProfile__c = true AND AccountId__c IN :accParentIdSet ];*/
        /*List<SBQQ__Quote__c> adminQuoteList = new List<SBQQ__Quote__c>();
        List<Account> accounBPList = new List<Account>();
        Map<String,List<String>> quoteAccMap =  new Map<String,List<String>>();
        List<String> idadimistrativeQueues = new List<String>();
        adminQuoteList = [Select Id, SBQQ__Account__c From SBQQ__Quote__c Where Id IN: wr.quoteAdministratorMap.values()];
        if(!adminQuoteList.isEmpty()){
            for(SBQQ__Quote__c itemQuote : adminQuoteList){
                idadimistrativeQueues.add(itemQuote.SBQQ__Account__c);
                if(!quoteAccMap.isEmpty() && quoteAccMap.containsKey(itemQuote.SBQQ__Account__c)){
                    List<String> tempQueues = new List<String>();
                    tempQueues = quoteAccMap.get(itemQuote.SBQQ__Account__c);
                    tempQueues.add(itemQuote.Id);
                    quoteAccMap.put(itemQuote.SBQQ__Account__c, tempQueues);
                }else{
                    List<String> tempQueues = new List<String>();
                    tempQueues.add(itemQuote.Id);
                    quoteAccMap.put(itemQuote.SBQQ__Account__c, tempQueues);   
                }
            }

            if(!quoteAccMap.isEmpty()){
                accounBPList = [Select Id, (Select Id From Billing_Profiles__r) From Account Where Id IN: idadimistrativeQueues];
                if(!accounBPList.isEmpty()){
                    for(Account itemAccount : accounBPList){
                        if(itemAccount.Billing_Profiles__r != null && itemAccount.Billing_Profiles__r.size() > 0){
                            String billingProfileId = itemAccount.Billing_Profiles__r[0].Id;
                            for(String itemStringId : quoteAccMap.get(itemAccount.Id))
                                bilProfAdminMap.put(itemStringId, billingProfileId);
                        }
                    }
                }
            }    
        }*/


        /*List<Address__c> addressList = [SELECT Id, Name,AccountId__c FROM Address__c WHERE AccountId__c IN :accParentIdSet AND Type__c = '4'];
        for(Address__c add : addressList){
            addressParentAccMap.put(add.AccountId__c,add.Id);
        }
        for(BillingProfile__c bp : bilProfAdminList){
            bilProfAdminMap.put(bp.AccountId__c,bp.Id);
        }*/
        
        List<BillingProfile__c> bProfList =  new List<BillingProfile__c>();
        List<CaricatoreCondomini__c> insertAddressList = new List<CaricatoreCondomini__c>();
        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini){
            Boolean bpCheck = false;
            if(!wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).Billing_Profiles__r.isEmpty())
                for(BillingProfile__c itemBP : wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).Billing_Profiles__r){
                    if(itemBP.PaymentConditions__c == getPicklistValueName('PaymentTerms__c', cc.PaymentTerms__c) && itemBP.SendingMethod__c == cc.SendingMethod__c && 
                    ((itemBP.PaymentMethod__r.blng__PaymentType__c == getPicklistValueName('PaymentType__c', cc.PaymentType__c) && 
                        '1' == getPicklistValueName('PaymentType__c', cc.PaymentType__c) && itemBP.PaymentMethod__r.Iban__c == cc.Iban__c) || 
                        (itemBP.PaymentMethod__r.blng__PaymentType__c == getPicklistValueName('PaymentType__c', cc.PaymentType__c) && '2' == getPicklistValueName('PaymentType__c', cc.PaymentType__c)))){
                            wr.blngProfileMap.put(itemBP.AccountId__c,itemBP.Id);
                            bpCheck = true;
                    }        
                }
            if(!bpCheck)
                insertAddressList.add(cc);   
        }
        if(insertAddressList.size() > 0){
            for(CaricatoreCondomini__c cc : insertAddressList){
                BillingProfile__c bp =  new BillingProfile__c();
                bp.IsActive__c = true;
                bp.DefaultBillingProfile__c = true;
                bp.AccountId__c = wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id;
                bp.PaymentConditions__c = getPicklistValueName('PaymentTerms__c', cc.PaymentTerms__c);//cc.PaymentTerms__c;
                bp.BillingEmail__c = cc.BillingEmail__c;
                bp.Company__c = wr.baslabPriceBook.Company__c;
                /*bp.BillingAddress__c = addressParentAccMap.containskey(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).ParentId) ? 
                                        addressParentAccMap.get(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).ParentId) : null;
                
                bp.Billing_Profile_Amministratore__c =  bilProfAdminMap.containsKey(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).ParentId) ?
                                bilProfAdminMap.get(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).ParentId) : null;*/
                                
                bp.PECEmail__c = cc.BillingPEC__c;
                if(wr.blngPaymentMethodMap.containskey(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id))
                    bp.PaymentMethod__c = wr.blngPaymentMethodMap.get(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).Id);
                bp.SendingMethod__c = cc.SendingMethod__c;
                System.debug('cc.QuoteId__c::: '+cc.QuoteId__c);
                //if(!bilProfAdminMap.isEmpty() && bilProfAdminMap.containsKey(cc.QuoteId__c))
                    //bp.Billing_Profile_Amministratore__c = bilProfAdminMap.get(cc.QuoteId__c);
                //if(!wr.accMapInSfCustomerCode.isEmpty() && wr.accMapInSfCustomerCode.containsKey(cc.AdminCode__c))    
                    //bp.Billing_Profile_Amministratore__c = wr.accMapInSfCustomerCode.get(cc.AdminCode__c).Id; 
                                                        
                if(!accIdSetAvoidDup.contains(bp.AccountId__c)){
                    bProfList.add(bp);
                    accIdSetAvoidDup.add(bp.AccountId__c);
                }
                
            }
        }    
        if(bProfList.size() > 0){
            insert bProfList;
            for(BillingProfile__c bp : bProfList){
                wr.blngProfileMap.put(bp.AccountId__c,bp.Id);
            }
        }
        return wr;
    }
    public static WrapperRes createSBQQQuote(WrapperRes wr){
        List<SBQQ__Quote__c> sbqList =  new List<SBQQ__Quote__c>();
        User curUser = [SELECT Id,Name,SalesChannel__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        RecordType rtQuoteGenerico = [SELECT Id FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Generico' AND IsActive = true];    
        Map<String, SBQQ__Quote__c> condQuoteMap = new Map<String, SBQQ__Quote__c>();
        Set<String> accIdSetAvoidDup = new Set<String>();

        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini){
            SBQQ__Quote__c sbq =  new SBQQ__Quote__c();
            sbq.SBQQ__Account__c = wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id;
            sbq.Agency__c =  wr.accMapInSfAgencyCode.containsKey(cc.AgencyCode__c) ? wr.accMapInSfAgencyCode.get(cc.AgencyCode__c).Id : null;
            sbq.Billing_Profile__c = wr.blngProfileMap.containsKey(sbq.SBQQ__Account__c) ? wr.blngProfileMap.get(sbq.SBQQ__Account__c) : null;
            sbq.SalesChannel__c =  !String.isEmpty(curUser.SalesChannel__c) ? curUser.SalesChannel__c : '';
            sbq.SubscriptionDate__c = system.today();
        	sbq.PrevistoInvioPDF__c = false;
            sbq.ParentQuote__c = cc.QuoteId__c;
            sbq.SBQQ__PriceBook__c = wr.baslabPriceBook.Id;
            sbq.SBQQ__PricebookId__c = wr.baslabPriceBook.Id;
            sbq.SBQQ__SalesRep__c = curUser.Id;
            sbq.SBQQ__StartDate__c = cc.StartDate__c;
            sbq.SBQQ__Status__c = '0';
            sbq.SBQQ__SubscriptionTerm__c = cc.SubscriptionTerm__c;
            sbq.SBQQ__Type__c = 'Quote';
            sbq.RecordTypeId = rtQuoteGenerico.Id;

            condQuoteMap.put(cc.Id, sbq);

            /*
            if(!accIdSetAvoidDup.contains(sbq.SBQQ__Account__c)){
                sbqList.add(sbq);
                if(wr.productSameInvoice.contains(cc.ProductCode__c))
                    accIdSetAvoidDup.add(sbq.SBQQ__Account__c);
            }  */
             if((wr.productSameInvoice.contains(cc.ProductCode__c) && !accIdSetAvoidDup.contains(sbq.SBQQ__Account__c))
                   || !wr.productSameInvoice.contains(cc.ProductCode__c)){
                    sbqList.add(sbq);

                       if(wr.productSameInvoice.contains(cc.ProductCode__c)){ 	
                           accIdSetAvoidDup.add(sbq.SBQQ__Account__c);
                           //aggiungo riga quote alla mappa perché sarà la quote unica per tutti i prodotti da accorpare
                           wr.sbqqAccMap.put(sbq.SBQQ__Account__c, sbq);
                       }
                   }
        }
        if(sbqList.size() > 0){
            //insert sbqList;
            Set<String> idQuoteinserted = new Set<String>();
            Database.SaveResult[] srList = Database.insert(sbqList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) 
                    idQuoteinserted.add(sr.getId());
            }
            System.debug('sbqList::: ' + sbqList);
            Map<String, SBQQ__Quote__c> sbqListMap = new Map<String, SBQQ__Quote__c>();
            if(!idQuoteinserted.isEmpty()){
                sbqListMap = new Map<String, SBQQ__Quote__c>([Select Name, SBQQ__Account__c,Agency__c,Billing_Profile__c,SalesChannel__c,SubscriptionDate__c,PrevistoInvioPDF__c,ParentQuote__c,SBQQ__PriceBook__c,SBQQ__PricebookId__c,SBQQ__SalesRep__c,SBQQ__StartDate__c,SBQQ__Status__c,SBQQ__SubscriptionTerm__c,SBQQ__Type__c,RecordTypeId From SBQQ__Quote__c Where Id IN: idQuoteinserted]);
                for(SBQQ__Quote__c sbq : sbqList){
                    //wr.sbqqAccMap.put(sbq.SBQQ__Account__c, sbq.Id);
                    for(String key : condQuoteMap.keySet()){
                        if(condQuoteMap.get(key) == sbq){
                            wr.quoteCaricatoreMap.put(key, sbqListMap.get(sbq.Id));
                            System.debug('CORRECT::: ' + key + ' - ' + sbq.Id);
                        }
                    }
                }
            }    
        }
        return wr;
        
    }
     //SBQQ__QuoteLine__c (sede legale) insert
    public static void createSBQQQuoteLine(WrapperRes wr){
        List<SBQQ__QuoteLine__c> sbqLineList =  new List<SBQQ__QuoteLine__c>();
        
        Set<String> productCodes = new Set<String>();
        Map<String,Product2> productMap = new Map<String,Product2>();
        Map<String,Id> pricebookEntryMap = new Map<String,Id>();

        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini) {
            productCodes.add(cc.ProductCode__c);
        }

        for(Product2 prod : [SELECT ProductCode, SBQQ__ChargeType__c, SBQQ__SubscriptionType__c, SBQQ__SubscriptionPricing__c,
                                    SBQQ__BillingType__c, SBQQ__BillingFrequency__c, SBQQ__SubscriptionTerm__c, Withholding_Tax__c
                            FROM Product2 WHERE ProductCode IN :productCodes]) {
            productMap.put(prod.ProductCode, prod);
        }

        for(PricebookEntry pbe : [SELECT Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2.ProductCode IN :productCodes AND Pricebook2Id = :wr.baslabPriceBook.Id]) {
            pricebookEntryMap.put(pbe.Pricebook2Id+'-'+pbe.Product2Id, pbe.Id);
        }
        List<SBQQ__Quote__c> reCalulateQuoteProduct = new List<SBQQ__Quote__c>();
        system.debug('wr.listcaricatoreCondomini--->'+wr.listcaricatoreCondomini);
        for(CaricatoreCondomini__c cc : wr.listcaricatoreCondomini){
            if(!String.isEmpty(cc.ProductCode__c)){
                SBQQ__QuoteLine__c sbqL =  new SBQQ__QuoteLine__c();
                sbqL.SBQQ__ListPrice__c =  cc.Price__c;
                sbqL.SBQQ__Product__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).Id : null;
                sbqL.SBQQ__ChargeType__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__ChargeType__c : null;
                sbqL.SBQQ__ProductSubscriptionType__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__SubscriptionType__c : null;
                sbqL.SBQQ__SubscriptionType__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__SubscriptionType__c : null;
                sbqL.SBQQ__SubscriptionPricing__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__SubscriptionPricing__c : null;
                sbqL.Withholding_Tax__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).Withholding_Tax__c : false;
                if(sbqL.SBQQ__SubscriptionType__c == 'Evergreen')
                    sbqL.SBQQ__SubscriptionTerm__c = 1;
                else
                    sbqL.SBQQ__SubscriptionTerm__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__SubscriptionTerm__c : null;

                sbqL.SBQQ__DefaultSubscriptionTerm__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__SubscriptionTerm__c : null;
                sbqL.SBQQ__BillingType__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__BillingType__c : null;
                sbqL.SBQQ__BillingFrequency__c = productMap.get(cc.ProductCode__c) != null ? productMap.get(cc.ProductCode__c).SBQQ__BillingFrequency__c : null;
                sbqL.SBQQ__PricebookEntryId__c = pricebookEntryMap.get(wr.baslabPriceBook.Id+'-'+sbqL.SBQQ__Product__c);
                sbqL.SBQQ__Quantity__c = 1;
                if(wr.productSameInvoice.contains(cc.ProductCode__c)){
                    sbqL.SBQQ__Quote__c = wr.sbqqAccMap.containsKey(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id) ? wr.sbqqAccMap.get(wr.accMapInSfFiscalCode.get(cc.FiscalCode__c).id).id : null;
                    system.debug('sbqL.SBQQ__Quote__c-66666666666666666666666666666666666-->'+sbqL.SBQQ__Quote__c);
                }else{  
                    sbqL.SBQQ__Quote__c = wr.quoteCaricatoreMap.get(cc.Id).Id;
                }
                
                sbqLineList.add(sbqL);
                system.debug('sbqL 00000000000000000000000   '+sbqL);
            }
        }
        System.debug('sbqLineList='+sbqLineList);
        insert sbqLineList;
    }

    //mapping valori picklist: dato nome campo e valore campo, viene restituito l'api name del valore picklist
    public static String getPicklistValueName(String picklistName, String picklistValueLabel) {
        Schema.DescribeFieldResult fieldResult = null;
        if(picklistName == 'PaymentType__c') {
            fieldResult = blng__PaymentMethod__c.blng__PaymentType__c.getDescribe();
        } else if(picklistName == 'PaymentTerms__c') {
            fieldResult = BillingProfile__c.PaymentConditions__c.getDescribe();
        }

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			if(picklistValueLabel == pickListVal.getLabel()) {
                return pickListVal.getValue();
            }
		}
        return null;
    }
    
    //wrapper for utilising in insertion/verification of objects 
    Public class WrapperRes{
        @auraEnabled public List<CaricatoreCondomini__c> listcaricatoreCondomini;
        @auraEnabled public Map<String,Account> accMapInSfFiscalCode =  new Map<String,Account> ();
        @auraEnabled public Map<String,Account> accMapInSfCustomerCode =  new Map<String,Account> ();
        @auraEnabled public Map<String,Contact> contMapInSf =  new Map<String,Contact> ();
        @auraEnabled public Map<String,Account> accMapInSfAgencyCode =  new Map<String,Account> ();
        @auraEnabled public Map<String,String> blngPaymentMethodMap =  new Map<String,String> ();
        @auraEnabled public Map<String,String> blngProfileMap =  new Map<String,String> ();
        @auraEnabled public Map<String,SBQQ__Quote__c> sbqqAccMap =  new Map<String,SBQQ__Quote__c> ();
        @auraEnabled public Pricebook2 baslabPriceBook;
        @auraEnabled public Boolean toProcess = false;
        @auraEnabled public Boolean processed = false;
        @auraEnabled public Map<String,SBQQ__Quote__c> quoteCaricatoreMap = new Map<String,SBQQ__Quote__c>();
        @auraEnabled public Map<String, String> quoteAdministratorMap = new Map<String,String>();
        @auraEnabled public List<String> productSameInvoice = new List<String>();
    }

    public class DatatableQuote{
        @AuraEnabled
        public String id_Quote { get; set; }
        @AuraEnabled
        public String nameQuote { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String FiscalCode { get; set; }
        @AuraEnabled
        public String AdminCode { get; set; }
        @AuraEnabled
        public String AgencyCode { get; set; }
        @AuraEnabled
        public String AgentCode { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String ValidationResult { get; set; }
        @AuraEnabled
        public String StreetNameCustomerAddress { get; set; }
        @AuraEnabled
        public String StreetNumberCustomerAddress { get; set; }
        @AuraEnabled
        public String CityCustomerAddress { get; set; }
        @AuraEnabled
        public String ProvinceCustomerAddress { get; set; }
        @AuraEnabled
        public String ZipCodeCustomerAddress { get; set; }
        @AuraEnabled
        public String CountryCustomerAddress { get; set; }
        @AuraEnabled
        public String SendingMethod { get; set; }
        @AuraEnabled
        public String BillingEmail { get; set; }
        @AuraEnabled
        public String PaymentType { get; set; }
        @AuraEnabled
        public String PaymentTerms { get; set; }
        @AuraEnabled
        public String ProductCode { get; set; }
        @AuraEnabled
        public String Price { get; set; }
        @AuraEnabled
        public String SubscriptionTerm { get; set; }
        @AuraEnabled
        public String StartDate { get; set; }
        @AuraEnabled
        public String BillingFrequency { get; set; }
        @AuraEnabled
        public String Iban { get; set; }
        @AuraEnabled
        public String BillingCountry { get; set; }
        @AuraEnabled
        public String BillingStreet { get; set; }
        @AuraEnabled
        public String StreetNumber { get; set; }
        @AuraEnabled
        public String BillingCity { get; set; }
        @AuraEnabled
        public String BillingZipPostal { get; set; }
        @AuraEnabled
        public String BillingStateProvince { get; set; }
        @AuraEnabled
        public String SubscriptionAccountFirstName { get; set; }
        @AuraEnabled
        public String SubscriptionAccountLastName { get; set; }
        @AuraEnabled
        public String SubscriptionFiscalCode { get; set; }
        @AuraEnabled
        public String Email { get; set; }
        @AuraEnabled
        public String MobilePrefix { get; set; }
        @AuraEnabled
        public String Phone2 { get; set; }
        @AuraEnabled
        public CaricatoreCondomini__c condominio { get; set; }
        public DatatableQuote(){}
        
        public DatatableQuote(SBQQ__Quote__c quoteRecord, CaricatoreCondomini__c condominioRecord) {
            if(quoteRecord != null){
                id_Quote = URL.getSalesforceBaseUrl().toExternalForm()+'/'+quoteRecord.Id; 
                nameQuote = quoteRecord.Name;
            }    
            Name = condominioRecord.Name;
            FiscalCode = condominioRecord.FiscalCode__c;
            AdminCode = condominioRecord.AdminCode__c;
            AgencyCode = condominioRecord.AgencyCode__c;
            AgentCode = condominioRecord.AgentCode__c;
            Status = condominioRecord.Status__c;
            ValidationResult = condominioRecord.ValidationResult__c;
            StreetNameCustomerAddress = condominioRecord.StreetNameCustomerAddress__c;
            StreetNumberCustomerAddress = condominioRecord.StreetNumberCustomerAddress__c;
            CityCustomerAddress = condominioRecord.CityCustomerAddress__c;
            ProvinceCustomerAddress = condominioRecord.ProvinceCustomerAddress__c;
            ZipCodeCustomerAddress = condominioRecord.ZipCodeCustomerAddress__c;
            CountryCustomerAddress = condominioRecord.CountryCustomerAddress__c;
            SendingMethod = condominioRecord.SendingMethod__c;
            BillingEmail = condominioRecord.BillingEmail__c;
            PaymentType = condominioRecord.PaymentType__c;
            PaymentTerms = condominioRecord.PaymentTerms__c;
            ProductCode = condominioRecord.ProductCode__c;
            if(condominioRecord.Price__c != null)
                Price = String.valueOf(condominioRecord.Price__c);
            if(condominioRecord.SubscriptionTerm__c != null)     
                SubscriptionTerm = String.valueOf(condominioRecord.SubscriptionTerm__c);
            if(condominioRecord.StartDate__c != null)      
                StartDate = String.valueOf(condominioRecord.StartDate__c);
            BillingFrequency = condominioRecord.BillingFrequency__c;
            Iban = condominioRecord.Iban__c;
            BillingCountry = condominioRecord.BillingCountry__c;
            BillingStreet = condominioRecord.BillingStreet__c;
            StreetNumber = condominioRecord.StreetNumber__c;
            BillingCity = condominioRecord.BillingCity__c;
            BillingZipPostal = condominioRecord.BillingZipPostal__c;
            BillingStateProvince = condominioRecord.BillingStateProvince__c;
            SubscriptionAccountFirstName = condominioRecord.SubscriptionAccountFirstName__c;
            SubscriptionAccountLastName = condominioRecord.SubscriptionAccountLastName__c;
            SubscriptionFiscalCode = condominioRecord.SubscriptionFiscalCode__c;
            Email = condominioRecord.Email__c;
            MobilePrefix = condominioRecord.MobilePrefix__c;
            Phone2 = condominioRecord.Phone2__c;
        }
    }
    
}