@isTest
public class AzureOpptyExtractionSchedulableTest {
     @isTest
    static void TestOpportunityExtractionSchedulable() {
        // Create a new instance of the Schedulable class
        AzureOpportunityExtractionSchedulable schedule = new AzureOpportunityExtractionSchedulable();

        // Enqueue the job
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String jobId = System.schedule('Test Schedule', '0 0 0 * * ?', schedule);
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