public with sharing class GlobalSearchController {
    public class SearchResult{
        @AuraEnabled public List<Account> accounts {get; set;}
        @AuraEnabled public List<Contact> contacts {get; set;}
        @AuraEnabled public List<Lead> leads {get; set;}

    }
    @AuraEnabled
    public static searchResult getSearchResults(String searchTerm){
        if(String.isNotBlank(searchTerm) && searchTerm.length() > 1){
            try{
                String searchQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' + 
                'Account(Id, Name), ' + 'Contact(Id, FirstName, LastName), ' + 'Lead(Id, FirstName, LastName)';
                List<List<sObject>> results = Search.query(searchQuery);
                SearchResult sr = new SearchResult();
                sr.accounts = results[0];
                sr.contacts = results[1];
                sr.leads = results[2];
                return sr;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return new SearchResult();
    }
}