public with sharing class AccountTriggerHandler {
    public static void createContact(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.AccountId = acc.Id;
            conList.add(con);
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
}