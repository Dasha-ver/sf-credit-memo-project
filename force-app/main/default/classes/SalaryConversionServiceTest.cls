@IsTest
private class SalaryConversionServiceTest {

    @TestSetup
    static void setupTestData() {
        List<Employee__c> employeesToInsert = new List<Employee__c>();
        
        Department__c dept = new Department__c(
            Name = 'SF', 
            Calculation_Date__c = Date.today()
            );
        insert dept;
        
        Employee__c emp1 = new Employee__c(
            Name = 'Test One', 
            Salary__c = 1000,
            Department__c = dept.Id, 
            Salary_Date__c = Date.today()
        );
        
        Employee__c emp2 = new Employee__c(
            Name = 'Test Two', 
            Salary__c = 4000,
            Department__c = dept.Id,
            Salary_Date__c = Date.today()
        );

        if (UserInfo.isMultiCurrencyOrganization()) {
            String defaultIso = UserInfo.getDefaultCurrency();
            emp1.put('CurrencyIsoCode', defaultIso);
            emp2.put('CurrencyIsoCode', defaultIso);
        }

        employeesToInsert.add(emp1);
        employeesToInsert.add(emp2);

        insert employeesToInsert;
    }

    @IsTest
    static void testCalculateSalariesSuccessfully() {
        List<Employee__c> testEmployees = [
            SELECT Salary__c 
            FROM Employee__c];
        
        if (UserInfo.isMultiCurrencyOrganization()) {
            String query = 'SELECT Id, Salary__c, CurrencyIsoCode FROM Employee__c';
            testEmployees = Database.query(query);
        }

        SalaryConversionService.ConversionRequest req = new SalaryConversionService.ConversionRequest();
        req.employees = testEmployees;
        req.targetCurrencyIso = UserInfo.getDefaultCurrency(); 
        req.calculationDate = Date.today();

        List<SalaryConversionService.ConversionRequest> requests = new List<SalaryConversionService.ConversionRequest>{req};

        Test.startTest();
        List<Decimal> results = SalaryConversionService.calculate(requests);
        Test.stopTest();

        Assert.isNotNull(results, 'Method should return a non-null list of results');
        Assert.areEqual(1, results.size(), 'Size of returned list should match size of request list');
        Assert.areEqual(5000.0, results[0], 'Total salary calculated incorrectly');
    }

    @IsTest
    static void testCalculateWithEmptyEmployeesList() {
    
        SalaryConversionService.ConversionRequest req = new SalaryConversionService.ConversionRequest();
        req.employees = new List<Employee__c>(); 
        req.targetCurrencyIso = 'GBP';
        req.calculationDate = Date.today();

        List<SalaryConversionService.ConversionRequest> requests = new List<SalaryConversionService.ConversionRequest>{req};

        Test.startTest();
        List<Decimal> results = SalaryConversionService.calculate(requests);
        Test.stopTest();

        Assert.isNotNull(results, 'Method should return a non-null list of results');
        Assert.areEqual(1, results.size(), 'Should return one result for one request');
        Assert.areEqual(0.0, results[0], 'Sum should be 0.0 for empty employee list');
    }

    @IsTest
    static void testCalculateWithMissingCalculationDate() {
        
        SalaryConversionService.ConversionRequest req = new SalaryConversionService.ConversionRequest();
        List<SalaryConversionService.ConversionRequest> requests = new List<SalaryConversionService.ConversionRequest>{req, req};

        Test.startTest();
        List<Decimal> results = SalaryConversionService.calculate(requests);
        Test.stopTest();

        Assert.isNotNull(results, 'Method should return a non-null list of results');
        Assert.areEqual(2, results.size(), 'Should return two results for two empty requests');
        Assert.areEqual(0.0, results[0], 'Result should be 0.0 for early exit due to empty data');
        Assert.areEqual(0.0, results[1], 'Result should be 0.0 for early exit due to empty data');
    }
}