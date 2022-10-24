global class DmxAccount {
    @AuraEnabled
    public List<DmxContact> contacts;
    @AuraEnabled
    public List<DmxAddress> addresses;

    @AuraEnabled
    public String account_id;
    @AuraEnabled
    public String account_iddatamax;
    @AuraEnabled
    public String account_name;
    @AuraEnabled
    public String account_recordtype;
    @AuraEnabled
    public String account_fiscalcode;
    @AuraEnabled
    public String account_vatnumber;
    @AuraEnabled
    public String account_pec;
    @AuraEnabled
    public Boolean account_privacyprofilazione;
    @AuraEnabled
    public Boolean account_privacycommercialeterzi;
    @AuraEnabled
    public Boolean account_privacycommerciale;
    @AuraEnabled
    public Boolean account_privacycontratto;
    @AuraEnabled
    public String account_agency;
    @AuraEnabled
    public String account_agent;
    @AuraEnabled
    public String account_status;
    @AuraEnabled
    public String account_phoneprefix;
    @AuraEnabled
    public String account_phone;
    @AuraEnabled
    public String account_mobile;
    @AuraEnabled
    public String account_mobileprefix;
    @AuraEnabled
    public String account_fax;
    @AuraEnabled
    public String account_faxprefix;
    @AuraEnabled
    public String account_email;
    @AuraEnabled
    public String account_formaanagrafica;
    @AuraEnabled
    public String account_idterp;
    @AuraEnabled
    public String account_company;
}