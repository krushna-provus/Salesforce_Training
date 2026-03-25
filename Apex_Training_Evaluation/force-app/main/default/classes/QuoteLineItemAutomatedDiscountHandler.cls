public with sharing class QuoteLineItemAutomatedDiscountHandler {

    //Handler 1
    public static void discountBasedOnProductCategory(List<QuoteLineItem> lineItems) {
        
        Set<Id> priceBookEntries = new Set<Id>();
        for(QuoteLineItem item : lineItems) {
            if(item.Auto_Apply_Discount__c == true && item.Discount == null && item.PricebookEntryId != null) {
                priceBookEntries.add(item.PricebookEntryId);
            }
        }
        
        if(priceBookEntries.isEmpty()) return;
        
        Map<Id, Decimal> pricebookEntriesToDiscountMap = new Map<Id, Decimal>();
        for (PricebookEntry pbe : QuoteLineItemDao.getPriceBookEntriesBasedOnIds(priceBookEntries)) {
            if (pbe.Product2.Product_Category__r != null) {
                pricebookEntriesToDiscountMap.put(pbe.Id, pbe.Product2.Product_Category__r.Default_Discount__c);
            }
        } 
        
        for (QuoteLineItem qli : lineItems) {
            if (pricebookEntriesToDiscountMap.containsKey(qli.PricebookEntryId)) {
                qli.Discount = pricebookEntriesToDiscountMap.get(qli.PricebookEntryId);
            }
        }
    }

    //Handler 2
    public static void checkThreshold(List<QuoteLineItem> lineItems) {
        
        Set<Id> priceBookEntryids = new Set<Id>();
        Set<Id> quoteIdsToFlag = new Set<Id>();
        
        for(QuoteLineItem item : lineItems) {
            if(item.Auto_Apply_Discount__c != true && item.Discount != null && item.PricebookEntryId != null && item.QuoteId != null) {
                priceBookEntryids.add(item.PricebookEntryId);
            }
        }
        
        if(priceBookEntryids.isEmpty()) return;
        
        Map<Id, List<Decimal>> productToDiscounts = new Map<Id, List<Decimal>>();
        for(PriceBookEntry pbe : QuoteLineItemDao.getPriceBookEntriesBasedOnIds(priceBookEntryids)) {
            if(pbe.Product2.Product_Category__r != null) {
                productToDiscounts.put(pbe.Id, new List<Decimal>{
                    pbe.Product2.Product_Category__r.Threshold_Discount__c, 
                    pbe.Product2.Product_Category__r.Max_Allowable_Discount__c
                });
            }                                           
        }
        
        for(QuoteLineItem qli : lineItems) {
            if(productToDiscounts.containsKey(qli.PricebookEntryId)) {
                List<Decimal> discLimits = productToDiscounts.get(qli.PricebookEntryId);
                
                if(qli.Discount > discLimits[0] && qli.Discount <= discLimits[1]) {
                    quoteIdsToFlag.add(qli.QuoteId);
                }
            }
        }

        if(!quoteIdsToFlag.isEmpty()) {
            List<Quote> quotesToUpdate = new List<Quote>();
            for(Id qId : quoteIdsToFlag) {
                quotesToUpdate.add(new Quote(
                    Id = qId, 
                    Is_Approval_Required__c = true
                ));
            }
            
            update quotesToUpdate;
        }
    }
}