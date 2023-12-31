/**
 * Created by achavez on 17/07/23.
 */

public with sharing class OrderProductService {
    public static OrderItem addProductToOrder(Id productId, Id orderId) {
        List<OrderItem> orderProduct = [
                SELECT Id, Quantity
                FROM OrderItem
                WHERE Product2Id = :productId AND OrderId = :orderId
                LIMIT 1
        ];
        if (orderProduct.isEmpty()) {
            return createNewOrderProduct(productId, orderId);
        }
        return updateOrderProduct(orderProduct[0]);
    }

    public static OrderItem updateOrderProduct(OrderItem orderProduct) {
        orderProduct.Quantity += 1;
        update orderProduct;
        return orderProduct;
    }

    public static OrderItem createNewOrderProduct(Id productId, Id orderId) {
        Order order = OrderService.getOrder(orderId);
        PricebookEntry pricebookEntry = PricebookEntryService.getPricebookEntry(productId, order.Pricebook2Id);
        OrderItem orderProduct = new OrderItem();
        orderProduct.OrderId = orderId;
        orderProduct.Quantity = 1;
        orderProduct.UnitPrice = pricebookEntry.UnitPrice;
        orderProduct.Product2Id = productId;
        orderProduct.PricebookEntryId = pricebookEntry.Id;
        insert orderProduct;
        return orderProduct;
    }

    public static List<OrderItem> getOrderProducts(Id orderId) {
        List<OrderItem> orderProducts = [
                SELECT Id, Product2.Name, UnitPrice, TotalPrice, Quantity, Product2Id, Product2.ProductCode
                FROM OrderItem
                WHERE OrderId=:orderId
        ];
        return orderProducts;
    }

}