/**
 * Created by achavez on 17/07/23.
 */

public with sharing class RequestCatcherService {
    public static String API_URL = 'https://alfredsf1.requestcatcher.com/test';

    public static HttpResponse post(ActivatePayload body) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(API_URL);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(5000);
        req.setBody(body.toJSONString());
        HttpResponse response = new Http().send(req);
        return response;
    }

    public class ActivatePayload {
        public String accountNumber{get;set;}
        public String orderNumber{get;set;}
        public String type{get;set;}
        public String status{get;set;}
        public List<OrderProductsActivatePayload> orderProducts{get;set;}

        public ActivatePayload accountNumber(String accNumber) {
            this.accountNumber = accNumber;
            return this;
        }
        public ActivatePayload orderNumber(String orderNumber) {
            this.orderNumber = orderNumber;
            return this;
        }
        public ActivatePayload type(String type) {
            this.type = type;
            return this;
        }
        public ActivatePayload status(String status) {
            this.status = status;
            return this;
        }

        public ActivatePayload orderProducts(List<OrderItem> orderProducts) {
            this.orderProducts = new List<OrderProductsActivatePayload>();
            for(OrderItem item: orderProducts) {
                this.orderProducts.add(new OrderProductsActivatePayload(item));
            }
            return this;
        }

        public String toJSONString() {
            return JSON.serialize(this);
        }

    }

    public class OrderProductsActivatePayload {
        public String name{get;set;}
        public String code{get;set;}
        public Decimal unitPrice{get;set;}
        public Decimal quantity{get;set;}
        public OrderProductsActivatePayload(OrderItem orderItem) {
            this.name = orderItem.Product2.Name;
            this.code = orderItem.Product2.ProductCode;
            this.unitPrice = orderItem.UnitPrice;
            this.quantity = orderItem.Quantity;
        }
    }

}