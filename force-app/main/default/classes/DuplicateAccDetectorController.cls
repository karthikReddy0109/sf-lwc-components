public with sharing class DuplicateAccDetectorController {
    public class DuplicateAccountsResponse{
        @AuraEnabled public String name;
        @AuraEnabled public String industry;
        @AuraEnabled public String phone;
        @AuraEnabled public String id;
    }
    @AuraEnabled(cacheable=true)
    public static List<DuplicateAccountsResponse> getDuplicateAccounts(String searchText){
        try{
            List<List<sObject>> duplicateAccounts = [
                FIND :searchText IN NAME FIELDS RETURNING Account(Id, Name, Industry, Phone)
            ];
            List<DuplicateAccountsResponse> response = new List<DuplicateAccountsResponse>();
            if(!duplicateAccounts.isEmpty() && !duplicateAccounts[0].isEmpty()){
                List<Account> accounts = duplicateAccounts[0];
                for(Account acc : accounts){
                    DuplicateAccountsResponse responseItem = new DuplicateAccountsResponse();
                    responseItem.name = acc.Name;
                    responseItem.id = acc.Id;
                    responseItem.industry = acc.Industry;
                    responseItem.phone = acc.Phone;
                    response.add(responseItem);
                }
            }
            return response;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}