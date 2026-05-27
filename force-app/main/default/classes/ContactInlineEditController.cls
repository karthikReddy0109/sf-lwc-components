public with sharing class ContactInlineEditController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String recordId){
        Id accId = Id.valueOf(recordId);
        return [SELECT Id, Name, Email, Phone, Title
        FROM Contact
        WHERE AccountId = :accId];
    }

    @AuraEnabled
    public static void updateContacts(List<sObject> contacts){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(sObject obj : contacts){
            contactsToUpdate.add((Contact) obj);
        }
        try{
            update contactsToUpdate;
        } catch(Exception e){
            throw new AuraHandledException('Error updating contacts: ' + e.getMessage());
        }
    }
}