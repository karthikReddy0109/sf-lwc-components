trigger OpportunityTrigger on Opportunity (after insert, after update, after delete) {
    if(trigger.isUpdate || trigger.isInsert){
        OpportunityTriggerHandler.oppRollupOnAccount(trigger.new, trigger.oldMap);
        OpportunityTriggerHandler.salesRepNotificationOnBigDeal(trigger.new, trigger.oldMap);
    }
    if(trigger.isDelete){
        OpportunityTriggerHandler.oppRollupOnAccount(trigger.old, trigger.oldMap);
    }
}