/**
 * @TestClass: BillingProfileTriggerTest
 */
trigger BillingProfileTrigger on BillingProfile__c (after insert, after update) {
    BillingProfileTriggerHandler.setMandateCode(Trigger.new);
}