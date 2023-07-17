/**
 * Created by achavez on 17/07/23.
 */

public with sharing class PricebookEntryService {
    public static List<PricebookEntry> getPricebooksAvailableForOrder(Id orderId) {
        Order order = OrderService.getOrder(orderId);
        List<PricebookEntry> availablePriceBookEntries = [
                SELECT Id, Product2.Name, Product2.Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :order.Pricebook2Id
        ];
        return availablePriceBookEntries;
    }

    public static PricebookEntry getPricebookEntry(Id productId, Id pricebookId) {
        List<PricebookEntry> pricebookEntries = [
                SELECT Id, UnitPrice
                FROM PricebookEntry
                WHERE Product2Id = :productId AND Pricebook2Id = :pricebookId
                LIMIT 1
        ];
        if (pricebookEntries.isEmpty()) throw new QueryException('Order does not exist');
        return pricebookEntries[0];
    }
}