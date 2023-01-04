@isTest
public class caricatoreCondominiManageCtrl_Test {
    
    @TestSetup
    static void makeData(){
        Account parentAccount = new Account(Name = 'Test parentAccount',DatamaxCustomerCode__c='abcd1234',
                                            BillingCity = 'Test City', BillingState = 'Test State', 
                                            BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                            BillingCountry = 'Test Country', Phone = '123456',
                                           recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId()); 
        insert parentAccount;
        
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country', Phone = '123456',FiscalCode__c= '91234567891',
                                        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId());
        insert objAccount;
        
        Account objAccountPartner = new Account(Name = 'Test Acc2', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId(),
                                         BillingCountry = 'Test Country', AgencyCodeDatamax__c = '123456',FiscalCode__c= '91234567881');
        insert objAccountPartner;
        
        Contact con = new Contact(LastName='Test Cont', FirstName='NameContact', DatamaxContactCode__c='abc003', AgentCode__c = '123456');
        insert con;
        
               
        Opportunity opp = new Opportunity(Name = 'Test opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'New'); 
        insert opp;
        
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__PaymentType__c = '1';
        paymentMethod.blng__Account__c = objAccount.Id;
        Insert paymentMethod;

        BillingProfile__c billing = new BillingProfile__c();
        billing.PaymentConditions__c = '4';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        insert billing;

        BillingProfile__c billing2 = new BillingProfile__c();
        billing.PaymentConditions__c = '0';
        billing.AccountId__c = objAccount.Id;
        billing.PaymentMethod__c = paymentMethod.Id;
        insert billing2;

        blng__BillingRule__c billRule = new blng__BillingRule__c();
        billRule.blng__GenerateInvoices__c = 'No';
        billRule.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        insert billRule;

        blng__RevenueRecognitionRule__c revenue = new blng__RevenueRecognitionRule__c();
        revenue.Name = 'Test';
        revenue.blng__CreateRevenueSchedule__c = 'No';
        insert revenue;

        blng__TaxRule__c tax = new blng__TaxRule__c();
        tax.Name = 'Tax Test';
        tax.blng__TaxableYesNo__c = 'No';
        insert tax;
       
       

        Product2 objProductSconto = new Product2(Name = 'SCONTOINFATTURA', family = 'Cafe', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
        blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true, Work_Order_Type__c = 'Spedizione', ProductCode = 'SCONTOINFATTURA');
        insert objProductSconto;

        PriceBookEntry objPBESconto = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                    Product2Id = objProductSconto.Id, IsActive = true);                                                            
        insert objPBESconto;

         

        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe', blng__BillingRule__c = billRule.Id, blng__TaxRule__c = tax.Id,
                                            blng__RevenueRecognitionRule__c = revenue.Id, NeedWorkOrder__c = true,Work_Order_Type__c = 'Spedizione', ProductCode = 'SCONTOINFATTURA');
        insert objProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = objProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PriceBook2 objPBEBaslab = new PriceBook2(Name ='Baslab', IsActive = true,Type__c='Bsb');                                                            
        insert objPBEBaslab;

        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = objPBEBaslab.Id,
                                                        Product2Id = objProduct.Id, IsActive = true);                                                            
        insert objPBE;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = objAccount.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.PrevistoInvioPDF__c = false;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Status__c = '2';
        insert quote;
        
        CaricatoreCondomini__c cc =  new CaricatoreCondomini__c(Name= 'Test 1',
                                                                StreetNameCustomerAddress__c= '243143223',
                                                                AgencyCode__c= '123456',
                                                                AdminCode__c= 'abcd1234',
                                                                ProductCode__c= 'SCONTOINFATTURA',
                                                                FiscalCode__c= '91234567891',
                                                                AgentCode__c= '123456',
                                                                Status__c = 'Da elaborare',
                                                                PaymentType__c= 'Bonifico',
                                                                QuoteId__c = quote.Id);
        insert cc;
        CaricatoreCondomini__c cc1 =  new CaricatoreCondomini__c(Name= 'Test 2',
                                                                StreetNameCustomerAddress__c= '243143223',
                                                                AgencyCode__c= '123456',
                                                                AdminCode__c= 'abcd1234',
                                                                ProductCode__c= 'SCONTOINFATTURA',
                                                                FiscalCode__c= '91234567891',
                                                                AgentCode__c= '123456',
                                                                Status__c = 'Da elaborare',
                                                                PaymentType__c= 'Bonifico',
                                                                QuoteId__c = quote.Id);
        insert cc1;
        CaricatoreCondomini__c cc2 =  new CaricatoreCondomini__c(Name= 'Test 3',
                                                                StreetNameCustomerAddress__c= '243143223',
                                                                AgencyCode__c= '123456',
                                                                AdminCode__c= 'abcd1234',
                                                                ProductCode__c= 'SCONTOINFATTURA',
                                                                FiscalCode__c= '91234577891',
                                                                AgentCode__c= '123456',
                                                                Status__c = 'Da elaborare',
                                                                PaymentType__c= 'Bonifico',
                                                                QuoteId__c = quote.Id);
        insert cc2;

       
        
    }
    

    @isTest
    public static void caricatoreCondominiManageTest() {

        Test.startTest();
        List<CaricatoreCondominiManageCtrl.DatatableQuote> ccList = CaricatoreCondominiManageCtrl.getCCList();
        List<CaricatoreCondominiManageCtrl.DatatableQuote> insertCCList = CaricatoreCondominiManageCtrl.insertCCListAsSobjects();
        CaricatoreCondominiManageCtrl.deleteCCList();
        Test.stopTest();
    }

    
    @isTest
    public static void BatchCaricatoreCondominiTest() {

      
        List<CaricatoreCondomini__c> listcaricatoreCondomini = new List<CaricatoreCondomini__c>();
        listcaricatoreCondomini = CaricatoreCondominiManageCtrl.queryCondomini('Da elaborare');
        
        List<CaricatoreCondominiManageCtrl.DatatableQuote> ccList = CaricatoreCondominiManageCtrl.getCCList();
        List<CaricatoreCondominiManageCtrl.DatatableQuote> insertCCList = CaricatoreCondominiManageCtrl.insertCCListAsSobjects();

        
        CaricatoreCondominiManageCtrl.WrapperRes result = new CaricatoreCondominiManageCtrl.WrapperRes ();
         result =  CaricatoreCondominiManageCtrl.verificaListcaricatoreCondomini(listcaricatoreCondomini);

        //insert account
        result =  CaricatoreCondominiManageCtrl.upsertAccount(result);

        //insert blng__PaymentMethod__c
      	result = CaricatoreCondominiManageCtrl.createBlng_PaymentMethod(result);
        

		system.debug('Input.listcaricatoreCondomini 7777777777777'+result.listcaricatoreCondomini);
        BatchCaricatoreCondomini btch = new BatchCaricatoreCondomini(result);
        Database.executeBatch(btch);  
        BatchCaricatoreCondomini.Get_attivo(new List<List<String>>{new List<String>{'input'}});
    }
    
    /*@isTest
    public static void caricatoreCondominiManageTest2() {
        CaricatoreCondomini__c cc1 =  new CaricatoreCondomini__c(Name= 'Test 2',
                                                                StreetNameCustomerAddress__c= '243143223',
                                                                AgencyCode__c= '1234567',
                                                                AdminCode__c= 'abcd123',
                                                                ProductCode__c= '',
                                                                FiscalCode__c= '9123456789',
                                                                AgentCode__c= 'abc00');
        insert cc1;

        Test.startTest();
        //List<CaricatoreCondomini__c> ccList = CaricatoreCondominiManageCtrl.getCCList();
        List<CaricatoreCondominiManageCtrl.DatatableQuote> insertCCList = CaricatoreCondominiManageCtrl.insertCCListAsSobjects();
		CaricatoreCondominiManageCtrl.deleteCCList();
        Test.stopTest();
    }*/


}