public class SLABreachMonitoringBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT Id, SLA_Breach_Time__c, Is_Breached__c ' +
            'FROM SLA_Tracking__c ' +
            'WHERE Is_Breached__c = false AND Service_Request__r.Status__c != \'Closed\''
        );
    }
    
    public void execute(Database.BatchableContext bc, List<SLA_Tracking__c> scope){
        List<SLA_Tracking__c> recordsToUpdate = new List<SLA_Tracking__c>();
        for(SLA_Tracking__c sla : scope){
            if(system.now() > sla.SLA_Breach_Time__c){
                sla.Is_Breached__c = true;
                recordsToUpdate.add(sla);
            }
        }
        
        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}