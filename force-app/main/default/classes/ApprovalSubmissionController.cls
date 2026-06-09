public with sharing class ApprovalSubmissionController {
    public class PurchaseOrderDetailsResponse{
        @AuraEnabled public String name;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String createdBy;
        @AuraEnabled public Boolean isAlreadyPending;
    }
    public class ApprovalResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }
    @AuraEnabled(cacheable=true)
    public static PurchaseOrderDetailsResponse getPODetails(String recordId){
        try{
            Puchase_Order__c purchaseOrder = [
                SELECT Name, Amount__c, Status__c, CreatedDate, CreatedBy.Name
                FROM Puchase_Order__c
                WHERE Id =: recordId
            ];

            List<ProcessInstance> pending = [
                SELECT Id 
                FROM ProcessInstance 
                WHERE TargetObjectId =: recordId
                AND Status = 'Pending'
            ];

            PurchaseOrderDetailsResponse response = new PurchaseOrderDetailsResponse();
            response.name = purchaseOrder.Name;
            response.amount = purchaseOrder.Amount__c;
            response.status = purchaseOrder.Status__c;
            response.createdBy = purchaseOrder.CreatedBy.Name;
            response.createdDate = purchaseOrder.CreatedDate;
            response.isAlreadyPending = !pending.isEmpty();

            return response;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ApprovalResponse submitRecordForApproval(String recordId, String comments){
        ApprovalResponse response = new ApprovalResponse();
        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(recordId);
            req.setComments(comments);
            Approval.ProcessResult result = Approval.process(req);
            if(result.isSuccess()){
                response.success = true;
                response.message = 'Record Submitted Successfully';
            }else{
                response.message = result.getErrors()[0].getMessage();
            }
            return response;
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
    }
}