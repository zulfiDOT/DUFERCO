/*
 * @TestClass: AssetTriggerHandlerTest
 * @Trigger : AssetTrigger
*/
public class AssetTriggerHandler {
    
    public static void syncWithMobilityInsert(List<Asset> triggerNew) {
        if(MulesoftApiController.isActive('UpsertCard')) {
            Set<Id> assetIdsToSend = new Set<Id>();
            for(Asset a : triggerNew) {
                assetIdsToSend.add(a.Id);
            }
            syncWithMobility(assetIdsToSend);
        }
    }

    public static void syncWithMobilityUpdate(List<Asset> triggerNew, Map<Id,Asset> triggerOldMap) {
        if(MulesoftApiController.isActive('UpsertCard')) {
            Set<Id> assetIdsToSend = new Set<Id>();
            Set<Id> assetIdsToSend2 = new Set<Id>();
            List<String> fieldsToCheck = new List<String>{'CardNumber__c','ResidualCredit__c','Status','InstallDate','UsageEndDate','BrandModel__c',
                                                            'LicencePlate__c','LifecycleEndDate','RemoteEnabled__c','AccountId','ContactId'};
            for(Asset a : triggerNew) {
                if(a.CardNumber__c != null && a.SyncStatus__c == triggerOldMap.get(a.Id).SyncStatus__c && a.SyncStatus__c != 'Non Sincronizzato') {
                    Boolean fieldChanged = false;
                    for(String field : fieldsToCheck) {
                        fieldChanged = isChanged(a, triggerOldMap.get(a.Id), field);
                        if(fieldChanged) break;
                    }
                    if(fieldChanged && assetIdsToSend.size()<100) {
                        assetIdsToSend.add(a.Id);
                    } else if(fieldChanged && assetIdsToSend.size()>=100) {
                        assetIdsToSend2.add(a.Id);
                    }
                }
            }
            if(assetIdsToSend != null && assetIdsToSend.size() > 0) syncWithMobility(assetIdsToSend);
            if(assetIdsToSend2 != null && assetIdsToSend2.size() > 0) syncWithMobility(assetIdsToSend2);
        }
    }

    public static void syncWithMobility(Set<Id> assetIds) {
        if(System.isBatch() || System.isFuture()) {
            syncWithMobilitySync(assetIds);
        } else {
            syncWithMobilityAsync(assetIds);
        }
    }

    @future(callout=true)
    public static void syncWithMobilityAsync(Set<Id> assetIds) {
        syncWithMobilitySync(assetIds);
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
                request.card = setVirTessere(a, c);

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

        System.debug('HERE AssetTriggerHandler COMES TRUE LINE 110: ');
        MulesoftApiController.lockTriggers = true;
        if(assetToUpdate != null && assetToUpdate.size() > 0) {
            update assetToUpdate;
        }
    }

    public static VIR_Tessere setVirTessere(Asset a, Contract c) {
        VIR_Tessere tessera = new VIR_Tessere();
        tessera.asset_activationdate       = a.InstallDate;
        tessera.asset_cardnumber           = a.CardNumber__c;
        tessera.asset_contactidmobility    = a.Contact.IdMobility__c;
        tessera.asset_contractstatus       = c!=null && c.SBQQ__ActiveContract__c==1 ? '1' : '2';
        tessera.asset_createddate          = a.CreatedDate;
        tessera.asset_deactivationdate     = a.LifecycleEndDate != null ? a.LifecycleEndDate.date() : null;
        tessera.asset_duedate              = a.UsageEndDate;
        tessera.asset_email                = a.Contact.Email;
        tessera.asset_firstname            = a.Contact.FirstName;
        tessera.asset_idrfid               = a.IDRFID__c;
        tessera.asset_lastname             = a.Contact.LastName;
        tessera.asset_modifieddate         = a.LastModifiedDate;
        tessera.asset_origine              = a.CardOrigin__c;
        tessera.asset_remoteenabled        = a.RemoteEnabled__c;
        tessera.asset_residualcredit       = a.ResidualCredit__c;
        tessera.asset_status               = a.Status;
        tessera.asset_targa                = a.LicencePlate__c;
        tessera.asset_uidrfid              = a.UIDRFID__c;
        tessera.asset_vettura              = a.BrandModel__c;
        return tessera;
    }

    public static Boolean isChanged(Asset oldRecord, Asset newRecord, String fieldName) {
        return oldRecord.get(fieldName) != newRecord.get(fieldName);
    }

}