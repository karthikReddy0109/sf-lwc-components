trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    if(trigger.isUpdate){
        if(trigger.isBefore || trigger.isUpdate){
            ContactTriggerHandler.handleContactUpdate(trigger.new);
        }
    }
}