public class AzureBlobUpload{
		public static String performUpload(String fileName, String fileContent) {
        String apiUrl = Label.AzureExtractionEndPoint;
        String endpointUrl = apiUrl.replace('{fileName}', fileName);
        //String endpointUrl = 'callout:AzureExtractionEndPoint/' + fileName;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        request.setHeader('x-ms-blob-type', 'BlockBlob');
        request.setBodyAsBlob(Blob.valueOf(fileContent));
        
        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() == 201) {
            system.Debug('File uploaded successfully.');
            return 'File uploaded successfully.';
            
        } else {
            system.debug('File upload failed');
            return 'File upload failed.';
        }
    }
}