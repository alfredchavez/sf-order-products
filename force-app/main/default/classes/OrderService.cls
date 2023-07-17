/**
 * Created by achavez on 17/07/23.
 */

public with sharing class OrderService {
 public static Order activateOrder(Id orderId) {
     List<Order> orders = [SELECT Id FROM Order WHERE Id=:orderId LIMIT 1];
     if(orders.isEmpty()){
         throw new QueryException('Order does not exist');
     }
     Order order = orders[0];
     order.Status = 'Activated';
     update order;
     return order;
 }
}