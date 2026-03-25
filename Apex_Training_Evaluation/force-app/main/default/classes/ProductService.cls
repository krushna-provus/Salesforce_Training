public with sharing class ProductService {
    public static void createStandardPricebookEntry(List<Product2> products){
        Id standardPbId = ProductDao.getStandardPricebookId();

        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();

        for(Product2 prod : products){
            if(prod.List_Price__c != null && prod.List_Price__c > 0){
                PricebookEntry pricebookEntry = new PricebookEntry(
                    Pricebook2Id = standardPbId,
                    Product2Id = prod.Id,
                    UnitPrice = prod.List_Price__c,
                    IsActive = true
                );
                pricebookEntriesToInsert.add(pricebookEntry);
            }

            if(prod.Targeted_Price_Book__c != null){
                PricebookEntry customPriceBookEntry = new PricebookEntry(
                    Pricebook2Id = prod.Targeted_Price_Book__c,
                    Product2Id = prod.Id,
                    UnitPrice = prod.List_Price__c,
                    IsActive = true
                );
                pricebookEntriesToInsert.add(customPriceBookEntry);
            }
        }

        if(!pricebookEntriesToInsert.isEmpty()){
            insert pricebookEntriesToInsert;
        }
    }
}