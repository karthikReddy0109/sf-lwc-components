public with sharing class SalesDashboardController {
    // Wrapper class for top rep response
    public class TopRepQuarterResponse{
        @AuraEnabled public String name{get; set;}
        @AuraEnabled public Decimal amount{get; set;}
    }
    // getTotalOpenPipeline()
    // getDealsClosingThisMonth()
    // getTopRepThisQuarter()
    // getAvgDealSize()
    @AuraEnabled(cacheable=true)
    public static Decimal getTotalOpenPipeline(){
        try{
            List<AggregateResult> ar = [
                SELECT SUM(Amount) totalAmount
                FROM Opportunity
                WHERE IsClosed = false
            ];
            Decimal totalOpenAmount = 0;
            if(!ar.isEmpty() && ar.get(0) != null){
                totalOpenAmount = (Decimal) ar.get(0).get('totalAmount');
            }
            return totalOpenAmount;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getDealsClosingThisMonth(){
        try{
            List<AggregateResult> ar = [
                SELECT COUNT(Id) totalCount
                FROM Opportunity
                WHERE IsClosed = false AND 
                CloseDate = THIS_MONTH
            ];
            Integer totalDeals = 0;
            if(!ar.isEmpty() && ar.get(0) != null){
                totalDeals = (Integer) ar.get(0).get('totalCount');
            }
            return totalDeals;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static TopRepQuarterResponse getTopRepThisQuarter(){
        try{
            List<AggregateResult> ar = [
                SELECT Owner.Name ownerName, SUM(Amount) totalAmount
                FROM Opportunity
                WHERE StageName = 'Closed Won' AND CloseDate = THIS_FISCAL_QUARTER
                GROUP BY OwnerId, Owner.Name
                ORDER BY SUM(Amount) DESC
                LIMIT 1
            ];

            // Build response
            TopRepQuarterResponse response = new TopRepQuarterResponse();
            if(!ar.isEmpty() && ar.get(0) != null){
                response.name = (String) ar.get(0).get('ownerName');
                response.amount = (Decimal) ar.get(0).get('totalAmount');
            }
            return response;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getAvgDealSize(){
        try{
            List<AggregateResult> ar = [
                SELECT AVG(Amount) totalAmount
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                AND CloseDate = THIS_YEAR
            ];
            Decimal totalDealSize = 0;
            if(!ar.isEmpty() && ar.get(0) != null){
                totalDealSize = (Decimal)ar.get(0).get('totalAmount');
            }
            return totalDealSize;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}