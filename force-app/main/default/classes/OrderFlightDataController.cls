public without sharing class OrderFlightDataController {
    
    @AuraEnabled
    public static string insertFlightItem(Id orderItem){
        try {
            Order_Flight__c fli = new Order_Flight__c(Order_Product__c = orderItem);
            insert fli;
            return fli.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string insertOrderItem(Id orderId){
        try {
            
            Order order = [SELECT Id, CurrencyIsoCode FROM Order WHERE Id =: orderId ];
            PricebookEntry pbe = [SELECT Id, Name From PricebookEntry WHERE CurrencyIsoCode =: order.CurrencyIsoCode LIMIT 1];
            OrderItem oli = new OrderItem(OrderId = orderId, PricebookEntryId = pbe.Id, UnitPrice = 1 , Quantity = 1);
            insert oli;
            return oli.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* @AuraEnabled(cacheable=True)
     public static List<OrderItem> getOrderItemData(Id orderId) {
        System.debug('orderId-->>'+orderId);
        List<OrderItem> orders = [SELECT Id,OrderItemNumber FROM OrderItem where OrderId =:orderId];
        System.debug('orders-->>'+orders);
        return orders;
     }*/
     @AuraEnabled(cacheable=True)
     public static Decimal getProductData(Id orderId, String productType, Id subProductType, String costType) {
        System.debug('orderId-->>'+orderId);
        System.debug('productType-->>'+productType); 
        System.debug('subProductType-->>'+subProductType);
        System.debug('costType-->>'+costType);
        List<OrderItem> orders = [SELECT Id,Product__c,Sub_Product__c,Cost_Type__c FROM OrderItem where Id =:orderId]; 
        System.debug('orders-->>'+orders); 
        String sproductType = orders[0].Product__c;
        Id ssubProductType = orders[0].Sub_Product__c;
        String scostType = orders[0].Cost_Type__c; 
        String query = 'SELECT Pricing_Model__c,Product_Sub_Type__c,Product_Type__c,List_Price__c  FROM Product_Price_List__c ';
        query += ' where Product_Type__c =: ';
         
         if(productType == null){ query += ' sproductType ';} else{query += ' productType ';}  
        query += ' and Product_Sub_Type__c =: '; 
         if( subProductType == null) {query += 'ssubProductType ';} else{query += ' subProductType '; }  
        query += ' and Pricing_Model__c =: ';  
         if(costType == null) {query += 'scostType ';} else{query += ' costType ';}
        System.debug('query-->'+query);
         
        List<Product_Price_List__c> productList = DataBase.query(query);
        System.debug('productList-->>'+productList);
         if(productList.Size()>0){
        return productList[0].List_Price__c;}
         else{return -1;}
     }
    

     @AuraEnabled(cacheable=false)
     public static void updateField(String fieldName, String fieldValue, String recordId) {
        // Get the SObject type for the record
        Id recId = recordId;
        SObjectType objectType = recId.getSObjectType();
        // Get the field describe result for the target field
        SObjectField field = objectType.getDescribe().fields.getMap().get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        // Convert the field value to the appropriate type based on the target field type
        Object convertedValue;
        if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
            convertedValue = Boolean.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.CURRENCY) {
            convertedValue = Double.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.DATE) {
            convertedValue = Date.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.DATETIME) {
            convertedValue = DateTime.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.PERCENT) {
            convertedValue = Double.valueOf(fieldValue);
        } else if (fieldDescribe.getType() == Schema.DisplayType.INTEGER) {
            convertedValue = Integer.valueOf(fieldValue);
        } else {
            convertedValue = fieldValue;
        }
        // Create a new instance of the SObject and populate the Id and target field
        SObject record = objectType.newSObject(recordId);
        record.put(fieldName, convertedValue);
        // Update the record
        update record;
      }
  

    
    @AuraEnabled(cacheable=True)
    public static String getOrderFlightData(Id orderId) {
        Integer dataNum = 0;
        List<OrderDetails> flightDataWithOrders = new List<OrderDetails>();
        
        Set<String> setValues = new Set<String>();
        List<Map<Id,OrderDetails>> orderLists = new List<Map<Id,OrderDetails>>();
       	List<OrderItem> orders = [SELECT Id,Budget__c,Cost_Type__c,End_Date__c,Impressions__c,List_Price__c,OrderItemNumber,Placement__c,Product__c,Quantity,Start_Date__c,Status__c,Sub_Product__c,Sales_Price__c,TotalPrice,UnitPrice FROM OrderItem where OrderId =:orderId and Id != null];
            Boolean childData = false;
            for(OrderItem order : orders) {
            List<Product_Price_List__c > productlst = [SELECT Pricing_Model__c,Product_Sub_Type__c,Product_Type__c,List_Price__c  FROM Product_Price_List__c where Product_Sub_Type__c =: order.Sub_Product__c and Product_Type__c =: order.Product__c and Pricing_Model__c =: order.Cost_Type__c];
         
            List<OrderDetailsChild> orderlst = new List<OrderDetailsChild>();
                OrderDetails od = new OrderDetails();
                childData = false;
                od.Id = order.Id;
                od.Impressions_Tempc = order.Impressions__c;
                if(productlst.size()>0)
                od.UnitPrice = productlst[0].List_Price__c;
                od.TotalPrice = order.TotalPrice;
                od.List_Price_Tempc = order.List_Price__c;
                od.Sales_Price_Tempc = order.Sales_Price__c;
                od.Oli_Start_Date_Tempc = order.Start_Date__c;
                od.Oli_Placement_Tempc = order.Placement__c;
                od.Oli_Cost_Type_Tempc = order.Cost_Type__c;
                od.Oli_End_Date_Tempc = order.End_Date__c;
                od.Oli_Budget_Tempc = order.Budget__c;
                if(order.Budget__c != null && order.Sales_Price__c != null)
                od.Oli_Quantity = (order.Budget__c/order.Sales_Price__c).intValue();
                od.Oli_Status_Tempc = order.Status__c;
                od.Oli_Sub_Product_Tempc = order.Sub_Product__c;
                od.Oli_Product_Tempc = order.Product__c;
                od.OrderItemNumber = order.OrderItemNumber;
                od.isExpandable = true;
                od.isVisible = true;
                od.rowStyle = 'slds-hide';
                od.nameStyle = 'chevronright';
                
                for(Order_Flight__c flightData : [SELECT Id,End_Date__c,Name,Price__c,Product__c,Quantity__c,Target_GEO__c,Placement__c,ROO__c,Cost_Type__c,Budget__c,Channel__c,Channel_Account__r.name,Notes__c,Creative__c, Order_Product__c,Sub_Product__c,Start_Date__c,Status__c FROM Order_Flight__c where Order_Product__c =:order.Id]){
                    
                    OrderDetailsChild ordch = new OrderDetailsChild();
                    ordch.Id = flightData.Order_Product__c;
                    ordch.orderFlightId = flightData.Id;
                    ordch.Name = flightData.Name;
                    ordch.Fli_Sub_Product_Tempc = flightData.Sub_Product__c;
                    ordch.Fli_Start_Date_Tempc = flightData.Start_Date__c;
                    ordch.Fli_End_Date_Tempc = flightData.End_Date__c;
                    ordch.Fli_Status_Tempc = flightData.Status__c;
                    ordch.Fli_Product_Tempc = flightData.Product__c;
                    ordch.Fli_Quantity_Tempc = flightData.Quantity__c; 
                    ordch.Target_GEO_Tempc = flightData.Target_GEO__c;
                    ordch.ROO_Tempc = flightData.ROO__c;
                    ordch.Fli_Placement_Tempc = flightData.Placement__c;
                    ordch.Fli_Cost_Type_Tempc = flightData.Cost_Type__c;
                    ordch.Fli_Budget_Tempc = flightData.Budget__c;
                    ordch.Channel_Tempc = flightData.Channel__c;
                    ordch.Price_Tempc = flightData.Price__c;
                    ordch.Channel_Account_Tempc = flightData.Channel_Account__r.Name;
                    ordch.Notes_Tempc = flightData.Notes__c;
                    ordch.Creative_Tempc = flightData.Creative__c;
                    orderlst.add(ordch);
            	}
                    od.orderdetailch = orderlst;
                    flightDataWithOrders.add(od);
            }
            String jsonstring = Json.serialize(flightDataWithOrders); 
            String filterString = OrderFlightDataController.filterRequest(jsonstring);
            System.debug(filterString); 

    System.debug('Final Orders-->>'+filterString);
            
    return filterString;
    }
    private static String filterRequest(String value) {
    //regex not thoroughly tested
    return value.replaceall('Tempc"\\s*:', '_c" :');
    }
    @AuraEnabled
    public static Boolean deleteRecord(Id recordId, String objectType) {
        try {
            SObject recordToDelete = (SObject)Type.forName('Schema', objectType).newInstance();
            recordToDelete.Id = recordId;
            delete recordToDelete;
            return true;
        } catch (Exception e) {
            System.debug('An error occurred while deleting the record: ' + e.getMessage());
            return false;
        }
    }
    public class OrderDetails{
        @AuraEnabled
        public string Id{get;set;}
        @AuraEnabled
        public Boolean parentId{get;set;}  // Only fill this for Flights. (It must hold OP's id)
        @AuraEnabled
        public Boolean isExpandable{get;set;}
        @AuraEnabled
        public Boolean isVisible{get;set;}     // Always true for OP, but default false for Flights
        @AuraEnabled
        public string Name{get;set;}
        @AuraEnabled
        public Date Oli_Start_Date_Tempc{get;set;}
        @AuraEnabled
        public Date Fli_Start_Date_Tempc{get;set;}
        @AuraEnabled
        public Decimal List_Price_Tempc{get;set;}
        @AuraEnabled
        public Decimal Sales_Price_Tempc{get;set;}
        @AuraEnabled
        public string Oli_Placement_Tempc{get;set;}
        @AuraEnabled
        public string Fli_Placement_Tempc{get;set;}
        @AuraEnabled
        public string Target_GEO_Tempc{get;set;}
        @AuraEnabled
        public string ROO_Tempc{get;set;}
        @AuraEnabled
        public string Oli_Cost_Type_Tempc{get;set;}
        @AuraEnabled
        public string Fli_Cost_Type_Tempc{get;set;}
        @AuraEnabled
        public Date Oli_End_Date_Tempc{get;set;}
        @AuraEnabled
        public Date Fli_End_Date_Tempc{get;set;}
        @AuraEnabled
        public Decimal Oli_Budget_Tempc{get;set;}  
        @AuraEnabled
        public Decimal Fli_Budget_Tempc{get;set;}  
        @AuraEnabled
        public string Channel_Tempc{get;set;}
        @AuraEnabled
        public Decimal Price_Tempc{get;set;}
        @AuraEnabled
        public Id Channel_Account_Tempc{get;set;} 
        @AuraEnabled
        public string Notes_Tempc{get;set;} 
        @AuraEnabled
        public string Creative_Tempc{get;set;}
        @AuraEnabled
        public string Oli_Status_Tempc{get;set;}
        @AuraEnabled
        public string Fli_Status_Tempc{get;set;}
        @AuraEnabled
        public Decimal Impressions_Tempc{get;set;}
        @AuraEnabled
        public Id Fli_Sub_Product_Tempc{get;set;}
        @AuraEnabled
        public Id Oli_Sub_Product_Tempc{get;set;}
        @AuraEnabled
        public string Oli_Product_Tempc{get;set;}
        @AuraEnabled
        public string Fli_Product_Tempc{get;set;}
        @AuraEnabled
        public Decimal UnitPrice{get;set;}
        @AuraEnabled
        public Decimal Oli_Quantity {get;set;}
        @AuraEnabled
        public Decimal TotalPrice{get;set;}
        @AuraEnabled
        public string OrderItemNumber{get;set;}
        @AuraEnabled
        public string nameStyle{get;set;}
        @AuraEnabled
        public string rowStyle{get;set;}
        @AuraEnabled
        public List<OrderDetailsChild> orderdetailch{get;set;}
        
    }
        public class OrderDetailsChild{
            @AuraEnabled
            public String Id {get;set;}
            @AuraEnabled
            public Id orderFlightId {get;set;}
            @AuraEnabled
            public String Name {get;set;}
            @AuraEnabled
            public String Fli_Sub_Product_Tempc {get;set;}
            @AuraEnabled
            public Date Fli_Start_Date_Tempc {get;set;}
            @AuraEnabled
            public Date Fli_End_Date_Tempc {get;set;}
            @AuraEnabled
            public String Fli_Status_Tempc {get;set;}
            @AuraEnabled
            public String Fli_Product_Tempc {get;set;}
            @AuraEnabled
            public Decimal Fli_Quantity_Tempc {get;set;}
            @AuraEnabled
            public String Target_GEO_Tempc {get;set;}
            @AuraEnabled
            public String ROO_Tempc {get;set;}
            @AuraEnabled
            public String Fli_Placement_Tempc {get;set;}
            @AuraEnabled
            public String Fli_Cost_Type_Tempc {get;set;}
            @AuraEnabled
            public Decimal Fli_Budget_Tempc {get;set;}
            @AuraEnabled
            public String Channel_Tempc {get;set;}
            @AuraEnabled
            public Decimal Price_Tempc {get;set;}
            @AuraEnabled
            public String Channel_Account_Tempc {get;set;}
            @AuraEnabled
            public String Notes_Tempc {get;set;}
            @AuraEnabled
            public String Creative_Tempc {get;set;}
            
        }

    


    
}