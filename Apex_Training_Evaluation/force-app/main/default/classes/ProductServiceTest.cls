/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProductServiceTest {

    @isTest
    static void testCreateProduct() {

        //Arrange
        Pricebook2 customPb = new Pricebook2(Name = 'Test Custom PB' , IsActive = true);
        insert customPb;

        Id stdPbId = Test.getStandardPricebookId();

        List<Product2> products = new List<Product2>();
        Product2 prod1 = new Product2(
            Name = 'Test Product 1',
            IsActive = true,
            List_Price__c = 100.00
        );
        products.add(prod1);

        Product2 prod2 = new Product2(
            Name = 'Test Product 2',
            IsActive = true,
            List_Price__c = 200.00,
            Targeted_Price_Book__c = customPb.Id
        );
        products.add(prod2);

        Product2 prod3  = new Product2(
            Name = 'Test Product 3',
            IsActive = true
        );
        products.add(prod3);

        //Act
        Test.startTest();
        insert products;
        Test.stopTest();


        //Assert
        List<PricebookEntry> pbes = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry];

        System.Assert.areEqual(3, pbes.size(), 'Should have created 3 Pricebook Entries.');
    }
}