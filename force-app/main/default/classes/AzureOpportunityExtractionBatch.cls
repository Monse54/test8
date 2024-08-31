global class AzureOpportunityExtractionBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Iterable<SObject> {
    private final String csvHeader = 'SFDC 18 Digit Opportunity Unique ID,Opportunity Owner,Account Name,Account ID,Opportunity Name,Stage,Fiscal Period,Amount (converted),Expected Revenue (converted),Probability (%),Age,Close Date,Created Date,Lead Source,Opportunity Type,Opportunity Record Type,Product Interest,Linked Client,Linked Client InMobi Account ID,Linked Client SF ID,Agency Account Name,Agency Account ID,Opportunity Owner EMP ID';
    private final String Subject1 = 'Azure Opportunity Extraction Status';
    private String csvContent;
    private String query;

    public AzureOpportunityExtractionBatch() {
        csvContent = csvHeader + '\n';
        query = 'SELECT Id, Account.Id, Owner.FirstName, Owner.LastName, Account.Name, SFDC_18_Digit__c, Name, StageName, Fiscal_Period__c, Amount, ExpectedRevenue, Probability, Opportunity_Age__c, CloseDate, CreatedDate, LeadSource, Type, RecordType.Name, Product_Interest__c, Brand_Name1__r.Name, Linked_Client_Salesforce_Id__c, Linked_client_ID__c, Owner.EmployeeNumber FROM Opportunity WHERE IsClosed = true AND CloseDate >= LAST_YEAR';
    }

    public Iterable<SObject> start(Database.BatchableContext context) {
        return this;
    }

    public Iterator<SObject> iterator() {
        return Database.getQueryLocator(query).iterator();
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<String> rows = new List<String>();
        for (SObject sobj : scope) {
            Opportunity opp = (Opportunity)sobj;
            rows.add(processRow(opp));
        }
        csvContent += String.join(rows, '\n') + '\n';
    }
	// Finish method to perform post-processing
    public void finish(Database.BatchableContext context) {
        // Upload csv file OpportunityFile.csv
        String fileName = 'OpportunityExtract.csv';
        String result = AzureBlobUpload.performUpload(fileName, csvContent);
        if (String.isNotBlank(result)) {
            sendEmail(Subject1, result);
        }
        System.debug('result upload file@@@' + result);
        System.debug('@@@@@@@@@@Finished Methodcall' + csvContent);
    }
	
    public static string processRow(Opportunity opp) {
        DateTime closeDateTime = DateTime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day());
        List<String> values = new List<String>{
            opp.Id != null ? removeCommas(opp.Id) : '',
            opp.Owner != null ? removeCommas(opp.Owner.FirstName + opp.Owner.LastName) : '',
            opp.Account != null ? removeCommas(opp.Account.Name) : '',
            opp.Account.Id != null ? removeCommas(opp.Account.Id) : '',
            opp.Name != null ? removeCommas(opp.Name) : '',
            opp.StageName != null ? removeCommas(opp.StageName) : '',
            opp.Fiscal_Period__c != null ? removeCommas(opp.Fiscal_Period__c) : '',
            opp.Amount != null ? removeCommas(String.valueOf(opp.Amount)) : '',
            opp.ExpectedRevenue != null ? removeCommas(String.valueOf(opp.ExpectedRevenue)) : '',
            opp.Probability != null ? removeCommas(String.valueOf(opp.Probability)) : '',
            opp.Opportunity_Age__c != null ? removeCommas(String.valueOf(opp.Opportunity_Age__c)) : '',
            closeDateTime != null ? closeDateTime.format('dd-MM-yyyy') : '',
            opp.CreatedDate != null ? opp.CreatedDate.format('dd-MM-yyyy') : '',
            opp.LeadSource != null ? removeCommas(opp.LeadSource) : '',
            opp.Type != null ? removeCommas(opp.Type) : '',
            opp.RecordType != null ? removeCommas(opp.RecordType.Name) : '',
            opp.Product_Interest__c != null ? removeCommas(opp.Product_Interest__c) : '',
            opp.Brand_Name1__r != null ? removeCommas(opp.Brand_Name1__r.Name) : '',
            opp.Linked_Client_Salesforce_Id__c != null ? removeCommas(opp.Linked_Client_Salesforce_Id__c) : '',
            opp.Linked_client_ID__c != null ? removeCommas(opp.Linked_client_ID__c) : '',
            opp.Owner.EmployeeNumber != null ? removeCommas(opp.Owner.EmployeeNumber) : ''
        };
        return String.join(values, ',');
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
	// Remove commas and quotes from a string
    private static String removeCommas(String value) {
        return value != null ? value.replaceAll('[,"]', '') : '';
    }
}