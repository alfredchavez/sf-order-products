/**
 * Created by achavez on 17/07/23.
 */

@IsTest
private class PricebookEntryServiceTest {
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

    }

    @IsTest
    static void testGetPricebooksAvailableForOrder() {
        List<Order> orders = [SELECT Id FROM Order LIMIT 1];
        Order order = orders[0];
        List<PricebookEntry> pricebookEntries = PricebookEntryService.getPricebooksAvailableForOrder(order.Id);
        System.assertEquals(pricebookEntries.size(), 2);
    }

    @IsTest
    static void testGetPricebookEntry() {
        Id stdPricebookId = Test.getStandardPricebookId();
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = :'Product 1' LIMIT 1][0];
        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id AND Pricebook2Id = :stdPricebookId LIMIT 1][0];

        PricebookEntry obtainedEntry = PricebookEntryService.getPricebookEntry(prod.Id, stdPricebookId);

        System.assertEquals(obtainedEntry.Id, entry.Id);
    }
}