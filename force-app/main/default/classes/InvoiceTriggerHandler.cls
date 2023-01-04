/*
 *   @TestClass: InvoiceTriggerHandlerTest
*/
public class InvoiceTriggerHandler {
    
    public static void setInvoiceOnPayment (List<blng__Invoice__c> invoiceList){
    
        Set<Id> quoteId = new Set<Id>();
        Set<Id> orderId = new Set<Id>();
        Set<Id> usageSummaryId = new Set<Id>();
        Set<Id> invoiceIdWithOrder = new Set<Id>();
        Set<Id> invoiceIdWithoutOrder = new Set<Id>();
        List<blng__Payment__c> paymentList = new List<blng__Payment__c>();
        Map<Id,blng__Invoice__c> orderIdToInvoiceMap = new Map<Id,blng__Invoice__c>();
        Map<Id,blng__Invoice__c> quoteIdToInvoiceMap = new Map<Id,blng__Invoice__c>();
        Map<Id,blng__InvoiceLine__c> orderIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,blng__InvoiceLine__c> usageSummaryIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,blng__InvoiceLine__c> quoteIdToInvoiceLineMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,Id> usageIdToMainIdMap = new Map<Id,Id>();

        for(blng__Invoice__c invoice : invoiceList) {
            if(invoice.blng__Order__c != null) {
                invoiceIdWithOrder.add(invoice.Id);
            }else if (invoice.blng__Order__c == null && invoice.InvoiceLineCount__c > 0) {
                invoiceIdWithoutOrder.add(invoice.Id);
            }
        }

        if(!invoiceIdWithOrder.isEmpty()) {
            for(blng__Invoice__c inv : [SELECT blng__Order__r.SBQQ__Quote__c, blng__Order__c, Id
                                        FROM blng__Invoice__c
                                        WHERE Id IN : invoiceIdWithOrder
                                        AND BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '9']) {
                orderId.add(inv.blng__Order__c);
                quoteId.add(inv.blng__Order__r.SBQQ__Quote__c);
                orderIdToInvoiceMap.put(inv.blng__Order__c, inv);
                quoteIdToInvoiceMap.put(inv.blng__Order__r.SBQQ__Quote__c, inv);
            }
        }

        System.debug('orderIdToInvoiceMap --> '+orderIdToInvoiceMap);
        System.debug('quoteIdToInvoiceMap --> '+quoteIdToInvoiceMap);

        if(!invoiceIdWithoutOrder.isEmpty()) {
            for(blng__InvoiceLine__c invLine : [SELECT blng__Invoice__c, blng__OrderProduct__c, blng__OrderProduct__r.OrderId,
                                                        blng__OrderProduct__r.Order.SBQQ__Quote__c, blng__UsageSummary__c
                                                FROM blng__InvoiceLine__c
                                                WHERE blng__Invoice__c IN :invoiceIdWithoutOrder
                                                AND (blng__Invoice__r.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '9'
                                                OR blng__Invoice__r.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c = '10')]) {
                if(invLine.blng__UsageSummary__c != null) {
                    usageSummaryId.add(invLine.blng__UsageSummary__c);
                    usageSummaryIdToInvoiceLineMap.put(invLine.blng__UsageSummary__c, invLine);
                }
                if(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c != null) {
                    quoteId.add(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c);
                    quoteIdToInvoiceLineMap.put(invLine.blng__OrderProduct__r.Order.SBQQ__Quote__c, invLine);
                }
            }
        }

        if(!usageSummaryId.isEmpty()) {
            for(blng__Usage__c usage : [SELECT blng__UsageSummary__c, MainUsage__c, MainUsage__r.blng__UsageSummary__c
                                        FROM blng__Usage__c
                                        WHERE blng__UsageSummary__c IN :usageSummaryId]) {
                if(usage.MainUsage__c != null) {
                    usageSummaryId.add(usage.MainUsage__r.blng__UsageSummary__c);
                    usageSummaryIdToInvoiceLineMap.put(usage.MainUsage__r.blng__UsageSummary__c, usageSummaryIdToInvoiceLineMap.get(usage.blng__UsageSummary__c));
                    usageIdToMainIdMap.put(usage.Id, usage.MainUsage__c);
                }
            }
        }

        System.debug('usageSummaryIdToInvoiceLineMap --> '+usageSummaryIdToInvoiceLineMap);
        System.debug('quoteIdToInvoiceLineMap --> '+quoteIdToInvoiceLineMap);

        for(blng__Payment__c payment : [SELECT Id, Order__c, Quote__c, Usage__c, Usage__r.blng__UsageSummary__c, Usage__r.MainUsage__r.blng__UsageSummary__c
                                        FROM blng__Payment__c
                                        WHERE blng__Invoice__c = null
                                        AND blng__Status__c = 'Draft'
                                        AND (Order__c IN : orderId OR Quote__c IN : quoteId OR Usage__r.blng__UsageSummary__c IN : usageSummaryId)]) {
            if (payment.Order__c != null && orderIdToInvoiceMap.get(payment.Order__c) != null) {
                payment.blng__Invoice__c = orderIdToInvoiceMap.get(payment.Order__c).Id;
                paymentList.add(payment);
            } else if (payment.Quote__c != null && quoteIdToInvoiceMap.get(payment.Quote__c) != null) {
                payment.blng__Invoice__c = quoteIdToInvoiceMap.get(payment.Quote__c).Id;
                paymentList.add(payment);
            } else if (payment.Usage__r?.blng__UsageSummary__c != null && usageIdToMainIdMap.get(payment.Usage__c) != null && usageSummaryIdToInvoiceLineMap.get(usageIdToMainIdMap.get(payment.Usage__c)) != null) {
                payment.blng__Invoice__c = usageSummaryIdToInvoiceLineMap.get(usageIdToMainIdMap.get(payment.Usage__c)).blng__Invoice__c;
                paymentList.add(payment);
            } else if (payment.Usage__r?.blng__UsageSummary__c != null && usageSummaryIdToInvoiceLineMap.get(payment.Usage__r.blng__UsageSummary__c) != null) {
                payment.blng__Invoice__c = usageSummaryIdToInvoiceLineMap.get(payment.Usage__r.blng__UsageSummary__c).blng__Invoice__c;
                paymentList.add(payment);
            } else if (payment.Quote__c != null && quoteIdToInvoiceLineMap.get(payment.Quote__c) != null) {
                payment.blng__Invoice__c = quoteIdToInvoiceLineMap.get(payment.Quote__c).blng__Invoice__c;
                paymentList.add(payment);
            }
        }
        
        if(!paymentList.isEmpty()) {update paymentList;
        }
    }

