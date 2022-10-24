public  class ResetAssetValueBatch implements Database.Batchable<sObject>{

    String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, TempoRicaricheMese__c, NumeroRicaricheMese__c, kWhConsumatiMese__c, ResidualCredit__c, CreditLimit__c, CardType__c '+
                'From Asset';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Asset> scope){
        List<Asset> assetList = new List<Asset>();
        for(Asset a : scope){
        if (a.TempoRicaricheMese__c != 0.00 || a.NumeroRicaricheMese__c != 0 || a.kWhConsumatiMese__c != 0.00) {
                a.TempoRicaricheMese__c = 0.00;
                a.NumeroRicaricheMese__c = 0;
                a.kWhConsumatiMese__c = 0.00;

                if (a.CardType__c == '1') {
                    a.ResidualCredit__c = a.CreditLimit__c;
                }
                assetList.add(a);
            }
        }
        if (!assetList.isEmpty()) {
            update assetList;
        }
    }
   
    public void finish(Database.BatchableContext BC){
    }
}