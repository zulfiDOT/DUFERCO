public  class ResetAssetValueBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, AccountId, TempoRicaricheMese__c, NumeroRicaricheMese__c, kWhConsumatiMese__c, ResidualCredit__c, CreditLimit__c, CardType__c, SBQQ__OrderProduct__r.blng__NextBillingDate__c '+
                'From Asset';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Asset> scope){
        Map<Id, Date> mapToWorkWith = new Map<Id, Date>();
        Set<Id> accIds = new Set<Id>();
        for(Asset a : scope){
            accIds.add(a.AccountId);
        }
        List<OrderItem> orderItemList = new List<OrderItem>();
        orderItemList = [SELECT id, Order.AccountId, Product2.name, SBQQ__TerminatedDate__c, blng__NextBillingDate__c
        FROM OrderItem WHERE Product2.name = 'Abbonamento flat 2022' AND Order.AccountId IN :accIds and SBQQ__TerminatedDate__c = null];
        for(OrderItem ordItem : orderItemList){
            mapToWorkWith.put(ordItem.Order.AccountId, ordItem.blng__NextBillingDate__c);
        }
        System.debug('mapToWorkWith: '+ mapToWorkWith);
        List<Asset> assetList = new List<Asset>();
        Set<Id> assetIdsToSend = new Set<Id>();
        Set<Id> assetIdsToSend2 = new Set<Id>();
       // String billingDayOfMonthOrder; //SBQQ__OrderProduct__r.Order.blng__BillingDayOfMonth__c
        Integer billingDayOfMonthOrderNumber;
        Date today = Date.today();
        System.debug('today: '+ today);
        // Integer datyOfTodayInt = today.day();
        for(Asset a : scope){
            // billingDayOfMonthOrder = a.SBQQ__OrderProduct__r.blng__NextBillingDate__c;
            Date billingDayOfMonthOrder = mapToWorkWith.get(a.AccountId);//a.SBQQ__OrderProduct__r.blng__NextBillingDate__c;
            System.debug('billingDayOfMonthOrder: '+ billingDayOfMonthOrder);
            //billingDayOfMonthOrderNumber = Integer.valueOf(billingDayOfMonthOrder);
            if ((today == billingDayOfMonthOrder) && (a.TempoRicaricheMese__c != 0.00 || a.NumeroRicaricheMese__c != 0 || a.kWhConsumatiMese__c != 0.00)) {
                    a.TempoRicaricheMese__c = 0.00;
                    a.NumeroRicaricheMese__c = 0;
                    a.kWhConsumatiMese__c = 0.00;

                    if (a.CardType__c == '1') {
                        a.ResidualCredit__c = a.CreditLimit__c;
                        if(assetIdsToSend.size()<100) {
                            assetIdsToSend.add(a.Id);
                        } else if(assetIdsToSend.size()>=100) {
                            assetIdsToSend2.add(a.Id);
                        }
                    }
                    assetList.add(a);
                }
        }
        if(assetIdsToSend != null && assetIdsToSend.size() > 0) syncWithMobilitySync(assetIdsToSend);
        if(assetIdsToSend2 != null && assetIdsToSend2.size() > 0) syncWithMobilitySync(assetIdsToSend2);

        if (!assetList.isEmpty()) {
            update assetList;
        }
       // = (new Map<Id,Asset>(assetList)).keySet();
       //if(assetIdsToSend != null && assetIdsToSend.size() > 0) syncWithMobilitySync(assetIdsToSend);
       //if(assetIdsToSend2 != null && assetIdsToSend2.size() > 0) syncWithMobilitySync(assetIdsToSend2);
        
    }
   
    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }

    public static void syncWithMobilitySync(Set<Id> assetIds) {
            Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT InstallDate, CardNumber__c, Contact.IdMobility__c, CreatedDate, LifecycleEndDate, UsageEndDate, Contact.Email,
                                                                Contact.FirstName, IDRFID__c, Contact.LastName, LastModifiedDate, CardOrigin__c, RemoteEnabled__c,
                                                                ResidualCredit__c, Status, LicencePlate__c, UIDRFID__c, BrandModel__c, AccountId
                                                        FROM Asset
                                                        WHERE Id IN :assetIds]);
            
            Set<Id> accountIds = new Set<Id>();
            for(Id assetId : assetIds) {
                Asset a = assetMap.get(assetId);
                if(a != null) {
                    accountIds.add(a.AccountId);
                }
            }

            Map<Id, Contract> contractPerAccountId = new Map<Id, Contract>();
            for(Contract c : [SELECT AccountId, SBQQ__ActiveContract__c
                                FROM Contract
                                WHERE AccountId IN :accountIds AND SBQQ__ActiveContract__c = 1 AND StartDate <= TODAY
                                AND (EndDate >= TODAY OR EndDate = null) AND Status = 'Activated' AND ContractType__c != null]) {
                contractPerAccountId.put(c.AccountId, c);
            }

            List<Asset> assetToUpdate = new List<Asset>();
            for(Id assetId : assetIds) {
                Asset a = assetMap.get(assetId);
                if(a != null) {
                    Contract c = contractPerAccountId.get(a.AccountId);
                    
                    UpsertCardApiController.Request request = new UpsertCardApiController.Request();
                    
                    request.calloutName = 'UpsertCard';
                    request.method = 'POST';
                    request.card = AssetTriggerHandler.setVirTessere(a, c);

                    List<UpsertCardApiController.Response> response = UpsertCardApiController.makeCallout(new List<UpsertCardApiController.Request>{request});

                    a.LastSyncDatetime__c = System.now();
                    if(response != null && response.size() > 0) {
                        if(response.get(0).ResponseCode == '200' || response.get(0).ResponseCode == '201') {
                            a.SyncErrorMessage__c = null;
                            a.SyncStatus__c = 'Sincronizzato';
                        } else {
                            a.SyncErrorMessage__c = response.get(0).ResponseCode + ' - ' + response.get(0).ResponseMessage;
                            a.SyncStatus__c = 'Errore';
                        }
                    } else {
                        a.SyncErrorMessage__c = 'No response from Mulesoft';
                        a.SyncStatus__c = 'Errore';
                    }
                    assetToUpdate.add(a);
                }
            }

            MulesoftApiController.lockTriggers = true;
            if(assetToUpdate != null && assetToUpdate.size() > 0) {
                update assetToUpdate;
            }
        }
}