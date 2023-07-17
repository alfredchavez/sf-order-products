/**
 * Created by achavez on 17/07/23.
 */

public with sharing class OrderService {
    private static Boolean orderProductsCached = false;
    private static List<OrderItem> cachedOrderProducts = new List<OrderItem>();

    public static Order activateOrder(Id orderId) {
        Order order = getOrder(orderId);
        order.Status = 'Activated';
        update order;
        return order;
    }

    public static Boolean isProductIncluded(Id orderId, Id productId, Boolean useCache) {
        if(!useCache || !orderProductsCached) {
            cachedOrderProducts = OrderProductService.getOrderProducts(orderId);
            orderProductsCached = true;
        }
        for (OrderItem oProduct : cachedOrderProducts) {
            if (productId == oProduct.Product2Id) return true;
        }
        return false;
    }

    public static Order getOrder(Id orderId) {
        List<Order> orders = [SELECT Id, Name, Pricebook2Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
        if(orders.isEmpty()) throw new QueryException('Order does not exist');
        return orders[0];
    }

}