public with sharing class LeadTriggerHandler {
    public static void preventDuplicateLeadsByEmail(List<Lead> leadList){
        // 1. Collect emails from incoming records
        Set<String> incomingEmailSet = new Set<String>();
        for(Lead ld : leadList){
            if(ld.Email != null){
                incomingEmailSet.add(ld.Email.toLowerCase());
            }
        }

        Map<String, Id> emailToLeadMap = new Map<String, Id>();
        for(Lead ld : [SELECT Id, Email FROM Lead WHERE Email IN :incomingEmailSet]){
            emailToLeadMap.put(ld.Email.toLowerCase(), ld.Id);
        }

        Set<String> seenEmails = new Set<String>();
        for(Lead ld : leadList){
            if(ld.Email != null){
                // Check if email already exists
                String emailLowerCase = ld.Email.toLowerCase();
                if(emailToLeadMap.containsKey(emailLowerCase) || seenEmails.contains(emailLowerCase)){
                    ld.addError('Lead with same Email already exists');
                }else{
                    seenEmails.add(emailLowerCase);
                }
            }
        }
    }
}