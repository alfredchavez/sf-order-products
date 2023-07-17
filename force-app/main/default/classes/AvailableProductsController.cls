public with sharing class AvailableProductsController {
    @AuraEnabled
    public static List<Product> getAvailableProducts(Id orderId) {
        try {
            List<PricebookEntry> availablePricebookEntries = PricebookEntryService.getPricebooksAvailableForOrder(orderId);
            List<Product> products = new List<Product>();
            for (PricebookEntry entry : availablePricebookEntries) {
                products.add(new Product(entry));
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

    public class Product {
        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public Decimal price { get; set; }

        public Product(Id product2Id, String name, Decimal price) {
            this.id = product2Id;
            this.name = name;
            this.price = price;
        }

        public Product(PricebookEntry pricebookEntry) {
            this.id = pricebookEntry.Product2Id;
            this.name = pricebookEntry.Product2.Name;
            this.price = pricebookEntry.UnitPrice;
        }

    }
}
