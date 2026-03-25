public with sharing class QuoteLineItemAutomatedDiscountHandler {

    //Handler 1
    public static void discountBasedOnProductCategory(List<QuoteLineItem> lineItems) {
        
        Set<Id> pbeIds = new Set<Id>();
        for(QuoteLineItem item : lineItems) {
            if(item.Auto_Apply_Discount__c == true && item.Discount == null && item.PricebookEntryId != null) {
                pbeIds.add(item.PricebookEntryId);
            }
        }
        
        if(pbeIds.isEmpty()) return;
        
        Map<Id, Decimal> pbeToDiscountMap = new Map<Id, Decimal>();
        for (PricebookEntry pbe : [SELECT Id, Product2.Product_Category__r.Default_Discount__c 
                                   FROM PricebookEntry 
                                   WHERE Id IN :pbeIds]) {
            if (pbe.Product2.Product_Category__r != null) {
                pbeToDiscountMap.put(pbe.Id, pbe.Product2.Product_Category__r.Default_Discount__c);
            }
        } 
        
        for (QuoteLineItem qli : lineItems) {
            if (pbeToDiscountMap.containsKey(qli.PricebookEntryId)) {
                qli.Discount = pbeToDiscountMap.get(qli.PricebookEntryId);
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
        for(PriceBookEntry pbe : [SELECT Id, Product2.Product_Category__r.Threshold_Discount__c, Product2.Product_Category__r.Max_Allowable_Discount__c 
                                  FROM PriceBookEntry WHERE Id IN :priceBookEntryids]) {
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