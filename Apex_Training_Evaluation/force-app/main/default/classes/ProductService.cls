public with sharing class ProductService {
    public static void createStandardPricebookEntry(List<Product2> products){
        Id standardPbId;
        if(Test.isRunningTest()){
            standardPbId = Test.getStandardPricebookId();
        }else{
            standardPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        }

        List<PricebookEntry> pbeToInsert = new List<PricebookEntry>();

        for(Product2 prod : products){
            if(prod.List_Price__c != null && prod.List_Price__c > 0){
                PricebookEntry pbe = new PricebookEntry(
                    Pricebook2Id = standardPbId,
                    Product2Id = prod.Id,
                    UnitPrice = prod.List_Price__c,
                    IsActive = true
                );
                pbeToInsert.add(pbe);
            }

            if(prod.Targeted_Price_Book__c != null){
                PricebookEntry pbeC = new PricebookEntry(
                    Pricebook2Id = prod.Targeted_Price_Book__c,
                    Product2Id = prod.Id,
                    UnitPrice = prod.List_Price__c,
                    IsActive = true
                );
                pbeToInsert.add(pbeC);
            }
        }

        if(!pbeToInsert.isEmpty()){
            insert pbeToInsert;
        }
    }
}