public with sharing class batchProgressIndicatorController {
    @AuraEnabled
    public static List<AsyncApexJob> getJobDetails(String jobId){
       
            List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems,
                                                NumberOfErrors FROM AsyncApexJob where Id =: jobId ];
            return asyncJobList;
   }

   @AuraEnabled
   public static string executeBatch(String className, Integer chunkSize){
            Type batchInstance = Type.forName(className);
            Id batchJobId = Database.executeBatch((Database.Batchable<sObject>)batchInstance.newInstance(), chunkSize);
            sendExecutionEmail(className, batchJobId);
            return batchJobId;
            
   }

    public static void sendExecutionEmail(String className, String batchJobId) {
    String recipientEmail = UserInfo.getUserEmail();
    if (String.isNotBlank(recipientEmail)) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Batch class '+ className+' was triggered');
        email.setPlainTextBody('The batch execution for class ' + className + ' with job ID ' + batchJobId + ' has completed.');
        email.setToAddresses(new List<String>{recipientEmail});

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}
}