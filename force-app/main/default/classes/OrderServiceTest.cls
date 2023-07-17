/**
 * Created by achavez on 17/07/23.
 */

@IsTest
private class OrderServiceTest {
    @TestSetup
    private static void setupTestData() {
        Account acc = new Account();
        acc.Name = 'Account 1';
        insert acc;

        Product2 testProduct1 = new Product2();
        testProduct1.Name = 'Product 1';
        testProduct1.IsActive = true;
        insert testProduct1;

        Product2 testProduct2 = new Product2();
        testProduct2.Name = 'Product 2';
        testProduct2.IsActive = true;
        insert testProduct2;

        Id stdPricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice1 = new PricebookEntry();
        standardPrice1.Pricebook2Id = stdPricebookId;
        standardPrice1.Product2Id = testProduct1.Id;
        standardPrice1.UnitPrice = 1;
        standardPrice1.IsActive = true;
        standardPrice1.UseStandardPrice = false;
        insert standardPrice1 ;

        PricebookEntry standardPrice2 = new PricebookEntry();
        standardPrice2.Pricebook2Id = stdPricebookId;
        standardPrice2.Product2Id = testProduct2.Id;
        standardPrice2.UnitPrice = 1;
        standardPrice2.IsActive = true;
        standardPrice2.UseStandardPrice = false;
        insert standardPrice2 ;

        Order ord = new Order();
        ord.Pricebook2Id = stdPricebookId;
        ord.Name = 'Order 1';
        ord.AccountId = acc.Id;
        ord.EffectiveDate = System.today();
        ord.EndDate = System.today() + 4;
        ord.Status = 'Draft';
        insert ord;

        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = ord.Id;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = standardPrice1.UnitPrice;
        orderItem.Product2Id = testProduct1.Id;
        orderItem.PricebookEntryId = standardPrice1.Id;
        insert orderItem;

    }

    @IsTest
    static void testActivateOrder() {
        String expectedStatus = 'Activated';

        List<Order> orders = [SELECT Id FROM Order LIMIT 1];
        Order order = orders[0];
        OrderService.activateOrder(order.Id);
        List<Order> newOrders = [SELECT Id, Status FROM Order LIMIT 1];
        Order newOrder = newOrders[0];

        System.assertEquals(newOrder.Status, expectedStatus);
    }

    @IsTest
    static void testIsProductIncludedShouldBeTrue() {
        List<Order> orders = [SELECT Id FROM Order LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name =: 'Product 1' LIMIT 1];
        Order order = orders[0];
        Product2 prod = products[0];
        Boolean included = OrderService.isProductIncluded(order.Id, prod.Id, false);
        System.assertEquals(included, true);
    }

    @IsTest
    static void testIsProductIncludedShouldBeFalse() {
        List<Order> orders = [SELECT Id FROM Order LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name =: 'Product 2' LIMIT 1];
        Order order = orders[0];
        Product2 prod = products[0];
        Boolean included = OrderService.isProductIncluded(order.Id, prod.Id, false);
        System.assertEquals(included, false);
    }

    @IsTest
    static void testIsProductIncludedUseCached() {
        Order order = [SELECT Id FROM Order LIMIT 1][0];
        Product2 prod1 = [SELECT Id FROM Product2 WHERE Name =: 'Product 1' LIMIT 1][0];
        Product2 prod2 = [SELECT Id FROM Product2 WHERE Name =: 'Product 2' LIMIT 1][0];
        Boolean included1 = OrderService.isProductIncluded(order.Id, prod1.Id, true);
        Boolean included2 = OrderService.isProductIncluded(order.Id, prod2.Id, true);
        Boolean included3 = OrderService.isProductIncluded(order.Id, prod1.Id, true);
        System.assertEquals(included1, true);
        System.assertEquals(included2, false);
        System.assertEquals(included3, true);
    }

    @IsTest
    static void testGetOrder() {
        String expectedOrderName = 'Order 1';

        List<Order> orders = [SELECT Id FROM Order LIMIT 1];
        Order order = orders[0];
        Order obtainedOrder = OrderService.getOrder(order.Id);

        System.assertEquals(obtainedOrder.Id, order.Id);
        System.assertEquals(obtainedOrder.Name, expectedOrderName);
    }
}