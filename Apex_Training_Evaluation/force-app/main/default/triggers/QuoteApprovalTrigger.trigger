trigger QuoteApprovalTrigger on Quote (after update) {
	List<Quote> quoteToApprove = new List<Quote>();
    
    for(Quote newQuote : Trigger.new){
        
        Quote oldQuote = Trigger.oldMap.get(newQuote.Id);
        
        if(newQuote.Is_Approval_Required__c == true && oldQuote.Is_Approval_Required__c == false){
            quoteToApprove.add(newQuote);
        }
    }
    
    if(!quoteToApprove.isEmpty()){
        QuoteApprovalHandler.SubmitToApprovalProccess(quoteToApprove);
    }
}