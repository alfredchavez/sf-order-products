public with sharing class AvailableProductsController {
    @AuraEnabled
    public static List<Product> getAvailableProducts(Id orderId, String search) {
        try {
            List<PricebookEntry> availablePricebookEntries = PricebookEntryService.getPricebooksAvailableForOrder(orderId, search);
            List<Product> products = new List<Product>();
            for (PricebookEntry entry : availablePricebookEntries) {
                products.add(new Product(entry, OrderService.isProductIncluded(orderId, entry.Product2Id, true)));
            }
            return products;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addProductToOrder(Id productId, Id orderId) {
        try {
            OrderProductService.addProductToOrder(productId, orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static OrderForDisplay getOrder(Id orderId) {
        try {
            Order order = OrderService.getOrder(orderId);
            return new OrderForDisplay(order);
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

    public class Product {
        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public Decimal price { get; set; }

        @AuraEnabled
        public Boolean alreadyAdded {get;set;}

        public Product(Id product2Id, String name, Decimal price, Boolean alreadyAdded) {
            this.id = product2Id;
            this.name = name;
            this.price = price;
            this.alreadyAdded = alreadyAdded;
        }

        public Product(PricebookEntry pricebookEntry, Boolean alreadyAdded) {
            this.id = pricebookEntry.Product2Id;
            this.name = pricebookEntry.Product2.Name;
            this.price = pricebookEntry.UnitPrice;
            this.alreadyAdded = alreadyAdded;
        }

    }
}
