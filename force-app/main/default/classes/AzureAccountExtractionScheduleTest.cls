@isTest
private class AzureAccountExtractionScheduleTest {
    @isTest
    static void testAzureAccountExtractionSchedule() {
        // Create a new instance of the Schedulable class
        AzureAccountExtractionSchedule schedule = new AzureAccountExtractionSchedule();

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