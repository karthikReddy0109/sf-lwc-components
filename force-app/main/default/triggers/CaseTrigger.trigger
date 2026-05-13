trigger CaseTrigger on Case (before insert) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            CaseTriggerHandler.autoAssignCaseToQueue(Trigger.new);
        }
    }
}