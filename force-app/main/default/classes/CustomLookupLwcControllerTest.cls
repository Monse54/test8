@isTest
public class CustomLookupLwcControllerTest {
    
    @isTest
    static void testFetchLookupData() {
        // Set up test data
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ acc1, acc2 };
        
        // Call the fetchLookupData method
        List<sObject> result = CustomLookupLwcController.fetchLookupData('Test', 'Account', 'Name', 'Id');
        
      
    }
    
    @isTest
    static void testFetchDefaultRecord() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Call the fetchDefaultRecord method
        sObject result = CustomLookupLwcController.fetchDefaultRecord(acc.Id, 'Account', 'Name', 'Id');
        
        // Verify the result
        System.assertEquals(acc.Name, result.get('Name'));
        System.assertEquals(acc.Id, result.get('Id'));
    }
    
    @isTest
    static void testGetNameFromRecord() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Call the getNameFromRecord method
        sObject result = CustomLookupLwcController.getNameFromRecord(acc.Id, 'Account');
        
        // Verify the result
        System.assertEquals(acc.Name, result.get('Name'));
        System.assertEquals(acc.Id, result.get('Id'));
    }
}