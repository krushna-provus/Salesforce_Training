trigger ProductTrigger on Product2 (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        ProductService.createStandardPricebookEntry(Trigger.new);
    }
}