/**
 * @TestClass: OrderItemTriggerHandlerTest
 */
public class OrderTriggerHandler {
    public static void createNotes(List<Order> triggerNew) {
        List<SBQQ__QuoteLine__c> listQuoteLineNotes = new List<SBQQ__QuoteLine__c>();
        Map<String, OrderNotes__mdt> completeMapNote = new Map<String, OrderNotes__mdt>();
        Map<String, Order> quoteIds = new Map<String, Order>();
        Map<String, String> orderNotesMap = new Map<String, String>();
        Set<String> accountTypeSet = new Set<String>();
        Set<String> discountTypeSet = new Set<String>();
        Set<String> pricebookTypeSet = new Set<String>();
        Map<String, List<SBQQ__QuoteLine__c>> mapOrderInfo = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<Invoice_Note__c> createNoteList = new List<Invoice_Note__c>();

        for(Order itemOrder : triggerNew)
            quoteIds.put(itemOrder.SBQQ__Quote__c, itemOrder);

        if(!quoteIds.isEmpty() && quoteIds.size() > 0){
            listQuoteLineNotes = [Select Id, SBQQ__Quote__c, Description_custom__c, SBQQ__Quote__r.SBQQ__Account__r.RecordType.Name, SBQQ__Quote__r.DiscountType__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Type__c,
            SBQQ__Quote__r.HeatGeneratorTypePresent__c, SBQQ__Quote__r.NominalPowerGeneratorPresent__c, SBQQ__Quote__r.AreaReplaced__c, SBQQ__Quote__r.InstallationType__c, SBQQ__Quote__r.ClimaticZone__c,
            SBQQ__Quote__r.Name, SBQQ__Quote__r.PropertyZipCode__c, SBQQ__Quote__r.PropertyCity__c, SBQQ__Quote__r.PropertyStreet__c, SBQQ__Quote__r.PropertyStreetNumber__c, SBQQ__Quote__r.PropertyProvince__c,
            SBQQ__Product__r.Type__c, SBQQ__Product__r.Categoria_prodotto__c, SBQQ__Product__r.SizekWt__c, SBQQ__Product__r.ProductCode From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN: quoteIds.keyset() AND SBQQ__Quote__r.RecordType.DeveloperName = 'EfficienzaEnergetica' AND ClonedSignificantAsset__c = false];

            for(SBQQ__QuoteLine__c itemQuoteLine : listQuoteLineNotes){
                accountTypeSet.add(itemQuoteLine.SBQQ__Quote__r.SBQQ__Account__r.RecordType.Name);
                discountTypeSet.add(itemQuoteLine.SBQQ__Quote__r.DiscountType__c);
                pricebookTypeSet.add(itemQuoteLine.SBQQ__Quote__r.SBQQ__PriceBook__r.Type__c);

                if(!mapOrderInfo.isEmpty() && mapOrderInfo.containsKey(quoteIds.get(itemQuoteLine.SBQQ__Quote__c).Id)){
                    List<SBQQ__QuoteLine__c> lineListTemp = new List<SBQQ__QuoteLine__c>(); 
                    lineListTemp = mapOrderInfo.get(quoteIds.get(itemQuoteLine.SBQQ__Quote__c).Id); 
                    lineListTemp.add(itemQuoteLine);
                    mapOrderInfo.put(quoteIds.get(itemQuoteLine.SBQQ__Quote__c).Id, lineListTemp);
                }else{
                    List<SBQQ__QuoteLine__c> lineListTemp = new List<SBQQ__QuoteLine__c>(); 
                    lineListTemp.add(itemQuoteLine);
                    mapOrderInfo.put(quoteIds.get(itemQuoteLine.SBQQ__Quote__c).Id, lineListTemp);   
                }
            }
        }    
        system.debug('accountTypeSet: '+accountTypeSet);
        system.debug('discountTypeSet: '+ discountTypeSet);
        system.debug('pricebookTypeSet: '+pricebookTypeSet);   
        if(!listQuoteLineNotes.isEmpty() && listQuoteLineNotes.size() > 0){ 
            completeMapNote = populateNote(accountTypeSet, discountTypeSet, pricebookTypeSet); 

            for(String itemOrder : mapOrderInfo.keyset()){
                System.debug('itemOrder::: '+itemOrder);
                System.debug('mapOrderInfo::: '+mapOrderInfo);
                Invoice_Note__c createNoteSingle = new Invoice_Note__c();
                String noteText = insertNewNote(mapOrderInfo.get(itemOrder), completeMapNote);
                if(noteText != null && noteText != '') {
                    createNoteSingle.Note__c = noteText;
                    createNoteSingle.Account__c = quoteIds.get(mapOrderInfo.get(itemOrder)[0].SBQQ__Quote__c).AccountId;
                    createNoteSingle.Order__c = itemOrder;
                    createNoteSingle.End_Date__c = System.today() + 30;
                    createNoteSingle.Start_Date__c = System.today();
                    createNoteList.add(createNoteSingle);
                }
            }

            if(!createNoteList.isEmpty() && createNoteList.size() > 0)
                insert createNoteList;
        }    
    }

