@isTest
private class OpportunityStageControllerTest {
    @isTest
    static void testGetPickListValues() {
        // Call the method being tested
        List<Map<String, String>> picklistValues = OpportunityStageController.getPickListValues('Opportunity', 'StageName');
    }

    @isTest(SeeAllData=true)
    static void testSaveValues() {
        // Create a test opportunity
		Opportunity testOpportunity = [SELECT Id,Reason__c, Comments__c FROM Opportunity LIMIT 1 ];

        // Call the method being tested
        OpportunityStageController.saveValues(testOpportunity.Id, 'Lost', 'Test Comment');

        // Retrieve the updated opportunity
        Opportunity updatedOpportunity = [SELECT Id, Reason__c, Comments__c FROM Opportunity WHERE Id = :testOpportunity.Id];

        // Assert the results
        System.assertEquals('Lost', updatedOpportunity.Reason__c);
        System.assertEquals('Test Comment', updatedOpportunity.Comments__c);
    }
}