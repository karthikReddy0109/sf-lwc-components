public with sharing class AccountSummaryController {
    public class AccountSummary{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String industry {get;set;}
        @AuraEnabled public Decimal annualRevenue {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public Integer openOppcount {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static AccountSummary getAccountSummary(String recordId){
        Id accountId = (Id)recordId;
        try{
            Account account = [
                SELECT Id,
                Name,
                Industry,
                AnnualRevenue,
                Phone, 
                (SELECT Id, StageName
                FROM Opportunities
                WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost')
                FROM Account
                WHERE Id =: recordId
                LIMIT 1
            ];
            AccountSummary response = new AccountSummary();
            response.name = account.Name;
            response.industry = account.Industry;
            response.annualRevenue = account.AnnualRevenue;
            response.phone = account.Phone;
            response.openOppcount = account.Opportunities.size();
            return response;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}