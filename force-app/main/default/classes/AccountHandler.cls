public class AccountHandler {
    public static void insertAccount(Integer count) {
    	
        List <Account> addAccounts = new List <Account> ();
        
        Integer N = 0;
        
        while (N < count){
            addAccounts.add(new Account (
             Name = 'Acme Inc ' + N,
                    AccountNumber = 'A000' + N
            )
          );
            N++;
                
        }
        
        insert addAccounts;
    }

    public static void createAccounts(Integer n) {
        List<Account> addAccounts = new List<Account>();
        for(Integer i=0; i<n; i++) {
            addAccounts.add(new Account(Name='Test Account ' + i));
        }
        insert addAccounts;
    }
}