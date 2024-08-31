public class AzureOpportunityExtractionSchedulable implements Schedulable {
     public void execute(SchedulableContext context) {
        AzureOpportunityExtractionBatch batch = new AzureOpportunityExtractionBatch();
        Database.executeBatch(batch);
    }

}