    public static void setCustomAutonumber(List<blng__Invoice__c> invoiceList) {
        
        Set<Id> invoiceIdWithOrder = new Set<Id>();
        Set<Id> invoiceIdWithoutOrder = new Set<Id>();
        Map<String, Set<blng__Invoice__c>> areaToInvoiceList = new Map<String, Set<blng__Invoice__c>>();
        List<CustomAutonumber__c> autonumberList = new List<CustomAutonumber__c>();
        List<blng__Invoice__c> invoiceToUpdate = new List<blng__Invoice__c>();

        for (blng__Invoice__c invoice : invoiceList) {
            
            if (invoice.blng__Order__c != null && String.isBlank(invoice.Progressivo_fattura__c)) {
                invoiceIdWithOrder.add(invoice.Id);

            }else if (invoice.blng__Order__c == null && invoice.InvoiceLineCount__c > 0 && String.isBlank(invoice.Progressivo_fattura__c)) {
                invoiceIdWithoutOrder.add(invoice.Id);
            }
        }

        if (!invoiceIdWithOrder.isEmpty()) {

            for (blng__Invoice__c inv : [SELECT Id, Name, blng__Order__r.Pricebook2.Area__c FROM blng__Invoice__c WHERE Id IN : invoiceIdWithOrder]) {             
                    
                if (!areaToInvoiceList.containsKey(inv.blng__Order__r.Pricebook2.Area__c)) {
                    areaToInvoiceList.put(inv.blng__Order__r.Pricebook2.Area__c, new Set<blng__Invoice__c>());
                }
                areaToInvoiceList.get(inv.blng__Order__r.Pricebook2.Area__c).add(inv);
            }   
        }

        if (!invoiceIdWithoutOrder.isEmpty()) {
            
            for (blng__InvoiceLine__c invLine : [SELECT Id,blng__OrderProduct__r.Order.Pricebook2.Area__c, blng__Invoice__c, blng__Invoice__r.Progressivo_fattura__c, blng__Invoice__r.Name FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :invoiceIdWithoutOrder]) {
       
                if (!areaToInvoiceList.containsKey(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c)) {areaToInvoiceList.put(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c, new Set<blng__Invoice__c>());
                }
                areaToInvoiceList.get(invLine.blng__OrderProduct__r.Order.Pricebook2.Area__c).add(invLine.blng__Invoice__r);
            }
        }

        for (String area : areaToInvoiceList.keySet()) {

            CustomAutonumber__c autonumber = CustomAutonumber__c.getValues(area);
            if (autonumber != null) {
                for (blng__Invoice__c invoice : areaToInvoiceList.get(area)) {
                    
                    invoice.Progressivo_fattura__c = String.valueOf(Integer.valueOf(autonumber.ProgressiveNumber__c + 1)).leftPad(8,'0');
                    autonumber.ProgressiveNumber__c ++;
                    autonumber.Last_Autonumber__c= invoice.Progressivo_fattura__c;
                    invoiceToUpdate.add(invoice);
                }
            autonumberList.add(autonumber);
            }
        }

        if (!autonumberList.isEmpty()) {update autonumberList;
        }

        if (!invoiceToUpdate.isEmpty()) {update invoiceToUpdate;
        }
    }
    
