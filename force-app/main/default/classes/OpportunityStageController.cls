public with sharing class OpportunityStageController {
   
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String strObjectName, String strPicklistField) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        
        Map<String, String> mapPickListValues = new Map<String, String>();
		Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
		Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
		Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
		List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
              Map < String, String > values = new Map < String, String > {
                'label' => objPickList.getLabel(),
                'value' => objPickList.getValue()
            };
            options.add(values);
    		System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
		}
        System.debug('options-->>'+options);
        return options;
    } 



    @AuraEnabled
    public static void saveValues(Id recordid, String lostReason, String comment) {
        Opportunity opp = [select id,Reason__c ,Comments__c from Opportunity where Id=: recordid];
        opp.Reason__c  = lostReason;
        opp.Comments__c = comment;
        System.debug('opp-->>'+opp);
        update opp;
    }
    
}