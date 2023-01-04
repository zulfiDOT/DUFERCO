/*
 *   @TestClass: QuoteTriggerHandlerTest
*/
public class QuoteTriggerHandler {
    
    public static Map<String, List<SBQQ__Quote__c>> Promo_Quotes = new Map<String, List<SBQQ__Quote__c>>();
    public static Map<String, List<SBQQ__Quote__c>> ValidPromo_Quotes = new Map<String, List<SBQQ__Quote__c>>();
    public static Set<SBQQ__Quote__c> INValidQuotes = new Set<SBQQ__Quote__c>();
    public static Map<String,Id> PromoCode_Id = new Map<String,Id>();
    public static QuotePromoInfo quotePRomo = new QuotePromoInfo();
    
    //Before Trigger//
    public static void getValidPromoCode(List<SBQQ__Quote__c> NewQuotesList){
        try{
            Set<String> PromoCodeToCheck = new Set<String>();
            
            for(SBQQ__Quote__c singleQuote : NewQuotesList){
                if(String.isNotBlank(singleQuote.Promotion_Code__c)){
                    PromoCodeToCheck.add(singleQuote.Promotion_Code__c);
                    
                    List<SBQQ__Quote__c> Quotes = new List<SBQQ__Quote__c>{singleQuote};
                        if(Promo_Quotes.containskey(singleQuote.Promotion_Code__c)){
                            Quotes.addAll(Promo_Quotes.get(singleQuote.Promotion_Code__c));
                        }
                    Promo_Quotes.put(singleQuote.Promotion_Code__c,Quotes);
                }
            }
            getPromoId(PromoCodeToCheck);
            verifyQuotePromoValidity(NewQuotesList);
            
            quotePRomo.PromoCode_Id = PromoCode_Id;
            quotePRomo.ValidPromo_Quotes = ValidPromo_Quotes;
            quotePromo.INValidQuotes = INValidQuotes;
            
        }catch(exception e){
            system.debug('error: '+e.getMessage()); //Sarabbe meglio tracciare con un oggetto
        }
    }
    
    public static void getValidPromoCode(Map<Id,SBQQ__Quote__c> UpdatedQuotesMap,Map<Id,SBQQ__Quote__c> OldQuotesMap ){
        Set<String> PromoCodeToCheck = new Set<String>();
        try{
        for(Id singleQuoteId : UpdatedQuotesMap.keySet()){
            if(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c!=OldQuotesMap.get(singleQuoteId).Promotion_Code__c){
                if(String.isNotBlank(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c)){
                    PromoCodeToCheck.add(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c);
                    
                    List<SBQQ__Quote__c> Quotes = new List<SBQQ__Quote__c>{UpdatedQuotesMap.get(singleQuoteId)};
                        if(Promo_Quotes.containskey(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c)){
                            Quotes.addAll(Promo_Quotes.get(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c));
                        }
                    Promo_Quotes.put(UpdatedQuotesMap.get(singleQuoteId).Promotion_Code__c,Quotes);
                }else{
                    INValidQuotes.add(UpdatedQuotesMap.get(singleQuoteId));//Quote da ripulire
                    system.debug('quote da ripulire: '+INValidQuotes);
                }
            }
        }
        getPromoId(PromoCodeToCheck);
        verifyQuotePromoValidity(UpdatedQuotesMap.values());
        
        quotePRomo.PromoCode_Id = PromoCode_Id;
        quotePRomo.ValidPromo_Quotes = ValidPromo_Quotes;
        quotePromo.INValidQuotes = INValidQuotes;
        }catch(exception e){
            system.debug('error: '+e.getMessage()); //Sarabbe meglio tracciare con un oggetto
        }
    }
    
    
    public static void getPromoId(Set<String> PromoCodeToCheck){
        
        for(Promotion__c promo:[Select id,Promo_Code__c from Promotion__c where Promo_Code__c =: PromoCodeToCheck]){
            PromoCode_Id.put(promo.Promo_Code__c, promo.id);
        }
    }
    
