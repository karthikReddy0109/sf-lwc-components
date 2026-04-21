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
            insert accToUpdate;
        }
    }
}