    public static void setDocumentId(List<blng__Invoice__c> invoiceList) {

        CustomAutonumber__c lastDocId = CustomAutonumber__c.getValues('DocumentId');
        for(blng__Invoice__c invoice : invoiceList){
            if (lastDocId != null) {
                invoice.DocumentId__c = String.valueOf(-Integer.valueOf(lastDocId.ProgressiveNumber__c + 1));
                lastDocId.ProgressiveNumber__c ++;
                lastDocId.Last_Autonumber__c= invoice.DocumentId__c;
            }    
        }
        //update creditNoteList;
        update lastDocId;
    }

    public static void setDueDate(List<blng__Invoice__c> invoiceList) {
        Map<String, InvoiceDueDateCalculation__mdt> iddcMap = InvoiceDueDateCalculation__mdt.getAll();
        System.debug('iddcMap='+iddcMap);

        for(blng__Invoice__c invoice : invoiceList) {
            System.debug('invoice.BillingProfile__c='+invoice.BillingProfile__c);
            if(invoice.BillingProfile__c != null) {
                System.debug('invoice.BillingProfile__r.PaymentConditions__c='+invoice.BillingProfile__r.PaymentConditions__c);
                if(invoice.BillingProfile__r.PaymentConditions__c != null) {
                    String paymentConditions = null;
                    if(invoice.BillingProfile__r.PaymentConditions__c.indexOfAny('0123456789') == 0) {
                        paymentConditions = 'X' + invoice.BillingProfile__r.PaymentConditions__c;
                    } else {paymentConditions = invoice.BillingProfile__r.PaymentConditions__c;
                    }

                    System.debug('paymentConditions='+paymentConditions);
                    System.debug('invoice.blng__InvoiceDate__c='+invoice.blng__InvoiceDate__c);
                    InvoiceDueDateCalculation__mdt iddc = iddcMap.get(paymentConditions);
                    if(iddc != null) {
                        invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c.addDays(Integer.valueOf(iddc.NofDays__c));
                    } else {
                        invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
                    }
                } else {invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
                }
            } else {
                invoice.blng__DueDate__c = invoice.blng__InvoiceDate__c;
            }
            System.debug('invoice.blng__DueDate__c='+invoice.blng__DueDate__c);
        }

        update invoiceList;
    }

