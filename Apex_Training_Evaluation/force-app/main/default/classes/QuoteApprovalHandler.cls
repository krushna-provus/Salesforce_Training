public with sharing class QuoteApprovalHandler {
    public static void SubmitToApprovalProccess(List<Quote> quotesToProcess){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        for(Quote q : quotesToProcess){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Fired from Apex code.');
            req.setObjectId(q.Id);
            req.setProcessDefinitionNameOrId('Manager_Approval');
            
            requests.add(req);
        }
        
        if(!requests.isEmpty()){
            Approval.ProcessResult[] results = Approval.process(requests);
            
        }
    }
}