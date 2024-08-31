@isTest
private class AzureAccountExtractionBatchTest {
    
    @isTest
    static void testAzureAccountExtractionBatch() {
        // Start the batch

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        AzureAccountExtractionBatch batch = new AzureAccountExtractionBatch();
        Database.executeBatch(batch);
        Test.stopTest();

    }
    
    @isTest
    static void testProcessRow(){
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent Account';
        // Set other required fields for the parent account
       // insert parentAccount;

        // Create a test account with the parent account assigned
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.OwnerId = UserInfo.getUserId();
        acc.Industry = 'Technology';
        acc.Website = 'www.example.com';
        //acc.ParentId = parentAccount.Id;
       	acc.Theme_Demand__c = 'ANZ-Demand-NAL-Q3-2021';
        acc.Demand_Tier__c = '3';
        acc.Type = 'SMB';
        acc.Account_Segment__c = 'Performance';
        //acc.Record_Type_Name__c = '';
        acc.Rev_Ops_Team__c = 'RevOps';
        acc.BillingCountry = 'India';
        acc.BillingCity = 'Lucknow';
        acc.BillingState = 'Uttar Pradesh';
        acc.Account_Sub_Region__c = 'India';
        acc.Account_Region_del__c = 'ROW';

        
        insert acc;

        
        AzureAccountExtractionBatch.processRow(acc);
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