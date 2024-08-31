public class AzureAccountExtractionSchedule implements Schedulable {
    public void execute(SchedulableContext context) {
        AzureAccountExtractionBatch batch = new AzureAccountExtractionBatch();
        Database.executeBatch(batch);
    }
}