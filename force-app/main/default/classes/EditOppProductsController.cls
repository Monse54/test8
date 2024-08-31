/**
    * @author Ramesh Kumar Gurusamy (CFG)
    * @date: 16-Apr-2022
    * @description: Custom controller for opp product component.
    * @date: 6-Jun-2022
    * @description: Implemented custom price list.
    * @testClass: EditOppProductsController_Test.
**/
public class EditOppProductsController {
    public EditOppProductsController(){}
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOppLineItemsList(String oppId) {
        // Getting the list of OpportunityLineItems
        System.debug('oppId***' + oppId);
        List<OpportunityLineItem> oppLineItemsList = [SELECT Id, Sales_Price__c, Opportunity.RecordType.DeveloperName, Placement_Name__c,
                                                      PricebookEntryId, Name, Product_Name__c, UnitPrice, Product2Id, Budget__c,
                                                      Product2.Name, Quantity, End_Date__c, Start_Date__c, Impression__c, Pricing_Model__c,
                                                      IMC_BU__c, Channel_Type__c, ProductType__c, Geo__c, List_Price__c, Notes__c, Target_Geo__c
                                                      FROM OpportunityLineItem 
                                                      WHERE OpportunityId=:oppId
                                                      ORDER BY Product2Id, Start_Date__c];
        system.debug('oppLineItemsList***' + oppLineItemsList);
        // Returning the OpportunityLineItems list
        return oppLineItemsList;
    }
    
    @AuraEnabled
    public static Product_Price_List__c getPriceList(String pType,String productId, String pModel, String accountId, String linkedAccountId, String currencyIsoCode) {
        system.debug('***getPriceList***');
        system.debug('pType***' + pType);
        system.debug('pModel***' + pModel);
        system.debug('accountId***' + accountId);
        system.debug('linkedAccountId***' + linkedAccountId);
        system.debug('currencyIsoCode***' + currencyIsoCode);
        Product_Price_List__c price = new Product_Price_List__c();
        List<Product_Price_List__c> priceList = [SELECT Id, List_Price__c 
                                                 FROM Product_Price_List__c 
                                                 WHERE Product_Sub_Type__c =:productId 
                                                 AND Product_Type__c=:pType 
                                                 AND Pricing_Model__c=:pModel 
                                                 AND CurrencyIsoCode=:currencyIsoCode
                                                 AND (Customer__c=:accountId OR Customer__c=:linkedAccountId)
                                                 ORDER BY LastModifiedDate DESC];
        system.debug('priceListWithCustomer***' + priceList);
        if(priceList == null || priceList.isEmpty()) priceList = [SELECT Id, List_Price__c 
                                                                  FROM Product_Price_List__c 
                                                                  WHERE Product_Sub_Type__c =:productId 
                                                 				  AND Product_Type__c=:pType 
                                                                  AND Pricing_Model__c=:pModel
                                                                  AND Customer__c=null
                                                                  AND CurrencyIsoCode=:currencyIsoCode
                                                                  ORDER BY LastModifiedDate DESC];
        system.debug('priceListWithoutCustomer***' + priceList);
        if(priceList != null && !priceList.isEmpty()) price = priceList[0];
        // Returning the price list
        return price;
    }
    
    @AuraEnabled
    public static String getProductList(String recordId) {
        OpportunityHelper helper = new OpportunityHelper();
        Opportunity opp = [SELECT Id, RecordType.DeveloperName, Opportunity_SubType__c, 
                           AccountId, Brand_Name1__c, Opportunity_Region__c, Opportunity_Sub_Region__c,
                           StageName, Start_Date_Rollup__c, End_Date_Rollup__c, End_Date__c, Account.Type,
                           Amount, CurrencyIsoCode, Account.BillingCountry, Launch_Date__c, 
                           Account.Record_Type_Name__c, Opportunity_Segment__c
                           FROM Opportunity 
                           WHERE Id=:recordId];
        System.debug('opp***' + opp);
        helper.opp = opp;
        helper.recordType = opp.RecordType.DeveloperName;
        helper.isAdmin = FALSE;
        if(UserInfo.getProfileId() == '00e30000001fLMB' || UserInfo.getProfileId() == '00e30000001fLMBAA2') helper.isAdmin = TRUE;
        /*List<Product2> productList = new list<Product2>();
        List<String> productCustomList = System.Label.productList.split(';');
        System.debug('productCustomList***' + productCustomList);
        productList = [SELECT Id, Name 
                       FROM Product2 
                       WHERE Name IN :productCustomList AND IsActive = true];
        helper.products = productList;
        List<String> pTypes = System.Label.productType.split(';');
        System.debug('pTypes***' + pTypes);
        helper.pTypes = pTypes;
        List<String> pModels = System.Label.pricingModel.split(';');
        System.debug('pModels***' + pModels);
        helper.pModels = pModels;
        List<String> pCountrys = System.Label.productCountry.split(';');
        System.debug('pCountrys***' + pCountrys);
        helper.pCountrys = pCountrys;*/
        system.debug('helper***' + helper);
        return JSON.serialize(helper);
    }
    