    public static Map<String, OrderNotes__mdt> populateNote(Set<String> accountTypeSet, Set<String> discountTypeSet, Set<String> pricebookTypeSet){
        List<OrderNotes__mdt> noteForOrder = new List<OrderNotes__mdt>();
        Map<String, OrderNotes__mdt> returnMap = new Map<String, OrderNotes__mdt>();
        
        noteForOrder = [Select Id, AccountType__c, DiscountType__c, PricebookType__c, (Select Id, MasterLabel, OrderNotes__c, OrderPart__c, PartOfNote__c, PlaceholderBlank__c From OrderNotePlaceholder__r) 
                        From OrderNotes__mdt Where AccountType__c IN: accountTypeSet And DiscountType__c IN: discountTypeSet And PricebookType__c IN: pricebookTypeSet];

        for(OrderNotes__mdt itemMeta : noteForOrder)
            returnMap.put(itemMeta.AccountType__c+itemMeta.DiscountType__c+itemMeta.PricebookType__c, itemMeta);  

        return returnMap;
    }
     
    public static Integer sentNumberValue(String typeNote){
        Integer returnValue = 0;
        switch on typeNote {
            when 'Persona Fisica - Eco Bonus - EEim'{	
                returnValue = 1;
            }when 'Persona Fisica - Eco Bonus - EEin'{	
                returnValue = 2;
            }when 'Persona Giuridica - Eco Bonus - EEim'{	
                returnValue = 3;
            }when 'Persona Giuridica - Eco Bonus - EEin'{
                returnValue = 4;
            }when 'Persona Fisica - Bonus Casa - EEim'{	
                returnValue = 5;
            }when 'Persona Giuridica - Bonus Casa - EEin'{	
                returnValue = 6;
            }    
        } 
        
        return returnValue;
    }

    public static String insertNewNote(List<SBQQ__QuoteLine__c> listQuoteLine, Map<String, OrderNotes__mdt> mapMetadata){
        OrderNotes__mdt noteMetadataOK = new OrderNotes__mdt();
        String notePlaceholderOK = '';
        noteMetadataOK = mapMetadata.get(listQuoteLine[0].SBQQ__Quote__r.SBQQ__Account__r.RecordType.Name+listQuoteLine[0].SBQQ__Quote__r.DiscountType__c+listQuoteLine[0].SBQQ__Quote__r.SBQQ__PriceBook__r.Type__c);
        
        if(noteMetadataOK != null && listQuoteLine != null && listQuoteLine.size() > 0)
            notePlaceholderOK = SelectPlaceholder(noteMetadataOK.OrderNotePlaceholder__r, listQuoteLine, listQuoteLine[0].SBQQ__Quote__r.SBQQ__Account__r.RecordType.Name+' - '+listQuoteLine[0].SBQQ__Quote__r.DiscountType__c+' - '+listQuoteLine[0].SBQQ__Quote__r.SBQQ__PriceBook__r.Type__c);

        return notePlaceholderOK;
    }

