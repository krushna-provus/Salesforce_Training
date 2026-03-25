public with sharing class QuoteLineItemDao {
    public static List<PricebookEntry> getPriceBookEntriesBasedOnIds(Set<Id> priceBookEntries){
        return [SELECT Id, Product2.Product_Category__r.Default_Discount__c 
                FROM PricebookEntry 
                WHERE Id IN :priceBookEntries];
    }
}