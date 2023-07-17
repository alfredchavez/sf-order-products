/**
 * Created by achavez on 17/07/23.
 */

public with sharing class PricebookEntryService {
    public static List<PricebookEntry> getPricebooksAvailableForOrder (Id orderId) {
        Order ord = [
                SELECT Id, Pricebook2Id
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
        ];
        List<PricebookEntry> availablePriceBookEntries = [
                SELECT Id, Product2.Name, Product2.Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :ord.Pricebook2Id
        ];
        return availablePriceBookEntries;
    }
}