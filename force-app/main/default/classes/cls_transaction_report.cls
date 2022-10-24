global class cls_transaction_report {
    @AuraEnabled
    public String transaction_numeroMerchant;	//00026510
    @AuraEnabled
    public String transaction_codiceTransazione;	//936eca41-0ec8-4512-bb06-e69bf2
    @AuraEnabled
    public String transaction_importo;	//79300
    @AuraEnabled
    public String transaction_divisa;	//EUR
    @AuraEnabled
    public String transaction_codiceAutorizzazione;	//7YGHOS
    @AuraEnabled
    public String transaction_brand;	//VISA
    @AuraEnabled
    public String transaction_tipoPagamento;	//3DSECURE
    @AuraEnabled
    public String transaction_tipoTransazione;	//VBV_FULL
    @AuraEnabled
    public String transaction_nazione;	//ITA
    @AuraEnabled
    public String transaction_tipoProdotto;	//VISA CLASSIC - CREDIT - N
    @AuraEnabled
    public String transaction_pan;	//453997*****0006
    @AuraEnabled
    public String transaction_parametri;	//num_contratto=cn_20220120143852469_e49f3758
    @AuraEnabled
    public String transaction_stato;	//Contabilizzato
    @AuraEnabled
    public String transaction_dataTransazione;	//2022-01-20 14:45:11.0
    @AuraEnabled
    public String transaction_mail;	//test@test.com
    @AuraEnabled
    public cls_transaction_dettaglio transaction_dettaglio;
}