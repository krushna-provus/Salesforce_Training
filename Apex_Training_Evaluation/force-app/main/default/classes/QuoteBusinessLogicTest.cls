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
private class QuoteBusinessLogicTest {

    @testSetup
    static void setupTestData() {

        //Arrange
        // 1. Setup: Product Category
        Product_Category__c pc = new Product_Category__c(
            Name = 'Software',
            Default_Discount__c = 15.0,
            Threshold_Discount__c = 10.0,
            Max_Allowable_Discount__c = 20.0,
            Active__c = true
        );
        insert pc;

        // 2. Setup: Product linked to Category
        Product2 pr = new Product2(
            Name = 'Cloud Subscription',
            Product_Category__c = pc.Id,
            IsActive = true
        );
        insert pr;

        // 3. Setup: Standard Pricebook Entry
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pr.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Account acc = new Account(Name = 'Test Acc', AccountNumber = '45612309');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp', 
            StageName = 'Prospecting', 
            CloseDate = Date.today(), 
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote', 
            OpportunityId = opp.Id, 
            Pricebook2Id = pricebookId
        );
        insert q;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User otherUser = [SELECT Id FROM User WHERE Id != :currentUser.Id AND IsActive = true LIMIT 1];
        currentUser.ManagerId = otherUser.Id;
        update currentUser;
    }

    @isTest
    static void testApplyDefaultDiscount() {
        // Fetch data from Setup
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        // ACT: Insert QLI with Auto-Apply enabled
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            Auto_Apply_Discount__c = true
        );

        Test.startTest();
        insert qli;
        Test.stopTest();

        // ASSERT
        QuoteLineItem result = [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(15.0, result.Discount, 'Default discount of 15% should be applied.');
    }

    @isTest
    static void testApprovalRequiredThreshold() {
        // Fetch data from Setup
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        // ACT: Insert QLI with manual discount (12%) which is > Threshold (10%)
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            Auto_Apply_Discount__c = false,
            Discount = 12
        );

        Test.startTest();
        insert qli;
        Test.stopTest();

        // ASSERT
        Quote result = [SELECT Is_Approval_Required__c FROM Quote WHERE Id = :q.Id];
        System.assertEquals(true, result.Is_Approval_Required__c, 'Quote should require approval for 12% discount.');
    }
}