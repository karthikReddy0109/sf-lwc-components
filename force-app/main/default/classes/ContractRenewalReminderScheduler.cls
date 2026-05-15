public class ContractRenewalReminderScheduler implements Schedulable {
    public void execute(schedulableContext sc){
        // Retrieve records where end date in next 60 days
        List<Contract> contractRecords = [SELECT Id, AccountId, Account.OwnerId, ContractNumber
                                          FROM Contract
                                          WHERE EndDate = NEXT_N_DAYS:60 AND Renewal_Reminder_Sent__c = FALSE];
        if(contractRecords.isEmpty()) return;
        Set<Id> ownerIdSet = new Set<Id>();
        for(Contract con : contractRecords){
            if(con.Account.OwnerId != null){
                ownerIdSet.add(con.Account.OwnerId);
            }
        }
        Map<Id, String> userToEmailMap = new Map<Id, String>();
        for(User u : [SELECT Id, Email FROM User WHERE Id IN: ownerIdSet]){
            userToEmailMap.put(u.Id, u.Email);
        }
        
        // Create Email List
        List<Messaging.singleEmailMessage> mailList = new List<Messaging.singleEmailMessage>();
        
        //create email
        for(Contract con : contractRecords){
            if(userToEmailMap.containsKey(con.Account.OwnerId)){
                Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
                mail.setToAddresses(new String[]{userToEmailMap.get(con.Account.OwnerId)});
                mail.setSubject('Contract ' + con.ContractNumber + ' Is Expiring');
                mail.setPlainTextBody('Please initiate a renewal');
                mailList.add(mail);
                con.Renewal_Reminder_Sent__c = True;
            }
        }
        
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList);
            update contractRecords;
        }
    }
}