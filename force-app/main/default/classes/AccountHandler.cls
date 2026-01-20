public class AccountHandler {
    
    public static void insertNewAccount(String accName) {
        try {
            Account acc = new Account(Name = accName);
            insert acc;
        } catch (Dmlexception e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
    }

    public static void createAccounts(Integer n) {
        List<Account> addAccounts = new List<Account>();
        
        for(Integer i=1; i<=n; i++) {
            Account a = new Account();
            a.Name = 'Account ' + i; 
            a.AccountNumber = 'A000' + i;
            addAccounts.add(a);
        }
        
        if(addAccounts.size() > 0) {
            insert addAccounts;
        }
    }
}