@istest
public class AzureBlobUploadTest {
    
   @isTest
    public static void testPerformUpload() {
        // Set up mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(201);
        
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Test data
        String fileName = 'test-file.txt';
        String fileContent = 'This is a test file content.';
        
        Test.startTest();
        
        // Perform the upload
        String result = AzureBlobUpload.performUpload(fileName, fileContent);
        
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('File uploaded successfully.', result);

}
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
    
}