/**
 * Created by achavez on 17/07/23.
 */

@IsTest
private class OrderProductServiceTest {

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
    static void testAddProductToOrderIfAlreadyAdded() {
        Integer expectedQuantity = 2;
        OrderItem orderProductThatExists = [SELECT Id FROM OrderItem LIMIT 1][0];
        Product2 product = [SELECT Id FROM Product2 WHERE Name= :'Product 1' LIMIT 1][0];
        Order order = [SELECT Id FROM Order LIMIT 1][0];
        OrderItem orderProduct = OrderProductService.addProductToOrder(product.Id, order.Id);
        System.assertEquals(orderProduct.Id, orderProductThatExists.Id);
        System.assertEquals(orderProduct.Quantity, expectedQuantity);
    }

    @IsTest
    static void testAddProductToOrderIfNotAddedBefore() {
        Integer expectedQuantity = 1;
        OrderItem orderProductThatExists = [SELECT Id FROM OrderItem LIMIT 1][0];
        Product2 product = [SELECT Id FROM Product2 WHERE Name= :'Product 2' LIMIT 1][0];
        Order order = [SELECT Id FROM Order LIMIT 1][0];
        OrderItem orderProduct = OrderProductService.addProductToOrder(product.Id, order.Id);
        System.assertNotEquals(orderProduct.Id, orderProductThatExists.Id);
        System.assertEquals(orderProduct.Quantity, expectedQuantity);
    }

    @IsTest
    static void testGetOrderProducts() {
        Order order = [SELECT Id FROM Order LIMIT 1][0];
        List<OrderItem> orderProducts = OrderProductService.getOrderProducts(order.Id);
        System.assertEquals(orderProducts.size(), 1);
    }
}