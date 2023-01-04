@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
    @IsTest
 static void testgetForgotPasswordUrl() {
  String authConfig = LightningLoginFormController.getForgotPasswordUrl();
  System.assertNotEquals('', authConfig);
 }
    @IsTest
 static void testLogin() {
  String result = LightningLoginFormController.login('','','');
  //System.assertNotEquals('', authConfig);
 }
    
    @IsTest
 static void LightningLoginFormController_setExperienceId() {     
    String expid = ApexPages.currentPage().getParameters().get('expid'); 
  	LightningLoginFormController.setExperienceId(expid);
     LightningLoginFormController.setExperienceId('TEST');
    LightningLoginFormController.setExperienceId(null);
 }
}