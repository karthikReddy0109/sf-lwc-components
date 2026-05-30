public with sharing class ApprovalActionController {
    private static Id currentUserId = UserInfo.getUserId();
    public class ApprovalDetailsResponse{
        @AuraEnabled public String currentStatus{get;set;}
        @AuraEnabled public String currentApprover{get;set;}
        @AuraEnabled public List<ProcessInstanceStep> previousSteps{get;set;}
        @AuraEnabled public Boolean isCurrentApprover{get;set;}
    }
    @AuraEnabled
    public static void processApproval(String recordId, Boolean isApproved){
        String actionFromLwc = isApproved ? 'Approve' : 'Reject';
        try{
            ProcessInstanceWorkitem workItem = [
                SELECT Id
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId = :recordId
                AND ActorId = :currentUserId
                LIMIT 1
            ];
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setWorkitemId(workItem.Id);
            request.setAction(actionFromLwc); // or 'Reject'
            request.setComments('Approved via LWC component');
            Approval.ProcessResult result = Approval.process(request);
            System.debug('Record Approved');
        }catch(Exception e){
            System.debug('Record Approval Failed');
            throw new AuraHandledException(e.getMessage());
        }
        
    }
        @AuraEnabled(cacheable=true)
        public static ApprovalDetailsResponse getApprovalDetails(String recordId){
            List<ProcessInstance> instances = [
                SELECT Id, Status,
                    (
                        SELECT Id,
                            ActorId,
                            Actor.Name
                        FROM Workitems
                    )
                FROM ProcessInstance
                WHERE TargetObjectId = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            List<ProcessInstanceStep> steps = [SELECT Id, ActorId, Actor.Name, StepStatus, ProcessInstance.SubmittedById, 
            ProcessInstance.Status,
            CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =: recordId];
            ApprovalDetailsResponse response = new ApprovalDetailsResponse();
            if(!instances.isEmpty() && !instances[0].Workitems.isEmpty()){
                response.isCurrentApprover = currentUserId == instances[0].Workitems[0].ActorId;
                response.currentApprover = instances[0].Workitems[0].Actor.Name;
            }else {
                response.currentApprover = 'No Pending Approver';
                response.isCurrentApprover = false;
            }
            response.previousSteps = steps;
            if(instances.isEmpty()){
                response.currentStatus = 'Not Submitted';
                response.isCurrentApprover = false;
                return response;
            }
            return response;
        }
}