    @AuraEnabled
    public static Boolean updateOppLineItems(String lineItemList, String recordId) {
        System.debug('lineItemList***' + lineItemList);
        System.debug('recordId***' + recordId);
        
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
        if(String.isNotBlank(lineItemList)) {
            productList = (List<OpportunityLineItem>)System.JSON.deserialize(lineItemList, List<OpportunityLineItem>.class);
            System.debug('productList***' + productList);
        } else {
            System.debug('No records to process.');
            return true;
        }
        Map<ID, OpportunityLineItem> newOppLinesMap = new Map<ID, OpportunityLineItem>();
        List<OpportunityLineItem> productListToInsert = new List<OpportunityLineItem>();
        if(productList != null && !productList.isEmpty()) {
            for(OpportunityLineItem oppLineitem : productList) {
                if(oppLineitem.Id != null) {
                    newOppLinesMap.put(oppLineitem.Id, oppLineitem);
                } else {
                    oppLineitem.Invoke_Trigger__c = TRUE;
                    productListToInsert.add(oppLineitem);
                }
            }
        }
        System.debug('newOppLinesMap***' + newOppLinesMap);
        System.debug('productListToInsert***' + productListToInsert);
        
        Map<ID, OpportunityLineItem> existingOppLinesAllMap = new Map<ID, OpportunityLineItem>([SELECT Id, Sales_Price__c, Quantity, End_Date__c, Impression__c, Budget__c, Target_Geo__c, Placement_Name__c,
                                                                                                Start_Date__c, UnitPrice, Opportunity.RecordType.DeveloperName, Pricing_Model__c, List_Price__c 
                                                                                                FROM OpportunityLineItem 
                                                                                                WHERE OpportunityId=:recordId]);
        System.debug('existingOppLinesAllMap***' + existingOppLinesAllMap);
        List<OpportunityLineItem> productListToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> productListToDelete = new List<OpportunityLineItem>();
        Set<Id> productListIdsToBeUpdated = new Set<Id>();
        for(ID existingOppLineId: existingOppLinesAllMap.keySet()) {
            System.debug('existingOppLineId***' + existingOppLineId);
            OpportunityLineItem oppLineitem = existingOppLinesAllMap.get(existingOppLineId);
            System.debug('oppLineitem***' + oppLineitem);
            if(newOppLinesMap.get(existingOppLineId) != null) {
                OpportunityLineItem existingOppLineItem = newOppLinesMap.get(oppLineitem.Id);
                System.debug('existingOppLineItem***' + existingOppLineItem);
                if(existingOppLineItem != null 
                    && (existingOppLineItem.Sales_Price__c != oppLineitem.Sales_Price__c
                        || existingOppLineItem.Budget__c != oppLineitem.Budget__c
                        || existingOppLineItem.Impression__c != oppLineitem.Impression__c
                        || existingOppLineItem.Start_Date__c != oppLineitem.Start_Date__c
                        || existingOppLineItem.End_Date__c != oppLineitem.End_Date__c)
                        ) {
                    existingOppLineItem.Invoke_Trigger__c = TRUE;
                    productListIdsToBeUpdated.add(existingOppLineId);
                    productListToUpdate.add(existingOppLineItem);
                } else if(existingOppLineItem != null && existingOppLineItem.Target_Geo__c != oppLineitem.Target_Geo__c) {
                    existingOppLineItem.Invoke_Trigger__c = FALSE;
                    productListToUpdate.add(existingOppLineItem);
                } 
                /*else if(existingOppLineItem != null && existingOppLineItem.Placement_Name__c != oppLineitem.Placement_Name__c) {
                    existingOppLineItem.Invoke_Trigger__c = FALSE;
                    productListToUpdate.add(existingOppLineItem);
                }*/
            } else {
                productListToDelete.add(oppLineitem);
            }
        }
        System.debug('productListToUpdate***' + productListToUpdate);
        System.debug('productListToDelete***' + productListToDelete);
        System.debug('productListIdsToBeUpdated***' + productListIdsToBeUpdated);
        if((productListToInsert == null || productListToInsert.isEmpty()) 
            && (productListToUpdate == null || productListToUpdate.isEmpty())
            && (productListToDelete == null || productListToDelete.isEmpty())) {
            System.debug('No records to process.');
            return true;
        }
        //During update of OpportunityLineItems the delete of OpportunityLineItemSchedule must to done here to avoid infinte loop.
        List<OpportunityLineItemSchedule> schedulesToBeDeleted = [SELECT Id, OpportunityLineItemId 
                                                                  FROM OpportunityLineItemSchedule 
                                                                  WHERE OpportunityLineItemId IN :productListIdsToBeUpdated];
        try {
            if(schedulesToBeDeleted != null && !schedulesToBeDeleted.isEmpty()) {
                System.debug('schedulesToBeDeleted***' + schedulesToBeDeleted);
                delete schedulesToBeDeleted;
            }
            if(productListToDelete != null && !productListToDelete.isEmpty()) {
                System.debug('productListToDelete***' + productListToDelete);
                delete productListToDelete;
            }
        } catch(Exception e) { System.debug('Exception***' + e.getStackTraceString()); throw e; }
        
        List<OpportunityLineItem> listToUpsert = new List<OpportunityLineItem>();
        if(productListToInsert != null && !productListToInsert.isEmpty()) {
            Opportunity opp = [SELECT Id, Pricebook2Id, CurrencyISOCode 
                               FROM Opportunity 
                               WHERE Id=:recordId LIMIT 1][0];
            System.debug('opp***' + opp);
            
            Id pricebookId = opp.Pricebook2Id;
            if(opp.Pricebook2Id == null) {
                pricebookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1][0].Id;
                opp.Pricebook2Id = pricebookId;
                update opp;
            }
            if(Test.isRunningTest())
                pricebookId = Test.getStandardPricebookId();
            System.debug('pricebookId***' + pricebookId);
            
            Map<Id,Id> productIdVsPricebookIdMap = new Map<Id,Id>();
            Map<Id, String> productIdVsNameMap = new Map<Id, String>();
            for(PricebookEntry entry: [SELECT Id, Product2Id, Product2.Name 
                                       FROM PricebookEntry 
                                       WHERE Pricebook2Id=:pricebookId 
                                       AND CurrencyISOCode=:opp.CurrencyISOCode
                                       LIMIT 1999]) {
                productIdVsPricebookIdMap.put(entry.Product2Id, entry.Id);
                productIdVsNameMap.put(entry.Product2Id, entry.Product2.Name);
            }
            System.debug('productIdVsNameMap***' + productIdVsNameMap);
            for(OpportunityLineItem oppLineitem : productListToInsert) {
                oppLineitem.OpportunityId = recordId;
                oppLineitem.List_Price__c = oppLineitem.List_Price__c;
                if(oppLineitem.Sales_Price__c != null) {
                    oppLineitem.UnitPrice = oppLineitem.Sales_Price__c;
                    oppLineitem.Sales_Price__c = oppLineitem.Sales_Price__c;
                } /*else {
                    oppLineitem.UnitPrice = 0;
                }*/
                
                if(oppLineitem.Budget__c != null && oppLineitem.Budget__c != 0 && oppLineitem.Sales_Price__c != 0) {
                    oppLineitem.Budget__c = oppLineitem.Budget__c;
                    if(oppLineitem.Pricing_Model__c == 'CPM') {
                        system.debug('inside insert block');
                        oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                        oppLineitem.Impression__c = oppLineitem.Impression__c;
                    } else {
                        oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                        oppLineitem.Impression__c = oppLineitem.Impression__c;
                    }
                } else if(oppLineitem.Impression__c != null && oppLineitem.Impression__c != 0) {
                    oppLineitem.Impression__c = oppLineitem.Impression__c;
                    oppLineitem.Budget__c = oppLineitem.Impression__c * oppLineitem.Sales_Price__c;
                    oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                } /*else {
                    oppLineitem.Impression__c = oppLineitem.Start_Date__c.daysBetween(oppLineitem.End_Date__c) + 1;
                }*/
                if(!productIdVsPricebookIdMap.isEmpty() && productIdVsPricebookIdMap.containsKey(oppLineitem.Product2Id)) oppLineitem.PricebookEntryId = productIdVsPricebookIdMap.get(oppLineitem.Product2Id);
                if(!productIdVsNameMap.isEmpty() && productIdVsNameMap.containsKey(oppLineitem.Product2Id)) oppLineitem.Product_Name__c = productIdVsNameMap.get(oppLineitem.Product2Id);
                if(oppLineitem.Start_Date__c != null) {
                    oppLineitem.Start_Date__c = oppLineitem.Start_Date__c;
                }
                
                if(oppLineitem.End_Date__c != null) { oppLineitem.End_Date__c = oppLineitem.End_Date__c;
                } else {
                    /*System.debug('oppLineitem.Impression__c***' + oppLineitem.Impression__c);
                    System.debug('oppLineitem.Impression__c***' + (integer.valueof(oppLineitem.Impression__c)-1));
                    System.debug('oppLineitem.Start_Date__c***' + oppLineitem.Start_Date__c);
                    //oppLineitem.End_Date__c = oppLineitem.Start_Date__c.addMonths(integer.valueof(oppLineitem.Impression__c)) - 1;
                    System.debug('oppLineitem.End_Date__c***' + oppLineitem.End_Date__c);*/
                } 
                System.debug('oppLineitem.End_Date__c***' + oppLineitem.End_Date__c);
                listToUpsert.add(oppLineitem);
            }
        }
        if(productListToUpdate != null && !productListToUpdate.isEmpty()) {
            for(OpportunityLineItem oppLineitem : productListToUpdate) {
                if(oppLineitem.Id != null) {
                    if(oppLineitem.Sales_Price__c != null) {
                        oppLineitem.UnitPrice = oppLineitem.Sales_Price__c;
                        oppLineitem.Sales_Price__c = oppLineitem.Sales_Price__c;
                    } /*else {
                        oppLineitem.UnitPrice = 0;
                    }*/
                
                    if(oppLineitem.Budget__c != null && oppLineitem.Budget__c != 0 && oppLineitem.Sales_Price__c != 0) {
                        oppLineitem.Budget__c = oppLineitem.Budget__c;
                        if(oppLineitem.Pricing_Model__c == 'CPM') {
                            oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                            oppLineitem.Impression__c = oppLineitem.Impression__c;
                        } else {
                            oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                            oppLineitem.Impression__c = oppLineitem.Impression__c;
                        }
                    } else if(oppLineitem.Impression__c != null && oppLineitem.Impression__c != 0) {
                        oppLineitem.Impression__c = oppLineitem.Impression__c;
                        oppLineitem.Budget__c = oppLineitem.Impression__c * oppLineitem.Sales_Price__c;
                        oppLineitem.Quantity = oppLineitem.Budget__c / oppLineitem.Sales_Price__c;
                    } /*else {
                        oppLineitem.Impression__c = oppLineitem.Start_Date__c.daysBetween(oppLineitem.End_Date__c) + 1;
                    }*/
                    if(oppLineitem.End_Date__c != null) {
                        oppLineitem.End_Date__c = oppLineitem.End_Date__c;
                    } /*else {
                        oppLineitem.End_Date__c = oppLineitem.Start_Date__c.addMonths(Integer.valueof(oppLineitem.Quantity)) - 1;
                    }*/
                    System.debug('oppLineitem.End_Date__c***' + oppLineitem.End_Date__c);
                }
                listToUpsert.add(oppLineitem);
            }
        }
        System.debug('listToUpsert***' + listToUpsert);
        try {
            if(listToUpsert != null && !listToUpsert.isEmpty()) {
                upsert listToUpsert;
            }
        } catch(Exception e) {
            System.debug('Exception***' + e.getStackTraceString());
            throw e;
        }
        return true; 
    }
}