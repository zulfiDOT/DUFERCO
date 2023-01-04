/*
 *   @TestClass: UtilsFlowTest
*/
public class UtilsFlow {
	 @InvocableMethod(label = 'Get Products' description = 'Get Products From Quote Line')
    public static List<List<Product2>> getProducts(List<List<Id>> productIds) {
        
        System.debug('Id Product --> '+productIds.get(0));
        List<Product2> plist = [Select id, Quantit_Magazzino__c, Magazzino__c, Quantit_Just_in_Time__c from Product2 Where Id In: productIds.get(0)];
        System.debug('Products result --> '+plist);
        List<List<Product2>> resultList = new List<List<Product2>>();
        resultList.add(plist);
        return resultList;
    }

}