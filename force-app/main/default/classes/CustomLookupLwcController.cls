public class CustomLookupLwcController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, string displayField, string dbValueField) {    
         List < sObject > returnList = new List < sObject > ();
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = 'Select ' + displayField + ',' + dbValueField + ' From ' + sObjectApiName + ' Where '+ displayField + ' Like : sWildCardText order by createdDate DESC LIMIT 5';
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName, string displayField, string dbValueField) {
         string sRecId = recordId;    
         string sQuery = 'Select ' + displayField + ',' + dbValueField + ' From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }

     @AuraEnabled
     public static sObject getNameFromRecord(string recId, string nameLookupObject){
        try {
            string sRecId = recId;    
            string sQuery = 'Select Id, Name From ' + nameLookupObject + ' Where Id = : sRecId LIMIT 1';
            for (sObject obj: database.query(sQuery)) {
                return obj;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     }
     
 }