public class myController {
    public String accName{get; set;}
    public String accNumber{get; set;}
    public String accRating{get; set;}
    public String accIndustry{get; set;}
    public String conLastName {get; set;}
    
    public PageReference addAccountContact(){
        Account acc = new Account();
        acc.Name = 'Mr. ' + accName;
        acc.Industry = accIndustry;
        acc.Rating = accRating;
        acc.AccountNumber = accNumber;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = conLastName;
        con.AccountId = acc.Id;
        insert con;
        
        PageReference acctPage = new ApexPages.StandardController(acc).view();
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    public List<Account> getAllAccounts(){
        List<Account> accList = [SELECT Name, Rating, Industry FROM Account WHERE Rating = 'Hot'];
        return accList;
    }
}