    public static String SelectPlaceholder(List<OrderNotePlaceholder__mdt> listPlaceholderComplete, List<SBQQ__QuoteLine__c> listQuoteLine, String typeMetadata){
        System.debug('typeMetadata::: '+typeMetadata);
        Integer typeCheck = sentNumberValue(typeMetadata);
        List<OrderNotePlaceholder__mdt> returnList = new List<OrderNotePlaceholder__mdt>();
        List<metaPlaceholerWrapper> listOrdered = new List<metaPlaceholerWrapper>();
        String returnStringNote = '';
        
        for(OrderNotePlaceholder__mdt itemPlaceholer : listPlaceholderComplete)
            listOrdered.add(new metaPlaceholerWrapper(itemPlaceholer));
        
        listOrdered.sort(); 
        
        List<Integer> tipologiaCheck = new List<Integer>();
        List<Integer> blankCheck = new List<Integer>();
        Boolean check1 = true;
        Boolean check2 = true;
        Boolean check3 = true;
        Boolean check4 = true;
        Boolean check5 = true;
        Boolean check6 = true;
        Boolean check7 = true;
        Boolean check8 = true;
        Boolean check9 = true;
        Boolean check10 = true;
        for(metaPlaceholerWrapper itemPlaceholer : listOrdered){
            for(SBQQ__QuoteLine__c itemLine : listQuoteLine){
                if(typeCheck == 1 || typeCheck == 3 || typeCheck == 5 || typeCheck == 6){
                    if(tipologiaCheck.size() < 2 && !String.isBlank(itemLine.SBQQ__Product__r.Categoria_prodotto__c) && (itemLine.SBQQ__Product__r.Categoria_prodotto__c == 'Componenti Generatore di Calore' || itemLine.SBQQ__Product__r.Categoria_prodotto__c == 'Componenti Unità Esterne ad Espansione Diretta')){
                        if(itemPlaceholer.element.MasterLabel == '<Tipologia>' && !String.isBlank(itemLine.SBQQ__Product__r.Type__c)){
                            returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Tipologia>', itemLine.SBQQ__Product__r.Type__c) + '|';
                            tipologiaCheck.add(1);
                        }else if(itemPlaceholer.element.MasterLabel == '<Capacità in kW>' && itemLine.SBQQ__Product__r.SizekWt__c != null){
                            returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Capacità in kW>', String.valueOf(itemLine.SBQQ__Product__r.SizekWt__c)) + 'KW |';
                            tipologiaCheck.add(2);   
                        }    
                    }
                }
                system.debug('master label: '+ itemPlaceholer.element.MasterLabel + ' itemLine.Description_custom__c: '+itemLine.Description_custom__c +' itemLine.SBQQ__Product__r.ProductCode :'+ itemLine.SBQQ__Product__r.ProductCode );
                if(typeCheck == 1 || typeCheck == 3){    
                    if(check1 && itemPlaceholer.element.MasterLabel == '<Modello Termovalvola>' && !String.isBlank(itemLine.Description_custom__c) && itemLine.SBQQ__Product__r.ProductCode  == 'TERMO'){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Modello Termovalvola>', itemLine.Description_custom__c) + '|';
                        check1 = false;
                    }
                }
                if(typeCheck == 1 || typeCheck == 3){       
                    if(check2 && itemPlaceholer.element.MasterLabel == '<Modello Sonda>' && !String.isBlank(itemLine.Description_custom__c) && itemLine.SBQQ__Product__r.ProductCode  == 'SONDA'){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Modello Sonda>', itemLine.Description_custom__c) + '|'; 
                        check2 = false;
                    }
                }
                if(typeCheck == 1 || typeCheck == 3){         
                    if(check3 && itemPlaceholer.element.MasterLabel == '<Modello Cronotermostato>' && !String.isBlank(itemLine.Description_custom__c) && itemLine.SBQQ__Product__r.ProductCode  == 'CRONO'){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Modello Cronotermostato>', itemLine.Description_custom__c) + '|';
                        check3 = false; 
                    }
                }

                if(typeCheck == 2 || typeCheck == 4){
                    if(check6 && itemPlaceholer.element.MasterLabel == '<Tipologia Generatore>' && !String.isBlank(itemLine.SBQQ__Quote__r.HeatGeneratorTypePresent__c)){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Tipologia Generatore di Calore presente>', itemLine.SBQQ__Quote__r.HeatGeneratorTypePresent__c) + '|';
                        check6 = false;
                    }
                    if(check7 && itemPlaceholer.element.MasterLabel == '<Potenza nominale>' && itemLine.SBQQ__Quote__r.NominalPowerGeneratorPresent__c != null){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Potenza nominale Generatore presente>', String.valueOf(itemLine.SBQQ__Quote__r.NominalPowerGeneratorPresent__c)) + '|';
                        check7 = false;
                    } 
                    if(check8 && itemPlaceholer.element.MasterLabel == '<Metratura Sostituita>' && itemLine.SBQQ__Quote__r.AreaReplaced__c != null){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Metratura Sostituita>', String.valueOf(itemLine.SBQQ__Quote__r.AreaReplaced__c)) + '|';
                        check8 = false;
                    }  
                    if(check9 && itemPlaceholer.element.MasterLabel == '<Tipologia di Installazione>' && !String.isBlank(itemLine.SBQQ__Quote__r.InstallationType__c)){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Tipologia di Installazione>', itemLine.SBQQ__Quote__r.InstallationType__c) + '|';
                        check9 = false;
                    }
                    if(check10 && itemPlaceholer.element.MasterLabel == '<Zona Climatica>' && !String.isBlank(itemLine.SBQQ__Quote__r.ClimaticZone__c)){
                        returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<Zona Climatica>', itemLine.SBQQ__Quote__r.ClimaticZone__c) + '|';
                        check10 = false;
                    } 
                } 

                //For all categories
                if(check4 && itemPlaceholer.element.MasterLabel == '<IDQuote>' && !String.isBlank(itemLine.SBQQ__Quote__r.Name)){
                    returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c.replace('<IDQuote>', itemLine.SBQQ__Quote__r.Name) + '|';
                    check4 = false;
                }    
                
                //For all categories
                if(check5 && itemPlaceholer.element.MasterLabel == '<Address>'){
                    System.debug('itemLine.SBQQ__Quote__r.PropertyCity__c::: '+itemLine.SBQQ__Quote__r.PropertyCity__c);
                    String addressTemp = itemPlaceholer.element.PartOfNote__c;
                    
                    if(!String.isBlank(itemLine.SBQQ__Quote__r.PropertyZipCode__c))
                        addressTemp = addressTemp.replace('<CAP>', itemLine.SBQQ__Quote__r.PropertyZipCode__c);
                    else
                        addressTemp = addressTemp.replace('<CAP>', '');
                        
                    if(!String.isBlank(itemLine.SBQQ__Quote__r.PropertyStreetNumber__c) && !String.isBlank(itemLine.SBQQ__Quote__r.PropertyStreet__c))
                        addressTemp = addressTemp.replace('<Indirizzo Immobile>', itemLine.SBQQ__Quote__r.PropertyStreet__c + ', '+ itemLine.SBQQ__Quote__r.PropertyStreetNumber__c);
                    else
                        addressTemp = addressTemp.replace('<Indirizzo Immobile>', '');

                    if(!String.isBlank(itemLine.SBQQ__Quote__r.PropertyCity__c))
                        addressTemp = addressTemp.replace('<Città>', itemLine.SBQQ__Quote__r.PropertyCity__c);
                    else
                        addressTemp = addressTemp.replace('<Città>', '');  

                    if(!String.isBlank(itemLine.SBQQ__Quote__r.PropertyProvince__c))
                        addressTemp = addressTemp.replace('<Provincia>', itemLine.SBQQ__Quote__r.PropertyProvince__c);
                    else
                        addressTemp = addressTemp.replace('<Provincia>', '');

                    returnStringNote = returnStringNote + addressTemp + '|';    
                        
                    check5 = false;    
                }    
            } 
            if(itemPlaceholer.element.PlaceholderBlank__c && (((typeCheck == 1 || typeCheck == 2  || typeCheck == 5) && blankCheck.size() < 2) || ((typeCheck == 3 || typeCheck == 4  || typeCheck == 6) && blankCheck.size() < 1))){
                returnStringNote = returnStringNote + itemPlaceholer.element.PartOfNote__c  + '|';
                blankCheck.add(1);
            }   
        }

        

        System.debug('returnStringNote::: '+returnStringNote);
        return returnStringNote;
    }

    public class metaPlaceholerWrapper implements Comparable {

        public OrderNotePlaceholder__mdt element;

        metaPlaceholerWrapper(OrderNotePlaceholder__mdt element) {
            this.element = element;
        }


        public Integer compareTo(Object compareTo) {

            metaPlaceholerWrapper metaToCompare = (metaPlaceholerWrapper) compareTo;

            Integer returnValue = 0;

            if(element.OrderPart__c > metaToCompare.element.OrderPart__c)
                returnValue = 1;
            else if (element.OrderPart__c < metaToCompare.element.OrderPart__c) 
                returnValue = -1;
            else if ((element.OrderPart__c == null) && (metaToCompare.element.OrderPart__c != null))
                returnValue = -1;
            else if ((element.OrderPart__c != null) && (metaToCompare.element.OrderPart__c == null))
                returnValue = 1;


            return returnValue;

        }
    }
}