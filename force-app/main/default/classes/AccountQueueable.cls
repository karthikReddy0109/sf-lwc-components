public with sharing class AccountQueueable implements Queueable, Database.AllowsCallouts{
    List<Account> accountList;
    public AccountQueueable(List<Account> accountList) {
        this.accountList = accountList;
    }

    public void execute(QueueableContext qc){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://webhook.site/c9af1b4e-04d5-48db-9b79-09943d26caa9');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        Map<String, String> payload = new Map<String, String>();
        for(Account acc : accountList){
            payload.put('accountId', acc.Id);
            payload.put('AccountName', acc.Name);
        }
        String body = JSON.serialize(payload);
        request.setBody(body);
        HttpResponse response = Http.send(request);
        if(response.getStatusCode() == 200){
            System.debug('API POSTED successfully');
        }else{
            System.debug('API call failed');
        }
    }
}