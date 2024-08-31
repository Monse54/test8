public class AzureAccountExtractionBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public final String csvHeader = 'SFDC 18 Digit ID,Salesforce Account ID,Account Name,Parent Account ID,Parent Account,Account Owner,Account Industry,Website,Theme - Demand,Demand Tier,Account Type,Account Segment,Account Record Type,Rev-Ops Team,Billing City,Billing State/Province,ROO,Region';
    private final String Subject1 = 'Azure Account Extraction Status';
    public String csvContent;
    
    public AzureAccountExtractionBatch() {
        csvContent = csvHeader + '\n';
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Saleforce_Account_ID__c, Name, ParentId, Parent.Name, Owner.FirstName, Owner.LastName, Industry, Website, Theme_Demand__c, Demand_Tier__c, Type, Account_Segment__c, Record_Type_Name__c, Rev_Ops_Team__c, BillingCity, BillingState, Account_Sub_Region__c, Account_Region_del__c FROM Account where MasterAccountId__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope) {
        for (Account acc : scope) {
            String row = processRow(acc);
            csvContent += row + '\n';
        }
    }
    
    private static String removeCommas(String value) {
        return value != null ? value.replaceAll('[,"]', '') : '';
    }
    
    public static String processRow(Account acc) {
        String row = '';
        
        row += (acc.Id != null ? removeCommas(acc.Id) : '') + ',';
        row += (acc.Saleforce_Account_ID__c != null ? removeCommas(acc.Saleforce_Account_ID__c) : '') + ',';
        row += (acc.Name != null ? removeCommas(acc.Name) : '') + ',';
        row += (acc.ParentId != null ? removeCommas(acc.ParentId) : '') + ',';
        row += (acc.Parent != null && acc.Parent.Name != null ? removeCommas(acc.Parent.Name) : '') + ',';
        row += (acc.Owner != null && acc.Owner.FirstName != null ? removeCommas(acc.Owner.FirstName) : '') +(acc.Owner != null && acc.Owner.LastName != null ? removeCommas(acc.Owner.LastName) : '') + ',';
        row += (acc.Industry != null ? removeCommas(acc.Industry) : '') + ',';
        row += (acc.Website != null ? removeCommas(acc.Website) : '') + ',';
        row += (acc.Theme_Demand__c != null ? removeCommas(acc.Theme_Demand__c) : '') + ',';
        row += (acc.Demand_Tier__c != null ? removeCommas(acc.Demand_Tier__c) : '') + ',';
        row += (acc.Type != null ? removeCommas(acc.Type) : '') + ',';
        row += (acc.Account_Segment__c != null ? removeCommas(acc.Account_Segment__c) : '') + ',';
        row += (acc.Record_Type_Name__c != null ? removeCommas(acc.Record_Type_Name__c) : '') + ',';
        row += (acc.Rev_Ops_Team__c != null ? removeCommas(acc.Rev_Ops_Team__c) : '') + ',';
        row += (acc.BillingCity != null ? removeCommas(acc.BillingCity) : '') + ',';
        row += (acc.BillingState != null ? removeCommas(acc.BillingState) : '') + ',';
        row += (acc.Account_Sub_Region__c != null ? removeCommas(acc.Account_Sub_Region__c) : '') + ',';
        row += (acc.Account_Region_del__c != null ? removeCommas(acc.Account_Region_del__c) : '');
        
        return row;
    }
    
    public void finish(Database.BatchableContext context) {
        // upload csv file  AccountFile.csv
        String fileName = 'AccountExtract.csv';
        String result = AzureBlobUpload.performUpload(fileName, csvContent);
        if (String.isNotBlank(result)) {
            sendEmail(Subject1, result);
        }
        system.debug('csv content @@@@'+csvContent);
    }
    
    public void sendEmail(String subject, String body) {
        String recipients = System.Label.AzureExtractionToEmailNotification;
        
        if (String.isNotBlank(body)) {
            if (String.isNotBlank(recipients)) {
                List<String> recipientList = recipients.split(',');
                List<String> validRecipients = new List<String>();
                
                for (String recipient : recipientList) {
                    recipient = recipient.trim();
                    if (String.isNotBlank(recipient)) {
                        validRecipients.add(recipient);
                    }
                }
                
                if (!validRecipients.isEmpty()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(subject);
                    email.setHtmlBody(body);
                    email.setToAddresses(validRecipients);
                    Messaging.sendEmail(new List<Messaging.Email>{ email });
                    system.debug('Email Sent Successfully '+validRecipients);
                } else {
                    System.debug('No valid email addresses found in the custom label.');
                }
            } else {
                System.debug('Custom label "EmailRecipients" is blank.');
            }
        } else {
            System.debug('Email body is blank.');
        }
    }
}