    //Lutech AT 07/09/2022  CR#44604 - Controlli pre fatturazione
    public static void setCustomAutonumberForStatusPosted(List<blng__Invoice__c> invoiceList,Map<Id,blng__Invoice__c> invoiceOldMap) {
        Set<Id> invoiceIds =  new Set<Id>();
        for(blng__Invoice__c bIn : invoiceList){
            if(invoiceOldMap.get(bIn.Id).blng__InvoiceStatus__c != bIn.blng__InvoiceStatus__c && bIn.blng__InvoiceStatus__c == 'Posted'){
                invoiceIds.add(bIn.Id);
            }
        }
        if(invoiceIds.size() > 0){
            system.debug('invoiceIds : '+invoiceIds.size());
            InvoiceAfterPostingLogicsBatch batch = new InvoiceAfterPostingLogicsBatch(invoiceIds);
            Database.executeBatch(batch);
            //Database.executeBatch(new InvoiceAfterPostingLogicsBatch(invoiceIds));
        }
    }

    public static void setCastellettoIva(List<blng__Invoice__c> invoiceList) {

        set<id> IdInvoiceSet = new set<id>();

        for(blng__Invoice__c Inv :invoiceList){
            IdInvoiceSet.add(Inv.id);
        }
        /*
        map<id,list<blng__InvoiceLine__c>> InvoiceLineMap = new map<id,list<blng__InvoiceLine__c>>();
        list<blng__InvoiceLine__c> LinesList = new list<blng__InvoiceLine__c>();

        for(blng__InvoiceLine__c InvLine : [SELECT blng__Invoice__c,blng__Subtotal__c,blng__TaxAmount__c,blng__TotalAmount__c,blng__TaxPercentageApplied__c 
                                            FROM blng__InvoiceLine__c where id in :IdInvoiceSet]){

                                                LinesList =(InvoiceLineMap.containsKey(InvLine.blng__Invoice__c))?InvoiceLineMap.get(InvLine.blng__Invoice__c): new list<blng__InvoiceLine__c>();
                                                LinesList.add(InvLine);
                                                InvoiceLineMap.put(InvLine.blng__Invoice__c, LinesList);
        }*/


        map<double,double> Iva_Subtotal = new map<double,double>();
        list<Castelletto_IVA__c> CastellettoList = new list<Castelletto_IVA__c>();
        Map<id,blng__InvoiceLine__c> CreateInvoiceLineMap = new Map<id,blng__InvoiceLine__c>();
        map<String,double> Fattura_totalUsage_Map = new map<String,double>();
        
        Double Imponibile,Imponibile_IVA,Totale_Complessivo,Totale_Fattura,total,Subtotal,Importo,ArrotondamentoUsage,Arrotondamento;


        Product2 Prod_Arrotondamento = [select id,SBQQ__BillingFrequency__c,blng__BillingRule__c,SBQQ__ChargeType__c,VATManagementType__c,blng__TaxRule__c 
                                        from product2 where ProductCode = 'ARR'];


        blng__TaxTreatment__c TaxTreatment = [select id,blng__TaxRule__c,blng__TaxLegalEntity__c,blng__Active__c 
                                                from blng__TaxTreatment__c 
                                                where blng__TaxRule__c = :Prod_Arrotondamento.blng__TaxRule__c and blng__Active__c = true];

        Map<Id,Id> usageSummaryIds = new Map<Id,Id>();
        for(blng__InvoiceLine__c invoiceLine : [SELECT blng__UsageSummary__c, blng__Invoice__c
                                                FROM blng__InvoiceLine__c
                                                WHERE blng__Invoice__c IN :IdInvoiceSet
                                                AND blng__UsageSummary__c != null]) {
            usageSummaryIds.put(invoiceLine.blng__UsageSummary__c, invoiceLine.blng__Invoice__c);
        }
        
        //prendo tutti gli usage degli usage summary delle invoice trattate e creo mappa di fattura e totale importo degli usage
        for(blng__Usage__c Usage:[select id,blng__UsageSummary__c,blng__UsageSummary__r.blng__Invoice__c,Usage_Total__c , (Select Id From Payments__r limit 1) 
                                    from blng__Usage__c 
                                    where blng__UsageSummary__c IN :usageSummaryIds.keySet()]){
            Id invoiceId = usageSummaryIds.get(usage.blng__UsageSummary__c);
            System.debug('usage='+Usage);
            total = (Fattura_totalUsage_Map.containsKey(invoiceId))?Fattura_totalUsage_Map.get(invoiceId):0;
            total += Usage.Usage_Total__c;
            System.debug('total='+total);
            Fattura_totalUsage_Map.put(invoiceId,total);
            System.debug('Fattura_totalUsage_Map='+Fattura_totalUsage_Map);     
    
        }

        List<blng__PaymentAllocationInvoice__c> insertListPaymentAllocation = new List<blng__PaymentAllocationInvoice__c>();
        List<blng__Payment__c> insertPaymentList = new List<blng__Payment__c>();
        //ciclo sulle fatture per prendere le relative righe
        for(blng__Invoice__c Inv :invoiceList){

            Iva_Subtotal = new map<double,double>();
            Totale_Fattura = 0;
            Importo = 0;
            Arrotondamento = 0;

            String taxCountry = Prod_Arrotondamento.VATManagementType__c + '-';
            if(Inv.blng__Account__r.FormaAnagrafica__c != null && Inv.blng__Account__r.FormaAnagrafica__c.equalsIgnoreCase('PA') && Inv.blng__Account__r.Nation__c != null && Inv.blng__Account__r.Nation__c.equalsIgnoreCase('IT')){taxCountry = taxCountry + 'PA-';
            }else{
                taxCountry = taxCountry + Inv.blng__Account__r.RecordType.DeveloperName + '-';
            }
            taxCountry = taxCountry + Inv.blng__Account__r.AccountRegion__c;
  
            //ciclo sulle righe delle fatture
            Map<Double, Decimal> mapLineForIva = new Map<Double, Decimal>();
            for(blng__InvoiceLine__c InvLine :Inv.blng__InvoiceInvoiceLines__r){
                System.debug('InvLine='+InvLine);
                Subtotal = (Iva_Subtotal.containsKey(InvLine.blng__TaxPercentageApplied__c))?Iva_Subtotal.get(InvLine.blng__TaxPercentageApplied__c):0;
                Subtotal += InvLine.blng__Subtotal__c;
                //valorizzo la mappa con chiave %iva e valore la somma delle righe fattura con quella %iva
                Iva_Subtotal.put(InvLine.blng__TaxPercentageApplied__c,Subtotal);

                if(mapLineForIva != null && mapLineForIva.size() > 0 && mapLineForIva.containsKey(InvLine.blng__TaxPercentageApplied__c)){
                    Decimal doubleTemp = mapLineForIva.get(InvLine.blng__TaxPercentageApplied__c);
                    doubleTemp = doubleTemp += InvLine.blng__TotalAmount__c;
                    mapLineForIva.put(InvLine.blng__TaxPercentageApplied__c, doubleTemp);
                }else{
                    Decimal doubleTemp;
                    doubleTemp = InvLine.blng__TotalAmount__c;
                    mapLineForIva.put(InvLine.blng__TaxPercentageApplied__c, doubleTemp);   
                }
            }

            //per ogni tipologia di iva delle righe fatture creo record di castelletto iva
            for(Double Iva : Iva_Subtotal.keySet()){

                Imponibile = Iva_Subtotal.get(Iva);
                system.debug('Imponibile--->'+Imponibile);
                system.debug('Iva--->'+Iva);
                Imponibile_IVA = Imponibile*Iva/100;
                Totale_Complessivo = Imponibile + Imponibile_IVA;
                Totale_Fattura+= Totale_Complessivo;
                
                Castelletto_IVA__c Castelletto = new Castelletto_IVA__c(Invoice__c = Inv.id,
                                                                        Aliquota_IVA__c = Iva,
                                                                        Imponibile__c = Imponibile,
                                                                        Imponibile_IVA__c = Imponibile_IVA,
                                                                        Totale_Complessivo__c = Totale_Complessivo);

                CastellettoList.add(Castelletto);

                System.debug('mapLineForIva::: '+mapLineForIva);
                System.debug('Decimal.valueOf(Totale_Complessivo).setScale(2)::: '+Decimal.valueOf(Totale_Complessivo).setScale(2));

                if(Iva != 0 && mapLineForIva != null && mapLineForIva.size() > 0 && mapLineForIva.containsKey(Iva) && (Decimal.valueOf(Totale_Complessivo).setScale(2) - mapLineForIva.get(Iva)) != 0){
                    blng__InvoiceLine__c CreateInvoiceLine = addInvoiceArr(Totale_Complessivo, mapLineForIva.get(Iva), Prod_Arrotondamento, TaxTreatment, Inv);
                    CreateInvoiceLineMap.put(Inv.id,CreateInvoiceLine);
                }
            }

            importo = ((Decimal.valueOf(Totale_Fattura).setScale(2)) - Inv.blng__TotalAmount__c);
            System.debug('importo='+importo);

            //se il totale della fattura calcolata non corrisponde al totale fattura presente su Sf
            //allora il calcolo è errato e bisogna sistemare importo totale della fattura scrivendo una riga di fattura come arrotondamento
            
            
            System.debug('Fattura_totalUsage_Map.containsKey(Inv.id)='+Fattura_totalUsage_Map.containsKey(Inv.id));
            //caso castelletto iva Fattura da Usage Summary
            if(!String.isBlank(Inv.BillingProfile__c) && !String.isBlank(Inv.BillingProfile__r.PaymentMethod__c) && !String.isBlank(Inv.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c) && 
            (Inv.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '9' || Inv.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '10' )){
                if (Fattura_totalUsage_Map.containsKey(Inv.id)){
                    ArrotondamentoUsage = Fattura_totalUsage_Map.get(Inv.id)-(Inv.blng__TotalAmount__c + Importo);
                    System.debug('ArrotondamentoUsage='+ArrotondamentoUsage);
                    //AD - Manage rounding between invoice and Payment - 19/12/2022 - Start 
                    blng__PaymentAllocationInvoice__c newPaymentAllocation = new blng__PaymentAllocationInvoice__c();
                    blng__Payment__c paymentOk = new blng__Payment__c();
                    List<blng__Payment__c> listPaymentInvoice = new List<blng__Payment__c>();
                    listPaymentInvoice = Inv.blng__Payments__r;
                    
                    if(ArrotondamentoUsage > 0){
                        System.debug('listPaymentInvoice::: '+listPaymentInvoice);
                        if(!listPaymentInvoice.isEmpty()){
                            for(blng__Payment__c singlePayment : listPaymentInvoice){
                                System.debug('singlePayment.blng__Amount__c::: '+singlePayment.blng__Amount__c);
                                if(singlePayment.blng__Amount__c >= ArrotondamentoUsage)
                                    paymentOk = singlePayment;
                            }
                        }
                        System.debug('paymentOk::: '+paymentOk);  
                        if(paymentOk != null && paymentOk != new blng__Payment__c()){
                            newPaymentAllocation.blng__Invoice__c = Inv.Id;
                            newPaymentAllocation.blng__Payment__c = paymentOk.Id;
                            newPaymentAllocation.blng__Type__c = 'Unallocation';
                            newPaymentAllocation.blng__Amount__c = Math.abs(ArrotondamentoUsage);
                            insertListPaymentAllocation.add(newPaymentAllocation);
                        }
                    }else{  
                        blng__Payment__c newPayment = new blng__Payment__c(); 
                        newPayment.NotVisibleInApp__c = true;
                        newPayment.blng__Account__c = Inv.blng__Account__c;
                        newPayment.blng__PaymentDate__c = System.today();
                        newPayment.blng__Amount__c = Math.abs(ArrotondamentoUsage);
                        newPayment.blng__Invoice__c = Inv.Id;
                        insertPaymentList.add(newPayment);

                        newPaymentAllocation.blng__Invoice__c = Inv.Id;
                        newPaymentAllocation.blng__Type__c = 'Allocation';
                        newPaymentAllocation.blng__Amount__c = Math.abs(ArrotondamentoUsage);
                        insertListPaymentAllocation.add(newPaymentAllocation);
                    }
                    
                    //AD - Manage rounding between invoice and Payment - 19/12/2022 - End
                }
            }    
        }

        insert CastellettoList;

        if(CreateInvoiceLineMap.size()>0)
            Insert CreateInvoiceLineMap.values();

        //AD - Manage rounding between invoice and Payment - 19/12/2022 - Start 
        Map<String, String> mapAllocation = new Map<String, String>();
        if(!insertPaymentList.isEmpty()){
            insert insertPaymentList;
            for(blng__Payment__c itemPList : insertPaymentList)
                mapAllocation.put(itemPList.blng__Invoice__c, itemPList.Id);    
        }
        if(!insertListPaymentAllocation.isEmpty()){
            for(blng__PaymentAllocationInvoice__c itemPaList : insertListPaymentAllocation){
                if(itemPaList.blng__Type__c == 'Allocation' && String.isBlank(itemPaList.blng__Payment__c) && mapAllocation != null && mapAllocation.containsKey(itemPaList.blng__Invoice__c))
                    itemPaList.blng__Payment__c = mapAllocation.get(itemPaList.blng__Invoice__c);    
            }
            System.debug('insertListPaymentAllocation::: '+insertListPaymentAllocation);
            insert insertListPaymentAllocation;    
        }
        //AD - Manage rounding between invoice and Payment - 19/12/2022 - End    
    }

