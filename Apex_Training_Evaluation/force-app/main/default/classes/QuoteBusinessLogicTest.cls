@isTest
private class QuoteBusinessLogicTest {

    @testSetup
    static void setupTestData() {
        Product_Category__c pc = new Product_Category__c(
            Name = 'Software',
            Default_Discount__c = 15.0,
            Threshold_Discount__c = 10.0,
            Max_Allowable_Discount__c = 20.0,
            Active__c = true
        );
        insert pc;

        Product2 pr = new Product2(Name = 'Cloud Subscription', Product_Category__c = pc.Id, IsActive = true);
        insert pr;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pr.Id, UnitPrice = 100, IsActive = true);
        insert pbe;

        Account acc = new Account(Name = 'Test Acc', AccountNumber = '45612309');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id);
        insert opp;

        Quote q = new Quote(Name = 'Test Quote', OpportunityId = opp.Id, Pricebook2Id = pricebookId);
        insert q;
    }

    @isTest
    static void testDiscountBasedOnProductCategory() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Auto_Apply_Discount__c = true,
            Discount = null
        );
        List<QuoteLineItem> qliList = new List<QuoteLineItem>{qli};

        Test.startTest();
        QuoteLineItemAutomatedDiscountHandler.discountBasedOnProductCategory(qliList);
        Test.stopTest();

        Assert.areEqual(15.0, qli.Discount);
    }

    @isTest
    static void testCheckThreshold() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Auto_Apply_Discount__c = false,
            Discount = 12
        );
        List<QuoteLineItem> qliList = new List<QuoteLineItem>{qli};

        Test.startTest();
        QuoteLineItemAutomatedDiscountHandler.checkThreshold(qliList);
        Test.stopTest();

        Quote resultQuote = [SELECT Is_Approval_Required__c FROM Quote WHERE Id = :q.Id];
        Assert.areEqual(true, resultQuote.Is_Approval_Required__c);
    }
}