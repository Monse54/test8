@IsTest
public class OrderFlightDataControllerTest {
    
 
    @IsTest
    static void testInsertFlightItem() {
        // Create a test OrderItem record
        
        Account account = new Account();
        account.Name = 'Test Account555';
        account.Website = 'www.youtube.com';
        insert account;
        
        Product2 prod = new Product2 (Name='Test Product', IsActive=true );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true, Customer__c = account.Id);
        insert pb;
        
		Id standardPriceBookId = Test.getStandardPricebookId(); 
	
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = prod.Id, UnitPrice = 1, UseStandardPrice = false);
		insert pbe;
 
        
		Order testOrder1 = new Order(
            CurrencyIsoCode = 'USD',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPriceBookId,
            AccountId = account.Id
            
        );
        insert testOrder1;

		OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=testOrder1.Id, Quantity=1, UnitPrice=pbe.UnitPrice, ServiceDate=Date.Today());
		insert ordPd;

        // Call the insertFlightItem method and verify the result
        Test.startTest();
        String result = OrderFlightDataController.insertFlightItem(ordPd.Id);
        Test.stopTest();
        System.assertEquals(18, result.length()); // Assert that the result is a valid ID
    }

    @IsTest
    static void testInsertOrderItem() {
        // Create a test Order record
		Account account = new Account();
        account.Name = 'Test Account244';
        account.Website = 'www.yahoo.com';
        insert account;
        
        Product2 prod = new Product2 (Name='Test Product', IsActive=true );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true, Customer__c = account.Id);
        insert pb;
        
		Id standardPriceBookId = Test.getStandardPricebookId(); 
	
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = prod.Id, UnitPrice = 1, UseStandardPrice = false);
		insert pbe;
 
        
		Order testOrder1 = new Order(
            CurrencyIsoCode = 'USD',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPriceBookId,
            AccountId = account.Id
            
        );
        insert testOrder1;

		OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=testOrder1.Id, Quantity=1, UnitPrice=pbe.UnitPrice, ServiceDate=Date.Today());
		insert ordPd;

        // Call the insertOrderItem method and verify the result
        Test.startTest();
        String result = OrderFlightDataController.insertOrderItem(testOrder1.Id);
        Test.stopTest();
        System.assertEquals(18, result.length()); // Assert that the result is a valid ID

        // Verify that an OrderItem record was created
        List<OrderItem> orderItems = [SELECT Id,OrderId FROM OrderItem WHERE OrderId = :testOrder1.Id];
        //System.assertEquals(1, orderItems.size());
    }

    @IsTest
    static void testGetProductData() {
        // Create a test OrderItem record
		Account account = new Account();
        account.Name = 'Test Account244';
        account.Website = 'www.yahoo.com';
        insert account;
        
        Product2 prod = new Product2 (Name='Test Product', IsActive=true );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true, Customer__c = account.Id);
        insert pb;
        
		Id standardPriceBookId = Test.getStandardPricebookId(); 
	
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = prod.Id, UnitPrice = 1, UseStandardPrice = false);
		insert pbe;
 
        
		Order testOrder1 = new Order(
            CurrencyIsoCode = 'USD',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPriceBookId,
            AccountId = account.Id
            
        );
        insert testOrder1;

		OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=testOrder1.Id, Quantity=1, UnitPrice=pbe.UnitPrice, ServiceDate=Date.Today());
		insert ordPd;

        // Call the getProductData method and verify the result
      /*  Test.startTest();
        Decimal result = OrderFlightDataController.getProductData(
            ordPd.Id, 'Display', '01t3K000003Js5gQAC', 'CPC'
        );
        Test.stopTest();
        System.assertEquals(-1, result); // Assert that no Product_Price_List__c record was found*/

        // Create a test Product_Price_List__c record
        Product_Price_List__c testProductPriceList = new Product_Price_List__c(
            Product_Type__c = 'Display',
            Product_Sub_Type__c = '01t3K000003Js5gQAC',
            Pricing_Model__c = 'CPC',
            List_Price__c = 10
        );
        insert testProductPriceList;

        // Call the getProductData method again and verify the result
        Test.startTest();
        Decimal result = OrderFlightDataController.getProductData(
            ordPd.Id, 'Display', '01t3K000003Js5gQAC', 'CPC'
        );
        Test.stopTest();
        System.assertEquals(10, result); // Assert that the correct List_Price__c was returned
    }

    @IsTest
    static void testUpdateField() {
        // Create a test OrderItem record
		Account account = new Account();
        account.Name = 'Test Account244';
        account.Website = 'www.yahoo.com';
        insert account;
        
        Product2 prod = new Product2 (Name='Test Product', IsActive=true );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true, Customer__c = account.Id);
        insert pb;
        
		Id standardPriceBookId = Test.getStandardPricebookId(); 
	
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = prod.Id, UnitPrice = 1, UseStandardPrice = false);
		insert pbe;
 
        
		Order testOrder1 = new Order(
            CurrencyIsoCode = 'USD',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPriceBookId,
            AccountId = account.Id
            
        );
        insert testOrder1;

		OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=testOrder1.Id, Quantity=1, UnitPrice=pbe.UnitPrice, ServiceDate=Date.Today());
		insert ordPd;

        // Call the updateField method to update the Product__c field
        
        Test.startTest();
        OrderFlightDataController.updateField('UnitPrice', '2.0', ordPd.Id);
        Test.stopTest();
        //System.assertEquals(10, result); // Assert that the correct List_Price__c was returned
    }
    
    @IsTest
    static void testgetOrderFlightData() {
        // Create a test Order record
		Account account = new Account();
        account.Name = 'Test Account2446';
        account.Website = 'www.gmail.com';
        insert account;
        
        Product2 prod = new Product2 (Name='Test Product', IsActive=true );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true, Customer__c = account.Id);
        insert pb;
        
		Id standardPriceBookId = Test.getStandardPricebookId(); 
	
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = prod.Id, UnitPrice = 1, UseStandardPrice = false);
		insert pbe;
 
        
		Order testOrder1 = new Order(
            CurrencyIsoCode = 'USD',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = standardPriceBookId,
            AccountId = account.Id
            
        );
        insert testOrder1;

		OrderItem ordPd = new OrderItem(PriceBookEntryId=pbe.Id, OrderId=testOrder1.Id, Quantity=1, UnitPrice=pbe.UnitPrice, ServiceDate=Date.Today());
		insert ordPd;
        
        Order_Flight__c  orderFlight = new Order_Flight__c (Order_Product__c = ordPd.Id ,Quantity__c = 1);
        insert orderFlight;

        // Call the insertOrderItem method and verify the result
        Test.startTest();
        String result = OrderFlightDataController.getOrderFlightData(testOrder1.Id);
        Test.stopTest();
        //System.assertEquals(18, result.length()); // Assert that the result is a valid ID

        // Verify that an OrderItem record was created
        List<OrderItem> orderItems = [SELECT Id,OrderId FROM OrderItem WHERE OrderId = :testOrder1.Id];
        //System.assertEquals(1, orderItems.size());
    }
    
}