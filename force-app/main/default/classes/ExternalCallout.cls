public class ExternalCallout {
    public static void makeCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String soqlQuery = EncodingUtil.urlEncode('SELECT Id, Name FROM Account', 'UTF-8');
        request.setEndpoint('callout:Agentforce_Org/services/data/v60.0/query?q='+ soqlQuery);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = Http.send(request);
        if(response.getStatusCode() == 200){
            System.debug('API call successfull');
            System.debug('----------------RESPONSE-----------------');
            System.debug(response.getBody());
        }else{
            System.debug('API call failed with status code' + response.getStatusCode());
        }
    }
}