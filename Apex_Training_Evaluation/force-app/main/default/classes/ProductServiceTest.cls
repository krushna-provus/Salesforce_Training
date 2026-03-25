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
private with sharing class ProductServiceTest {

    @isTest
    static void testCreatePricebookEntries() {

        Id standardPricebookId = Test.getStandardPricebookId();

        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Test Custom PB',
            IsActive = true
        );
        insert customPricebook;

        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'Test Product 1',
                IsActive = true,
                List_Price__c = 100
            ),
            new Product2(
                Name = 'Test Product 2',
                IsActive = true,
                List_Price__c = 200,
                Targeted_Price_Book__c = customPricebook.Id
            ),
            new Product2(
                Name = 'Test Product 3',
                IsActive = true
            )
        };

        Test.startTest();
        Database.SaveResult[] results = Database.insert(products, false, AccessLevel.USER_MODE);
        Test.stopTest();

        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess());
        }

        List<PricebookEntry> entries = [
            SELECT Id, Product2Id, Pricebook2Id
            FROM PricebookEntry
        ];

        Assert.areEqual(3, entries.size());

        Boolean hasStandardEntry = false;

        for (PricebookEntry pbe : entries) {
            if (pbe.Pricebook2Id == standardPricebookId) {
                hasStandardEntry = true;
            }
        }

        Assert.areEqual(true,hasStandardEntry);
    }
}
