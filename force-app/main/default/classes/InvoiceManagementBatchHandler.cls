/*
 *   @TestClass: InvoiceManagementBatchTest
*/
public with sharing class InvoiceManagementBatchHandler {

    public static void EngineLinesScontoAndRitenuta (List<blng__Invoice__c> invoiceList){
        system.debug('inside EngineLinesScontoAndRitenuta');
        Set<Id> invoiceIds = new Set<Id>();
        
        List<blng__Invoice__c> invoicesToElaborate = new List<blng__Invoice__c>();
        List<blng__InvoiceLine__c> InvoiceLineToInsert = new List<blng__InvoiceLine__c>();
        Map<id, Decimal> invoiceMapSconto = new Map<id, Decimal>();
        Map<id, Decimal> invoiceMapRitenuta = new Map<id, Decimal>();
        Map<id, blng__Invoice__c> invoiceMap = new Map<id, blng__Invoice__c>();

        for(blng__Invoice__c invoice: invoiceList){
            if(invoice.blng__InvoiceStatus__c != 'Posted'){ 
                invoiceMap.put(invoice.id, invoice);
            }
        }
        system.debug('invoiceMap:' +invoiceMap);
        List<blng__InvoiceLine__c> invoiceLines  = [SELECT blng__Subtotal__c, blng__Invoice__c, blng__OrderProduct__r.Order.TotalAmountNoVat__c,
                                                        blng__OrderProduct__r.Order.TotalInvoiceDiscount__c,blng__OrderProduct__r.Order.WithholdingTax__c,
                                                        blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName,
                                                        blng__Product__r.SignificantAsset__c, blng__Product__r.Withholding_Tax__c
                                                    FROM blng__InvoiceLine__c
                                                    WHERE blng__Invoice__c IN : invoiceMap.keySet()];

        system.debug('invoiceLines:' +invoiceLines);
        for(blng__InvoiceLine__c invoiceLine: invoiceLines){
            if(invoiceMap.get(invoiceLine.blng__Invoice__c) != null){
                system.debug('invoiceLine.blng__OrderProduct__c---'+invoiceLine.blng__OrderProduct__c );
                system.debug('invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__c---'+invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__c );
                system.debug('invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName---'+invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName );
                system.debug('invoiceLine.blng__Product__r.SignificantAsset__c----'+invoiceLine.blng__Product__r.SignificantAsset__c);
               
                //if(invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName.equals('EfficienzaEnergetica') && invoiceLine.blng__Product__r.SignificantAsset__c == true){
                if(invoiceLine.blng__OrderProduct__c != null && invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__c != null && invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName.equals('EfficienzaEnergetica') && invoiceLine.blng__Product__r.SignificantAsset__c == true){
                 
                    invoiceMapSconto.put(invoiceLine.blng__Invoice__c, invoiceLine.blng__OrderProduct__r.Order.TotalInvoiceDiscount__c);
                }    
                else if(invoiceLine.blng__OrderProduct__c != null && invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__c != null && invoiceLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.RecordType.DeveloperName.equals('Baslab') && invoiceLine.blng__Product__r.Withholding_Tax__c){
                    //invoiceMapRitenuta.put(invoiceLine.blng__Invoice__c, invoiceLine.blng__OrderProduct__r.Order.WithholdingTax__c);
                    Decimal ritenuta = invoiceMapRitenuta.get(invoiceLine.blng__Invoice__c);
                    if(ritenuta == null) {
                        ritenuta = 0;
                    }
                    invoiceMapRitenuta.put(invoiceLine.blng__Invoice__c, ritenuta+invoiceLine.blng__Subtotal__c);
                }    
            }
        }
        system.debug('invoiceMapSconto:' +invoiceMapSconto);
        system.debug('invoiceMapRitenuta:' +invoiceMapRitenuta);
        List<Product2> products = [SELECT id,blng__TaxRule__r.id, Name, SBQQ__BillingFrequency__c,ProductCode, blng__BillingRule__c, SBQQ__ChargeType__c,VATManagementType__c,blng__TaxRule__c, (SELECT id, UnitPrice From PricebookEntries LIMIT 1) from Product2 WHERE ProductCode = 'SCONTOINFATTURA' OR ProductCode = 'RITENUTADACCONTO'];
        system.debug('products:' +products);
        Map<String,Product2> mapProducts = new Map<String,Product2>();

        for(Product2 product : products){
            mapProducts.put(product.ProductCode,product);
        }
       
        blng__TaxTreatment__c taxTreatment = [SELECT id from blng__TaxTreatment__c LIMIT 1];
        blng__LegalEntity__c legalEntity = [SELECT id from blng__LegalEntity__c LIMIT 1 ];
        blng__InvoiceLine__c invoiceLineTemp = new blng__InvoiceLine__c(); 
        
        for(id singleId: invoiceMap.keySet()){

            if(invoiceMapSconto.get(singleId) != null && mapProducts != null){ //case sconto in fattura
                Product2 productSconto = mapProducts.get('SCONTOINFATTURA');
                invoiceLineTemp = new blng__InvoiceLine__c(); 
                invoiceLineTemp.blng__Invoice__c = singleId;
                invoiceLineTemp.Name = 'Sconto In Fattura';
                invoiceLineTemp.blng__BillingFrequency__c = productSconto.SBQQ__BillingFrequency__c;
                invoiceLineTemp.blng__BillingRule__c = productSconto.blng__BillingRule__c;
                invoiceLineTemp.blng__ChargeDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                invoiceLineTemp.blng__ChargeType__c = productSconto.SBQQ__ChargeType__c;
                invoiceLineTemp.blng__EndDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                invoiceLineTemp.blng__LegalEntity__c = legalEntity.id;
                invoiceLineTemp.blng__Quantity__c = 1;
                invoiceLineTemp.blng__StartDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                String taxCountry = productSconto.VATManagementType__c + '-';
                if(invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c != null && invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c.equalsIgnoreCase('PA') && invoiceMap.get(singleId).blng__Account__r.Nation__c != null && invoiceMap.get(singleId).blng__Account__r.Nation__c.equalsIgnoreCase('IT')){
                    taxCountry = taxCountry + 'PA-';
                }
                else{
                    taxCountry = taxCountry + invoiceMap.get(singleId).blng__Account__r.RecordType.DeveloperName + '-';
                }
                taxCountry = taxCountry + invoiceMap.get(singleId).blng__Account__r.AccountRegion__c;
                invoiceLineTemp.blng__TaxCountry__c = taxCountry;
                invoiceLineTemp.blng__TaxRule__c = productSconto.blng__TaxRule__c;
                invoiceLineTemp.blng__TaxTreatment__c = taxTreatment.id;
                invoiceLineTemp.blng__TotalAmount__c = productSconto.PricebookEntries[0].UnitPrice;
                invoiceLineTemp.blng__UnitPrice__c = productSconto.PricebookEntries[0].UnitPrice;
                invoiceLineTemp.blng__Product__c = productSconto.id;
                if(!invoiceMapSconto.isEmpty()){
                    invoiceLineTemp.blng__Subtotal__c = -invoiceMapSconto.get(singleId);
                }    
                invoiceLineTemp.blng__TaxPercentageApplied__c = 0;
                InvoiceLineToInsert.add(invoiceLineTemp);

            }
            else if(invoiceMapRitenuta.get(singleId) != null && (invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c.equalsIgnoreCase('CONDOMINIO') || invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c.equalsIgnoreCase('CONDOMINIA'))){
                //case ritenuta d'acconto
                Decimal ritenuta = invoiceMapRitenuta.get(singleId)*0.04;
                Product2 productRitenuta = mapProducts.get('RITENUTADACCONTO');
                invoiceLineTemp = new blng__InvoiceLine__c(); 
                invoiceLineTemp.blng__Invoice__c = singleId;
                invoiceLineTemp.Name = 'Ritenuta dAcconto';
                invoiceLineTemp.blng__BillingFrequency__c = productRitenuta.SBQQ__BillingFrequency__c;
                invoiceLineTemp.blng__BillingRule__c = productRitenuta.blng__BillingRule__c;
                invoiceLineTemp.blng__ChargeDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                invoiceLineTemp.blng__ChargeType__c = productRitenuta.SBQQ__ChargeType__c;
                invoiceLineTemp.blng__EndDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                invoiceLineTemp.blng__LegalEntity__c = legalEntity.id;
                invoiceLineTemp.blng__Quantity__c = 1;
                invoiceLineTemp.blng__StartDate__c = invoiceMap.get(singleId).blng__InvoiceDate__c;
                String taxCountry = productRitenuta.VATManagementType__c + '-';
                if(invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c != null && invoiceMap.get(singleId).blng__Account__r.FormaAnagrafica__c.equalsIgnoreCase('PA') && invoiceMap.get(singleId).blng__Account__r.Nation__c != null && invoiceMap.get(singleId).blng__Account__r.Nation__c.equalsIgnoreCase('IT')){
                    taxCountry = taxCountry + 'PA-';
                }
                else{
                    taxCountry = taxCountry + invoiceMap.get(singleId).blng__Account__r.RecordType.DeveloperName + '-';
                }
                taxCountry = taxCountry + invoiceMap.get(singleId).blng__Account__r.AccountRegion__c;
                invoiceLineTemp.blng__TaxCountry__c = taxCountry;
                invoiceLineTemp.blng__TaxRule__c = productRitenuta.blng__TaxRule__c;
                invoiceLineTemp.blng__TaxTreatment__c = taxTreatment.id;
                invoiceLineTemp.blng__TotalAmount__c = -ritenuta;
                invoiceLineTemp.blng__UnitPrice__c = -ritenuta;
                invoiceLineTemp.blng__Product__c = productRitenuta.id;
                if(!invoiceMapRitenuta.isEmpty()){
                    invoiceLineTemp.blng__Subtotal__c = -ritenuta;
                }    
                invoiceLineTemp.blng__TaxPercentageApplied__c = 0;
                InvoiceLineToInsert.add(invoiceLineTemp);
            }

        }
        system.debug('InvoiceLineToInsert:'+ InvoiceLineToInsert);
        insert InvoiceLineToInsert;

    }

    public static void setPeriodoFatturazione (List<blng__Invoice__c> invoiceList){
        system.debug('**InvoiceBatch Set Periodo Fatturazione');

        Map<Integer, String> mapOfMonthNameByMonthNumber = new Map<Integer, String>();
        mapOfMonthNameByMonthNumber.put(1, 'Gennaio');
        mapOfMonthNameByMonthNumber.put(2, 'Febbraio');
        mapOfMonthNameByMonthNumber.put(3, 'Marzo');
        mapOfMonthNameByMonthNumber.put(4, 'Aprile');
        mapOfMonthNameByMonthNumber.put(5, 'Maggio');
        mapOfMonthNameByMonthNumber.put(6, 'Giugno');
        mapOfMonthNameByMonthNumber.put(7, 'Luglio');
        mapOfMonthNameByMonthNumber.put(8, 'Agosto');
        mapOfMonthNameByMonthNumber.put(9, 'Settembre');
        mapOfMonthNameByMonthNumber.put(10, 'Ottobre');
        mapOfMonthNameByMonthNumber.put(11, 'Novembre');
        mapOfMonthNameByMonthNumber.put(12, 'Dicembre');

        for(blng__Invoice__c invoice : invoiceList){
            Date startDate = invoice.MinInvoiceLineStartDate__c;
            Integer yearStart = startDate.year();
            Integer monthStart = startDate.month();
            Integer dayStart = startDate.day();

            Date endDate = invoice.MaxInvoiceLineEndDate__c;
            Integer yearEnd = endDate.year();
            Integer monthEnd = endDate.month();
            Integer dayEnd = endDate.day();

            if(yearStart == yearEnd && monthStart == monthEnd){
                invoice.BillingPeriod__c = mapOfMonthNameByMonthNumber.get(monthStart) + ' '+ yearStart;
            }
            else {
                invoice.BillingPeriod__c = mapOfMonthNameByMonthNumber.get(monthStart) + ' '+ yearStart + ' - ' + mapOfMonthNameByMonthNumber.get(monthEnd) + ' '+ yearEnd;
            }
            system.debug('**InvoiceBatch Set Periodo Fatturazione:** invoice periodo fatturazione: '+ invoice.BillingPeriod__c);
        }
    }

    //Lutech AT 07/09/2022 CR#44604 - Controlli pre fatturazione
    @InvocableMethod
    public static void controlloDelleFatture(List<Id> invoiceIds){
        System.debug('invoiceIds='+invoiceIds);
        List<blng__Invoice__c> invoiceToVerify = [SELECT Id
                                                  ,Name
                                                  ,BillingProfile__r.PaymentMethod__c
                                                  ,BillingProfile__r.BillingAddress__r.StreetName__c
                                                  ,BillingProfile__r.BillingAddress__r.StreetNumber__c
                                                  ,BillingProfile__r.BillingAddress__r.ZipCode__c
                                                  ,BillingProfile__r.BillingAddress__r.City__c
                                                  ,BillingProfile__r.BillingAddress__r.Province__c
                                                  ,BillingProfile__r.BillingAddress__r.Country__c
                                                  ,BillingProfile__r.BillingEmail__c
                                                  ,BillingProfile__r.SdiCode__c
                                                  ,blng__Account__r.CustomerAddress__r.StreetName__c
                                                  ,blng__Account__r.CustomerAddress__r.StreetNumber__c
                                                  ,blng__Account__r.CustomerAddress__r.ZipCode__c
                                                  ,blng__Account__r.CustomerAddress__r.City__c
                                                  ,blng__Account__r.CustomerAddress__r.Province__c
                                                  ,blng__Account__r.CustomerAddress__r.Country__c
                                                  ,blng__Account__r.IDTERPDatamax__c
                                                  ,blng__Account__r.IsPersonAccount 
                                                  ,blng__Account__r.Nation__c
                                                  ,blng__Account__r.FiscalCode__c 
                                                  ,blng__Account__r.FormaAnagrafica__c
                                                  ,blng__Account__r.VatNumber__c
                                                  ,blng__TotalAmount__c
                                                  ,BillingProfile__r.PaymentMethod__r.MandateCode__c
                                                  ,BillingProfile__r.IBANBank__c
                                                  ,BillingProfile__r.PaymentMethod__r.blng__PaymentType__c
                                                  ,BillingProfile__r.Bank__c
                                                  ,BillingProfile__r.SwiftCodeBank__c
                                                  ,EstimatedTaxAmount__c
                                                  ,blng__TaxAmount__c
                                                  ,InvoiceValidationStatus__c 
                                                  ,InvoiceValidationResult__c 
                                                  FROM blng__Invoice__c 
                                                  WHERE Id IN :invoiceIds
                                                 ];
        
        Map<Id, List<blng__InvoiceLine__c>> invoiceLineMap = new Map<Id, List<blng__InvoiceLine__c>>();
        Map<Double, Decimal> mapSubtotal = new Map<Double, Decimal>();
        for(blng__InvoiceLine__c invLine : [SELECT Id,Name,blng__TaxStatus__c,blng__TaxPercentageApplied__c, NaturaSDI__c, blng__Invoice__c, blng__Product__r.ProductCode, blng__Subtotal__c
                                            FROM blng__InvoiceLine__c 
                                            WHERE blng__Invoice__c IN :invoiceIds]) {
            if(invoiceLineMap.get(invLine.blng__Invoice__c) == null)
                invoiceLineMap.put(invLine.blng__Invoice__c, new List<blng__InvoiceLine__c>());
            invoiceLineMap.get(invLine.blng__Invoice__c).add(invLine);
            
            if(mapSubtotal != null && mapSubtotal.size() > 0 && mapSubtotal.containsKey(InvLine.blng__TaxPercentageApplied__c)){
                Decimal decimalTemp = mapSubtotal.get(InvLine.blng__TaxPercentageApplied__c);
                decimalTemp = decimalTemp += InvLine.blng__Subtotal__c;
                mapSubtotal.put(InvLine.blng__TaxPercentageApplied__c, decimalTemp);
            }else{
                Decimal decimalTemp;
                decimalTemp = InvLine.blng__Subtotal__c;
                mapSubtotal.put(InvLine.blng__TaxPercentageApplied__c, decimalTemp);   
            }
        }

        List<String> customErr1 =  Label.Controlli_pre_fatturazione_1.split(';');// Error message for 1
        List<String> customErr2 =  Label.Controlli_pre_fatturazione_2.split(';');// Error message for 2,3,4,5
        List<String> customErr3 =  Label.Billing_Profile_PaymentMethod_PaymentType.split(';');// Error message for 8,9
        List<String> customErr4 =  Label.InvoiceLineControlli.split(';');// Error message for 10,11,13

        for(blng__Invoice__c inv : invoiceToVerify) {
            Boolean isError =  false;
            String errorMsg =  '';
            //1 -- campi  obbligatoriamente compilati 
            if(String.isEmpty(inv.BillingProfile__r.PaymentMethod__c)){
                errorMsg += customErr1[0]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.StreetName__c)){
                errorMsg += customErr1[1]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.StreetNumber__c)){
                errorMsg += customErr1[2]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.ZipCode__c)){
                errorMsg += customErr1[3]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.City__c)){
                errorMsg += customErr1[4]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.Province__c)){
                errorMsg += customErr1[5]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingAddress__r.Country__c)){
                errorMsg += customErr1[6]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.BillingProfile__r.BillingEmail__c)){
                errorMsg += customErr1[7]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.StreetName__c)){
                errorMsg += customErr1[8]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.StreetNumber__c)){
                errorMsg += customErr1[9]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.ZipCode__c)){
                errorMsg += customErr1[10]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.City__c)){
                errorMsg += customErr1[11]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.Province__c)){
                errorMsg += customErr1[12]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.CustomerAddress__r.Country__c)){
                errorMsg += customErr1[13]+';' +'\n';
                isError =  true; 
            }
            if(String.isEmpty(inv.blng__Account__r.IDTERPDatamax__c)){
                errorMsg += customErr1[14]+';' +'\n';
                isError =  true; 
            }
            //2  - blng__Account__r.Nation__c == "IT" 3,4,5
            if( inv.blng__Account__r.Nation__c == 'IT'){
            
                if(!String.isEmpty(inv.BillingProfile__r.BillingAddress__r.ZipCode__c)
                && inv.BillingProfile__r.BillingAddress__r.ZipCode__c.length() == 5 
                && inv.BillingProfile__r.BillingAddress__r.ZipCode__c.isNumeric() ){
                }else{
                    errorMsg += customErr2[0]+';' +'\n';
                    isError =  true; 
                }
                if(!String.isEmpty(inv.blng__Account__r.CustomerAddress__r.ZipCode__c)
                && inv.blng__Account__r.CustomerAddress__r.ZipCode__c.length() == 5 
                && inv.blng__Account__r.CustomerAddress__r.ZipCode__c.isNumeric() ){
                }else{
                    errorMsg += customErr2[1]+';' +'\n';
                    isError =  true; 
                }
                if(inv.BillingProfile__r.SdiCode__c=='XXXXXXX'){
                    errorMsg += customErr2[2]+';' +'\n';
                    isError =  true; 
                }
                //3-Se blng__Account__r.IsPersonAccount == true && blng__Account__r.Nation__c == "IT"
                if(inv.blng__Account__r.IsPersonAccount){
                    if(String.isEmpty(inv.blng__Account__r.FiscalCode__c)){
                    errorMsg += customErr2[3]+';' +'\n';
                    isError =  true; 
                    }
                }
                //4 -- Se blng__Account__r.IsPersonAccount == false && blng__Account__r.Nation__c == "IT" && (blng__Account__r.FormaAnagrafica__c == ‘CONDOMINIO’ || blng__Account__r.FormaAnagrafica__c == ‘CONDOMINIA’)
                if(!inv.blng__Account__r.IsPersonAccount 
                && (inv.blng__Account__r.FormaAnagrafica__c == 'CONDOMINIO' || inv.blng__Account__r.FormaAnagrafica__c == 'CONDOMINIA')
                ){
                    if(String.isEmpty(inv.blng__Account__r.FiscalCode__c)){
                    errorMsg += customErr2[4]+';' +'\n';
                    isError =  true; 
                    }
                }
                //5 --Se blng__Account__r.IsPersonAccount == false && blng__Account__r.Nation__c == "IT" && blng__Account__r.FormaAnagrafica__c != ‘CONDOMINIO’ && blng__Account__r.FormaAnagrafica__c != ‘CONDOMINIA’
                if(!inv.blng__Account__r.IsPersonAccount 
                && (inv.blng__Account__r.FormaAnagrafica__c != 'CONDOMINIO' || inv.blng__Account__r.FormaAnagrafica__c != 'CONDOMINIA')
                ){
                    if(String.isEmpty(inv.blng__Account__r.VatNumber__c)){
                    errorMsg += customErr2[5]+';' +'\n';
                    isError =  true; 
                    }
                }
            }
            
            //6- Il campo blng__TotalAmount__c deve essere positivo
            if(inv.blng__TotalAmount__c <= 0){
                errorMsg += Label.TotalAmount_deve_essere_positivo +';' +'\n';
                isError =  true;
            }
            
            //7 -I seguenti campi devono essere valorizzati con uno dei valori previsti dal campo Nation__c dell’oggetto Account:
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Account.Nation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getValue());
            } 
            
            if(!String.isEmpty(inv.BillingProfile__r.BillingAddress__r.Country__c)
            && pickListValuesList.contains(inv.BillingProfile__r.BillingAddress__r.Country__c)){
            }else{
                errorMsg += Label.Billing_Profile_Billing_Address_Country +';' +'\n';
                isError =  true;
            }
            if(!String.isEmpty(inv.blng__Account__r.CustomerAddress__r.Country__c)
            && pickListValuesList.contains(inv.blng__Account__r.CustomerAddress__r.Country__c)){
            }else{
                errorMsg += Label.Account_Customer_Address_Country +';' +'\n';
                isError =  true;
            }
            
            //8 - Se BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == ‘1’
            if(inv.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '1'){
                if(String.isEmpty(inv.BillingProfile__r.PaymentMethod__r.MandateCode__c)){
                    errorMsg += customErr3[0]+';' +'\n';
                    isError =  true;
                }
            }
            
            //9 - Se BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == ‘2’ i seguenti campi devono essere popolati:
            if(inv.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '2'){
                if(String.isEmpty(inv.BillingProfile__r.Bank__c)){
                    errorMsg += customErr3[1]+';' +'\n';
                    isError =  true;
                }
                if(String.isEmpty(inv.BillingProfile__r.IBANBank__c)){
                    errorMsg += customErr3[2]+';' +'\n';
                    isError =  true;
                }
                /*if(String.isEmpty(inv.BillingProfile__r.SwiftCodeBank__c)){
                    errorMsg += customErr3[3]+';' +'\n';
                    isError =  true;
                }*/
            }
            
            List<blng__InvoiceLine__c> invoiceLineToVerify = invoiceLineMap.get(inv.Id);
            
            if(invoiceLineToVerify == null || invoiceLineToVerify.size()==0){//13 -- La Invoice deve avere almeno una Invoice Line.
                errorMsg += customErr4[2]+';' +'\n';
                isError =  true;
            } else {
                Boolean taxStatusCompleted = true;
                for(blng__InvoiceLine__c inL : invoiceLineToVerify){
                    //10 - Ogni Invoice Line deve avere il campo blng__TaxStatus__c == ‘Completed’
                    if(taxStatusCompleted && inL.blng__Product__r.ProductCode != 'ARR' && inL.blng__TaxStatus__c != 'Completed'){
                        taxStatusCompleted = false;
                    }
                    //11 -  Ogni Invoice Line, se ha il campo blng__TaxPercentageApplied__c == 0, allora il campo NaturaSDI__c deve essere popolato
                    if(inL.blng__TaxPercentageApplied__c == 0 && inL.blng__Product__r.ProductCode != 'ARR'){
                        if(String.isEmpty(inL.NaturaSDI__c)){
                            errorMsg += customErr4[1]+' - '+inL.Name +' ;' +'\n';
                            isError =  true;
                        }
                    }
                }
                if(!taxStatusCompleted){//10 - Ogni Invoice Line deve avere il campo blng__TaxStatus__c == ‘Completed’
                    errorMsg += customErr4[0]+';' +'\n';
                    isError =  true;
                }
            }

            //12 Il campo EstimatedTax__c (*) deve essere uguale al campo blng__TaxAmount__c.
            if(mapSubtotal != null && mapSubtotal.size() > 0){
                Decimal countTotal = 0;
                for(Double itemDouble : mapSubtotal.keySet()){
                    if(itemDouble == 22.0)
                        countTotal = countTotal += (mapSubtotal.get(itemDouble) * 0.22);
                    if(itemDouble == 10.0)
                        countTotal = countTotal += (mapSubtotal.get(itemDouble) * 0.1);    
                }

                if(countTotal.setScale(2) != inv.blng__TaxAmount__c){
                    errorMsg += Label.TaxAmount+';' +'\n';
                    isError =  true;
                }    
            }
            
            if(isError){
                inv.InvoiceValidationStatus__c = 'Error';
                inv.InvoiceValidationResult__c  = errorMsg;
            }else{
                inv.InvoiceValidationStatus__c = 'Success';
                inv.InvoiceValidationResult__c  = null;
            }
        }
        System.debug('invoiceToVerify='+invoiceToVerify);
        update invoiceToVerify;
        
    }

}