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
private class QuoteApprovalHandlerTest {

    @isTest
    static void testSubmitToApprovalProcess() {

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User otherUser = [SELECT Id FROM User WHERE Id != :currentUser.Id AND IsActive = true LIMIT 1];
        currentUser.ManagerId = otherUser.Id;
        update currentUser;
        // 1. Setup Data: Account -> Opportunity -> Quote
        Account acc = new Account(Name = 'Test Account', AccountNumber = '98712356');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;

        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            // Ensure any fields that are entry criteria for 'Manager_Approval' are set here
            Is_Approval_Required__c = true 
        );
        insert testQuote;

        // 2. ACT: Call the handler method
        Test.startTest();
        QuoteApprovalHandler.SubmitToApprovalProccess(new List<Quote>{testQuote});
        Test.stopTest();

        // 3. ASSERT: Check if an Approval Process Instance was created for this Quote
        List<ProcessInstance> instances = [SELECT Id, Status, TargetObjectId 
                                           FROM ProcessInstance 
                                           WHERE TargetObjectId = :testQuote.Id];
        
        System.assertEquals(1, instances.size(), 'One approval process should have been started.');
        System.assertEquals('Pending', instances[0].Status, 'The approval status should be Pending.');
    }
}