    public static void verifyQuotePromoValidity(List<SBQQ__Quote__c> Quotes){
        List<SBQQ__Quote__c> ValidQuotesToClean = new List<SBQQ__Quote__c>();
        
        
        if(!PromoCode_Id.isEmpty()){
            for(String promoCode : Promo_Quotes.keySet()){
                if(PromoCode_Id.containsKey(promoCode)){
                    List<SBQQ__Quote__c> ValidQuotesPerPromo = new List<SBQQ__Quote__c>();
                    for(SBQQ__Quote__c quote : Promo_Quotes.get(promoCode)){
                        if(String.isNotBlank(quote.Promo_Code_Validation__c)) ValidQuotesToClean.add(quote);
                        ValidQuotesPerPromo.add(quote);
                    }
                    ValidPromo_Quotes.put(promoCode,ValidQuotesPerPromo);
                }else{
                    for(SBQQ__Quote__c quote : Promo_Quotes.get(promoCode)){
                        INValidQuotes.add(quote);
                    }
                }
            }
        }else{
            INValidQuotes.addAll(Quotes);
        }
        
        UpdatePromoErrorMess(ValidQuotesToClean,INValidQuotes);
    }
    
    public static void UpdatePromoErrorMess(List<SBQQ__Quote__c> ValidQuotesToClean,Set<SBQQ__Quote__c> INValidQuotes){
        if(ValidQuotesToClean.size()>0){
            for(SBQQ__Quote__c quote : ValidQuotesToClean){
                quote.Promo_Code_Validation__c='';
            }
        }
        if(INValidQuotes.size()>0){
            for(SBQQ__Quote__c quote : INValidQuotes){
                if(String.isNotBlank(quote.Promotion_Code__c)){
                    quote.Promo_Code_Validation__c='Not Existing Code';
                }else if(String.isNotBlank(quote.Promo_Code_Validation__c)){
                    quote.Promo_Code_Validation__c = '';
                }
            }
        }
    }
    
    //Before Trigger//
    
    //After Trigger//
    public static void CreateQuotePromotion(){
        try{
        List<Account_Promotion__c> AccPromToInsert = new List<Account_Promotion__c>();
        for(String promoString: quotePRomo.PromoCode_Id.keySet()){
            for(SBQQ__Quote__c quote : QuotePromo?.ValidPromo_Quotes.get(promoString)){
                Account_Promotion__c accprom = new Account_Promotion__c();
                accprom.Promotion__c = QuotePromo?.PromoCode_Id.get(promoString);
                accprom.Account__c = quote?.SBQQ__Account__c;
                accprom.Quote__c = quote.id;
                AccPromToInsert.add(accprom);
            }
        }
        
        for(Database.SaveResult sr : Database.insert(AccPromToInsert)){
            if(!sr.Success){
                system.debug('error');//Aggiungere Record di Errore
            }
        }
        }catch(exception e){
            system.debug('error: '+e.getMessage()); //Sarabbe meglio tracciare con un oggetto
        }
    }
    
    public static void DeletePromotion(){
        try{
        Set<Id> InvalidQuotePromoId = new Set<Id>();
        for(SBQQ__Quote__c quote : quotePRomo.INValidQuotes){
            InvalidQuotePromoId.add(quote.id);
        }
        List<Account_Promotion__c> AccPromoList = new List<Account_Promotion__c>([Select id from Account_Promotion__c where Quote__c =:InvalidQuotePromoId]);
        Database.delete(AccPromoList);
        }catch(exception e){
            system.debug('error: '+e.getMessage()); //Sarabbe meglio tracciare con un oggetto
        }
    }
    
    
    
    public class QuotePromoInfo {
        public Map<String, List<SBQQ__Quote__c>> ValidPromo_Quotes {get;set;}
        public Map<String,Id> PromoCode_Id {get;set;}
        public Set<SBQQ__Quote__c> INValidQuotes {get;set;}
    }

