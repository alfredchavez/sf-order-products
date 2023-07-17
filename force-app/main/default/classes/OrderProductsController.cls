/**
 * Created by achavez on 17/07/23.
 */

public with sharing class OrderProductsController {
    @AuraEnabled
    public static List<OrderProduct> getOrderProducts(Id orderId) {
        try {
            List<OrderItem> oProducts = OrderProductService.getOrderProducts(orderId);
            List<OrderProduct> orderProducts = new List<OrderProduct>();
            for(OrderItem oProduct: oProducts) {
                orderProducts.add(new OrderProduct(oProduct));
            }
            return orderProducts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void activateOrder(Id orderId) {
        try {
            OrderService.activateOrder(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static OrderForDisplay getOrder(Id orderId) {
        try {
            return new OrderForDisplay(OrderService.getOrder(orderId));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OrderForDisplay {
        @AuraEnabled
        public Id id {get;set;}

        @AuraEnabled
        public String status {get; set;}

        public OrderForDisplay(Order order) {
            this.id = order.Id;
            this.status = order.Status;
        }
    }


    public class OrderProduct {
        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public Decimal unitPrice { get; set; }

        @AuraEnabled
        public Decimal totalPrice { get; set; }

        @AuraEnabled
        public Decimal quantity { get; set; }

        public OrderProduct(OrderItem orderProduct) {
            this.id = orderProduct.Id;
            this.name = orderProduct.Product2.Name;
            this.unitPrice = orderProduct.UnitPrice;
            this.totalPrice = orderProduct.TotalPrice;
            this.quantity = orderProduct.Quantity;
        }

    }
}