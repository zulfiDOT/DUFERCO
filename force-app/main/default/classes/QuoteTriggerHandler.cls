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
    
}