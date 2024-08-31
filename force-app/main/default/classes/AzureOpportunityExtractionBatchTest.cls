@isTest
private class AzureOpportunityExtractionBatchTest {
    @isTest
    static void testAzureOpportunityExtractionBatch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        AzureOpportunityExtractionBatch batch = new AzureOpportunityExtractionBatch();
        Database.executeBatch(batch);
        Test.stopTest();

    }
     @isTest
    static void testProcessRow(){
        Account ac = new Account();
        ac.Name = 'Test Acc';
        ac.Account_Type__c = 'Agency';
        ac.Account_Segment__c = 'Brand';
        ac.MasterAccountId__c = 'Test1234';
       // ac.Account_Stage__c = 'Draft';
        ac.Billing_Country__c = 'India';
        ac.BillingCountry = 'India';
        ac.Account_Legal_Entity__c = 'IMIN';
        ac.GST_Type__c = 'Regular/TDS/ISD';
        ac.GST_Number__c = '12345abcd';
        ac.PAN_Card_Detail__c = 'abcde1234k';
        //insert ac;
        //account acc = [select id, name from account limit 1];
        
        Contact con = New Contact();
        con.LastName = 'Test';
        con.AccountId = ac.Id;
       // insert con;
        
        
        
        Opportunity opp = New Opportunity();
        opp.Name = 'opty1';
        opp.AccountId = ac.Id;
        opp.Billing_Contact__c = con.Id;
        opp.Opportunity_Type__c = 'New Customer';
        opp.Billing_Address__c = 'Test Street';
        opp.StageName = 'Qualified';
        opp.CloseDate = Date.today() + 30;
        opp.Amount = 15000;
        opp.Type = 'New Business';
        opp.Opportunity_SubType__c = 'Demand';
        opp.Opportunity_Segment__c = 'Brand';
        opp.Approval_Status__c = 'Approved';
        opp.Is_Free_Trial_Required__c = true;
        //insert opp;
        // Start the batch
        AzureOpportunityExtractionBatch.processRow(opp);
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/plain');
            response.setBody('Mock response');
            response.setStatusCode(200);
            return response;
        }
    }
    
}