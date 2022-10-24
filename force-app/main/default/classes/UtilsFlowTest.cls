/*
 *   @Class  :   UtilsFlow
*/
@isTest
public with sharing class UtilsFlowTest {
    

    @testSetup
    public static void setup() {

        Product2 prod = new Product2();
        prod.Name = 'Prod Test Class';
        insert prod;

    }

    @isTest
    public static void getProductsTest() {

        List<List<Id>> productIds = new List<List<Id>>();
        List<List<Product2>> products = new List<List<Product2>>();
        List<Id> productId = new List<Id>();
        List<Product2> prodList = [Select id from Product2];
        productId.add(prodList.get(0).Id);
        productIds.add(productId);
        Test.startTest();

        products = UtilsFlow.getProducts(productIds);

        Test.stopTest();

        System.assert(!products.isEmpty());

    }
}