    public static blng__InvoiceLine__c addInvoiceArr(Double vatDouble, Decimal lineAmountDouble, Product2 Prod_Arrotondamento, blng__TaxTreatment__c TaxTreatment, blng__Invoice__c Inv) {
        blng__InvoiceLine__c CreateInvoiceLine = new blng__InvoiceLine__c();

        system.debug('Decimal.valueOf(Totale_Fattura).setScale(2)--->'+ Decimal.valueOf(vatDouble).setScale(2));
        system.debug('blng__TotalAmount__c--->'+ Inv.blng__TotalAmount__c);
        system.debug('Decimal.valueOf(Totale_Fattura).setScale(2) - Inv.blng__TotalAmount__c--->'+ (Decimal.valueOf(vatDouble).setScale(2) - lineAmountDouble));
        Double Importo = ((Decimal.valueOf(vatDouble).setScale(2)) - lineAmountDouble);
        system.debug('Importo--->'+Importo);

        CreateInvoiceLine.blng__Invoice__c = Inv.id;
        CreateInvoiceLine.Name = 'Arrotondamento';
        CreateInvoiceLine.blng__BillingFrequency__c = Prod_Arrotondamento.SBQQ__BillingFrequency__c;
        CreateInvoiceLine.blng__BillingRule__c = Prod_Arrotondamento.blng__BillingRule__c;
        CreateInvoiceLine.blng__ChargeDate__c = Inv.blng__InvoiceDate__c;
        CreateInvoiceLine.blng__ChargeType__c = Prod_Arrotondamento.SBQQ__ChargeType__c;
        CreateInvoiceLine.blng__EndDate__c = Inv.blng__InvoiceDate__c;
        CreateInvoiceLine.blng__LegalEntity__c = TaxTreatment.blng__TaxLegalEntity__c;
        CreateInvoiceLine.blng__Quantity__c = 1;
        CreateInvoiceLine.blng__StartDate__c =  Inv.blng__InvoiceDate__c;
        CreateInvoiceLine.blng__TaxRule__c = Prod_Arrotondamento.blng__TaxRule__c;
        CreateInvoiceLine.blng__TaxTreatment__c = taxTreatment.id;
        CreateInvoiceLine.blng__UnitPrice__c = 0;
        CreateInvoiceLine.blng__Product__c = Prod_Arrotondamento.id;
        CreateInvoiceLine.blng__Subtotal__c = 0;
        CreateInvoiceLine.blng__TaxPercentageApplied__c = 0;
        CreateInvoiceLine.blng__TaxAmount__c = Importo;
        CreateInvoiceLine.blng__TotalAmount__c = Importo;

        return CreateInvoiceLine;
    }    
}