public class SyncWithMobilityQueue implements Queueable,Database.AllowsCallouts{

    public Set<Id> assetIds; 
    public SyncWithMobilityQueue(Set<Id> assetsIds){
        system.debug('assetsIds:' +assetsIds);
        assetIds = assetsIds ;
        
    }
    public void execute(QueueableContext qc){
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