trigger LeadTrigger on Lead (before insert) {
    LeadTriggerHandler.preventDuplicateLeadsByEmail(trigger.new);
}