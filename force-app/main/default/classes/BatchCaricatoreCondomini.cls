/**
 * @TestClass: caricatoreCondominiManageCtrl_Test
 */
public class BatchCaricatoreCondomini implements Database.batchable<CaricatoreCondominiManageCtrl.WrapperRes>{
    
    public list<CaricatoreCondominiManageCtrl.WrapperRes> resultList;
    public set<id> QuotePadreSet;
    
    @InvocableMethod
    public static list<list<boolean>> Get_attivo(list<list<string>> input){
        list<boolean> bList = new list<boolean>();
        list<list<boolean>> bListList = new list<list<boolean>>();
        while(bListList.size()<input.size()){
            bList.add(System.isBatch() || System.isQueueable());
            bListList.add(bList);  
        }
        return bListList;
    }
    
    public BatchCaricatoreCondomini(CaricatoreCondominiManageCtrl.WrapperRes Input){

        map<string,CaricatoreCondominiManageCtrl.WrapperRes> WrapperResMap = new map<string,CaricatoreCondominiManageCtrl.WrapperRes>();
        set<id> QuotesPadre = new set <id>();
        list<CaricatoreCondomini__c> caricatoreCondominiList = new list<CaricatoreCondomini__c>();
        for(CaricatoreCondomini__c cc: Input.listcaricatoreCondomini){
            QuotesPadre.add(cc.QuoteId__c);
            CaricatoreCondominiManageCtrl.WrapperRes wr = Input.clone();
            caricatoreCondominiList = (WrapperResMap.containsKey(cc.FiscalCode__c))? WrapperResMap.get(cc.FiscalCode__c).listcaricatoreCondomini:new list<CaricatoreCondomini__c>();
            caricatoreCondominiList.add(cc);
            wr.listcaricatoreCondomini = caricatoreCondominiList;
            WrapperResMap.put(cc.FiscalCode__c,wr);
            
        }
        this.QuotePadreSet = QuotesPadre;
        this.resultList = WrapperResMap.values();
        
    }
    
    public Iterable<CaricatoreCondominiManageCtrl.WrapperRes> start(Database.batchableContext info){ 
        system.debug('resultList---->'+resultList);
        return resultList;
    }     
    
    
    public void execute(Database.batchableContext info, list<CaricatoreCondominiManageCtrl.WrapperRes> scope){ 
        List<CaricatoreCondomini__c> caricatoreCondominiList = new List<CaricatoreCondomini__c>(); 

        for(CaricatoreCondominiManageCtrl.WrapperRes result : scope){
       
            caricatoreCondominiList = result.listcaricatoreCondomini;
           // Savepoint sp = Database.setSavepoint();
            try{
                //caricatoreCondominiList.add(a);
                //result.listcaricatoreCondomini =caricatoreCondominiList;
                
                //insert account
                //result =  CaricatoreCondominiManageCtrl.upsertAccount(result);
                
                //insert address
                CaricatoreCondominiManageCtrl.createAddress(result.listcaricatoreCondomini , result.accMapInSfFiscalCode);
                
                //insert blng__PaymentMethod__c
                //result = CaricatoreCondominiManageCtrl.createBlng_PaymentMethod(result);
                
                //insert createBillingProfile
                result = CaricatoreCondominiManageCtrl.createBillingProfile(result);
                
                //insert SBQQ__Quote__c
                result = CaricatoreCondominiManageCtrl.createSBQQQuote(result);
                
                //insert SBQQ__QuoteLine__c
                CaricatoreCondominiManageCtrl.createSBQQQuoteLine(result);
                
                 for(CaricatoreCondomini__c cc : caricatoreCondominiList){
                    cc.Status__c = 'Elaborato';
                     if(result.productSameInvoice.contains(cc.ProductCode__c)){
                         cc.Quote__c = result.sbqqAccMap.containsKey(result.accMapInSfFiscalCode.get(cc.FiscalCode__c).id) ? result.sbqqAccMap.get(result.accMapInSfFiscalCode.get(cc.FiscalCode__c).id).id : null;
                    
                     }else if(!result.quoteCaricatoreMap.isEmpty() && result.quoteCaricatoreMap.containsKey(cc.Id)){
                        cc.Quote__c = result.quoteCaricatoreMap.get(cc.Id).Id;
                    }
                }
                update caricatoreCondominiList;
                result.processed =  true;


            }Catch(Exception ex){
                System.debug('Error CaricatoreCondominiManageCtrl: '+ex.getMessage()+ ' at line: '+ex.getLineNumber()+' stack trace: '+ex.getStackTraceString());
             //   Database.rollback(sp);
                for(CaricatoreCondomini__c cc : caricatoreCondominiList){
                    cc.ValidationResult__c =  ex.getMessage()+';' +'\n'+ ex.getTypeName() + '\n'+ ex.getLineNumber();
                    cc.Status__c = 'In errore';
                }  
                update caricatoreCondominiList;
                result.processed =  true;
            }
        } 
    }
    
    public void finish(Database.batchableContext info){  
        BatchRecalculateQuote btch = new BatchRecalculateQuote(QuotePadreSet);
        Database.executeBatch(btch,1);
    } 
}