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
class QuoteApprovalHandlerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account',AccountNumber = '12309874');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            Is_Approval_Required__c = false
        );
        insert q;
    }

    @isTest
    static void testTriggerApprovalFlow() {
        Quote q = [SELECT Id, Is_Approval_Required__c FROM Quote LIMIT 1];

        q.Is_Approval_Required__c = true;

        Test.startTest();
        Database.SaveResult[] results = Database.update(new List<Quote>{q}, false);
        Test.stopTest();

        Assert.areEqual(true, results[0].isSuccess(), 'ERROR: Quote update failed in trigger flow');

        List<ProcessInstance> instances = [
            SELECT Id, Status
            FROM ProcessInstance
            WHERE TargetObjectId = :q.Id
        ];

        Assert.areEqual(1, instances.size(), 'ERROR: Approval process was not created for Quote');
        Assert.areEqual('Pending', instances[0].Status, 'ERROR: Approval status is not Pending');
    }

    @isTest
    static void testHandlerDirectCall() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        QuoteApprovalHandler.SubmitToApprovalProccess(new List<Quote>{q});
        Test.stopTest();

        List<ProcessInstance> instances = [
            SELECT Id
            FROM ProcessInstance
            WHERE TargetObjectId = :q.Id
        ];

        Assert.areEqual(1, instances.size(), 'ERROR: Handler did not submit Quote for approval');
    }
}