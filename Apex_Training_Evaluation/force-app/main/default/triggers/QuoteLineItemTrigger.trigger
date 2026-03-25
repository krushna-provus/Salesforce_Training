trigger QuoteLineItemTrigger on QuoteLineItem (before insert,after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert){
        QuoteLineItemAutomatedDiscountHandler.discountBasedOnProductCategory(Trigger.new);
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        QuoteLineItemAutomatedDiscountHandler.checkThreshold(Trigger.new);
    }
}