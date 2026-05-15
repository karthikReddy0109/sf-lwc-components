public with sharing class OpportunityTriggerHandler {
    public static void oppRollupOnAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        // 1. Collect Id's
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }
            if(oppOldMap != null && oppOldMap.containsKey(opp.Id)){
                Opportunity oldOpp = oppOldMap.get(opp.Id);
                if(oldOpp.AccountId != null){
                    accountIdSet.add(oldOpp.AccountId);
                }
            }
        }

        if(accountIdSet.isEmpty()) return;

        Map<Id, Decimal> accToAmountMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [SELECT AccountId, SUM(Amount) totalAmount FROM Opportunity WHERE AccountId IN: accountIdSet GROUP BY AccountId]){
            accToAmountMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalAmount'));
        }

        List<Account> accToUpdate = new List<Account>();
        for(Id accId : accountIdSet){
            Decimal total = accToAmountMap.containsKey(accId) ? accToAmountMap.get(accId) : 0;
            accToUpdate.add(new Account(
                Id = accId,
                Total_Opp_Amount__c = total
            ));
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
    
    public static void salesRepNotificationOnBigDeal(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        List<Opportunity> qualifiedOpps = new List<Opportunity>();
        Set<Id> ownerIds = new Set<Id>();
        List<Messaging.singleEmailMessage> emailList = new List<Messaging.singleEmailMessage>();
        for(Opportunity opp : oppList){
            String oldStage = oppOldMap != null && oppOldMap.containsKey(opp.Id) ? oppOldMap.get(opp.Id).stageName : null;
            Boolean isClosedWon = oldStage != 'Closed Won' && opp.StageName == 'Closed Won';
            if(opp.Amount >= 10000 && isClosedWon){
                qualifiedOpps.add(opp);
                ownerIds.add(opp.OwnerId);
            }
        }
        if(qualifiedOpps.isEmpty()) return;
        Map<Id, User> userMap = new Map<Id, User>([SELECT Email FROM User WHERE Id IN: ownerIds]);
        for(Opportunity opp : qualifiedOpps){
            Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
            String ownerEmail = userMap.get(opp.ownerId).Email;
            mail.setToAddresses(new String[]{ownerEmail});
            mail.setSubject('Congratulation on Big Deal : ' + opp.Name);
            mail.setPlainTextBody('Congratulations for winning a deal worth ' + opp.Amount);
            emailList.add(mail);
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
            System.debug('Email sent successfully');
        }
    }
}