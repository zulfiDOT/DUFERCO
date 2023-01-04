/*
 *   @Class  :   public with sharing class LookupSearchResult
*/
@isTest
public with sharing class LookupSearchResultTest {
    
    @isTest static void LookupSearchResultTest(){

        LookupSearchResult res = new LookupSearchResult('test','test','test','test','test');
        String icon = res.getIcon();
        String testId = res.getId();
        String sobType = res.getSObjectType();
        String subtitle = res.getSubtitle();
        String title = res.getTitle(); 
    }
}