    public static void EfficienzaEnergeticaEngine (Map<Id,SBQQ__Quote__c> UpdatedQuotesMap,Map<Id,SBQQ__Quote__c> OldQuotesMap){

        List<SBQQ__Quote__c> quotesToEvalutate = new List<SBQQ__Quote__c>();
        for(Id singleQuoteId : UpdatedQuotesMap.keySet()){
            if(UpdatedQuotesMap.get(singleQuoteId).SBQQ__Status__c!=OldQuotesMap.get(singleQuoteId).SBQQ__Status__c && UpdatedQuotesMap.get(singleQuoteId).SBQQ__Status__c == '8'){
                quotesToEvalutate.add(UpdatedQuotesMap.get(singleQuoteId));
            }
        } 
        List<SBQQ__Quote__c> quoteToElaborate = getInvoiceEfficienzaEnergetica(quotesToEvalutate);           
        if(quoteToElaborate.size()>0){
            elaborateInvoiceLinesEfficienza(quoteToElaborate);
        }
    }
    
    public static List<SBQQ__Quote__c> getInvoiceEfficienzaEnergetica(List<SBQQ__Quote__c> quoteList){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteWithSignificantAsset = new Set<Id>();

        for(SBQQ__Quote__c quote: quoteList){
            if(quote.SBQQ__Status__c == '8'  && !quote.Cadastral_Category__c.startsWithIgnoreCase('C')  /*quote.Intended_General_Use__c == 'Residenziale'*/){
                quoteIds.add(quote.id);               
            }
        }
        system.debug('quoteIds: '+quoteIds);
        List<SBQQ__Quote__c> quotesToElaborate = [SELECT id,TaxableSignificantAsset__c,TaxableThirdPartyComponentsAndLabour__c, 
                                                    (select Id, SBQQ__Quote__c, SBQQ__AdditionalDiscountAmount__c, 
                                                    SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPrice__c, 
                                                    SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c, SBQQ__ChargeType__c, SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, 
                                                    SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c, SBQQ__CompoundDiscountRate__c, 
                                                    SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__DefaultSubscriptionTerm__c, 
                                                    SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Discount__c, SBQQ__DistributorDiscount__c, 
                                                    SBQQ__DynamicOptionId__c, SBQQ__EarliestValidAmendmentStartDate__c,  
                                                    SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c, SBQQ__GrossProfit__c, SBQQ__Group__c, SBQQ__Guidance__c, SBQQ__HasConsumptionSchedule__c, 
                                                    SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c,  SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c, 
                                                    SBQQ__NetPrice__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, 
                                                    SBQQ__OptionType__c, SBQQ__Optional__c, SBQQ__OriginalPrice__c, SBQQ__OriginalQuoteLineId__c, SBQQ__OriginalUnitCost__c, 
                                                    SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c,  SBQQ__PartnerDiscount__c, SBQQ__PartnerPrice__c, SBQQ__PreviousSegmentPrice__c, 
                                                    SBQQ__PreviousSegmentUplift__c, SBQQ__PriceEditable__c, SBQQ__PricebookEntryId__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, 
                                                    SBQQ__ProductOption__c, SBQQ__ProductSubscriptionType__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c, SBQQ__ProratedListPrice__c, 
                                                    SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, 
                                                    SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__SpecialPrice__c, SBQQ__StartDate__c,
                                                    SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, 
                                                    SBQQ__SubscriptionTargetPrice__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c, 
                                                    SBQQ__TermDiscount__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, 
                                                    SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c, SBQQ__VolumeDiscount__c,  Discount_months__c, Discounted__c, Swith_to_One_time__c, 
                                                    Product_Code_Text__c, ProductValue__c, ExternalId__c, TaxCountry__c, TaxPercentageApplied__c, SignificantAsset__c,  MaxPrice__c, 
                                                    Type__c, SizekWt__c, ClonedSignificantAsset__c from SBQQ__LineItems__r) FROM SBQQ__Quote__c where SBQQ__Account__r.IsPersonAccount = true and id IN : quoteIds and RecordType.DeveloperName = 'EfficienzaEnergetica' ];

        system.debug('quotesToElaborate: '+quotesToElaborate);

        return quotesToElaborate;
    }

