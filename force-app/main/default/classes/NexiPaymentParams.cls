global class NexiPaymentParams {
    @AuraEnabled
    public String nexiTransactionCode;
    @AuraEnabled
    public Decimal nexiAmount;
    @AuraEnabled
    public String nexiGuid;
    @AuraEnabled
    public String accountId;
    @AuraEnabled
    public String usageId;
    @AuraEnabled
    public String orderId;
    @AuraEnabled
    public String invoiceId;
    @AuraEnabled
    public String quoteId;
}