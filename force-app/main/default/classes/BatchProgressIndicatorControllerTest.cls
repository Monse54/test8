@isTest
public class BatchProgressIndicatorControllerTest {
    
    @isTest
    static void testExecuteBatch() {
        String className = 'AzureOpportunityExtractionBatch'; 
        Integer chunkSize = 1;
        
       // List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Status = 'Completed' where ];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String batchJobId = batchProgressIndicatorController.executeBatch(className, chunkSize);
        batchProgressIndicatorController.getJobDetails(batchJobId);
        Test.stopTest();
        
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