    public static void elaborateInvoiceLinesEfficienza(List<SBQQ__Quote__c> quoteList){

        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineClonataToInsert = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineSignificantAssetToClone = new SBQQ__QuoteLine__c();
        Decimal vatPercentage10; 
        Decimal vatPercentage22;
        for(SBQQ__Quote__c quote: quoteList){
            if(quote.TaxableSignificantAsset__c != null &&  quote.TaxableThirdPartyComponentsAndLabour__c != null &&  quote.TaxableSignificantAsset__c > quote.TaxableThirdPartyComponentsAndLabour__c){
                system.debug('case bene significativo > di terze parti e manodopera');
                vatPercentage10 = (quote.TaxableThirdPartyComponentsAndLabour__c/quote.TaxableSignificantAsset__c);
                system.debug('vatPercentage10: '+vatPercentage10);
                vatPercentage22 = ((quote.TaxableSignificantAsset__c - quote.TaxableThirdPartyComponentsAndLabour__c) / quote.TaxableSignificantAsset__c);
                system.debug('vatPercentage10: '+vatPercentage22);
                for(SBQQ__QuoteLine__c quoteLine : quote.sbqq__LineItems__r ){
                    if(quoteLine.significantasset__c == true){          
                        //calcolo prima linea bene significativo al 10%
                        quoteLineSignificantAssetToClone = quoteLine.clone(false,false,false,false);
                        if(quoteLine.SBQQ__ListPrice__c != null)
                            quoteLine.SBQQ__ListPrice__c = quoteLine.SBQQ__ListPrice__c * vatPercentage10;
                        if(quoteLine.SBQQ__SpecialPrice__c != null)    
                            quoteLine.SBQQ__SpecialPrice__c = quoteLine.SBQQ__SpecialPrice__c * vatPercentage10;
                        if(quoteLine.SBQQ__NetPrice__c != null)
                            quoteLine.SBQQ__NetPrice__c = quoteLine.SBQQ__NetPrice__c * vatPercentage10;
                        quoteLineToUpdate.add(quoteLine);
                        system.debug('invoice line bene significativo da aggiornare pre update: '+ quoteLine);

                        //calcolo clone linea bene significativo al 22%
                        if(quoteLineSignificantAssetToClone.SBQQ__ListPrice__c != null)
                            quoteLineSignificantAssetToClone.SBQQ__ListPrice__c = quoteLineSignificantAssetToClone.SBQQ__ListPrice__c * vatPercentage22;
                        if(quoteLineSignificantAssetToClone.SBQQ__SpecialPrice__c != null)    
                            quoteLineSignificantAssetToClone.SBQQ__SpecialPrice__c = quoteLineSignificantAssetToClone.SBQQ__SpecialPrice__c * vatPercentage22;
                        if(quoteLineSignificantAssetToClone.SBQQ__NetPrice__c != null)
                            quoteLineSignificantAssetToClone.SBQQ__NetPrice__c = quoteLineSignificantAssetToClone.SBQQ__NetPrice__c * vatPercentage22;
                        quoteLineSignificantAssetToClone.ClonedSignificantAsset__c = true;
                        system.debug('quote line bene significativo clonata pre insert: '+ quoteLine);
                        quoteLineClonataToInsert.add(quoteLineSignificantAssetToClone);
                    }
                }
            }
            vatPercentage10 = null;
            vatPercentage22 = null;
        }   

        insert quoteLineClonataToInsert;
        update quoteLineToUpdate;

    }
    
}