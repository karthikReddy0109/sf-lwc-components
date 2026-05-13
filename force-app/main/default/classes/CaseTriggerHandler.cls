public with sharing class CaseTriggerHandler {
    public static void autoAssignCaseToQueue(List<Case> caseList){
        Map<String, String> caseToQueueMap = new Map<String, String>();
        for(Case_Queue_Mapping__mdt m : [SELECT Case_Type__c, Queue_Developer_Name__c FROM Case_Queue_Mapping__mdt]){
            caseToQueueMap.put(m.Case_Type__c, m.Queue_Developer_Name__c);
        }
        Map<String, Id> developerToQueueIdMap = new Map<String, Id>();
        for(Group g : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN: caseToQueueMap.values()]){
            developerToQueueIdMap.put(g.DeveloperName, g.Id);
        }
        for(Case c : caseList){
            String devName = caseToQueueMap.containsKey(c.Type) ? caseToQueueMap.get(c.Type) : caseToQueueMap.get('Default');
            Id queueId = developerToQueueIdMap.get(devName);
            if(queueId != null){
                c.OwnerId = queueId;
            }
        }
    }
}