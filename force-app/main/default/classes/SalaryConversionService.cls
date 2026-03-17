public with sharing class SalaryConversionService {

    public class ConversionRequest {
        @InvocableVariable(required=true label='Employees List')
        public List<Employee__c> employees;

        @InvocableVariable(required=true label='Target Currency (Department)')
        public String targetCurrencyIso;

        @InvocableVariable(required=true label='Calculation Date')
        public Date calculationDate;
    }

    private static String corporateCurrencyIso {
        get {
            if (corporateCurrencyIso == null) {
                if (UserInfo.isMultiCurrencyOrganization()) {
                    SObject ct = Database.query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true LIMIT 1');
                    corporateCurrencyIso = (String)ct.get('IsoCode');
                } else {
                    corporateCurrencyIso = UserInfo.getDefaultCurrency();
                }
            }
            return corporateCurrencyIso;
        }
        set;
    }

    @InvocableMethod(label='Convert & Rollup Salaries' description='Converts employee salaries using Dated Exchange Rates')
    public static List<Decimal> calculate(List<ConversionRequest> requests) {
        List<Decimal> results = new List<Decimal>();        
        Date minDate;
        Date maxDate;
        Set<String> neededIsos = new Set<String>();

        for (ConversionRequest req : requests) {
            if (req.calculationDate != null) {
                if (minDate == null || req.calculationDate < minDate){
                    minDate = req.calculationDate;
                }
                if (maxDate == null || req.calculationDate > maxDate) {
                    maxDate = req.calculationDate;
                }
            }
            if (String.isNotBlank(req.targetCurrencyIso)) {
                neededIsos.add(req.targetCurrencyIso);
            }
            if (req.employees != null) {
                for (Employee__c emp : req.employees) {
                    String empCurrency = (String)emp.get('CurrencyIsoCode');
                    if (String.isNotBlank(empCurrency)) {
                        neededIsos.add(empCurrency);
                    }
                }
            }
        }

        if (minDate == null || neededIsos.isEmpty()) {
            for (Integer i = 0; i < requests.size(); i++){
                 results.add(0.0);
            }
            return results;
        }

        List<DatedConversionRate> rates = [
            SELECT IsoCode, ConversionRate, StartDate, NextStartDate 
            FROM DatedConversionRate 
            WHERE IsoCode IN :neededIsos 
              AND StartDate <= :maxDate 
              AND NextStartDate > :minDate
        ];

        Map<String, List<DatedConversionRate>> ratesByIso = new Map<String, List<DatedConversionRate>>();
        for (DatedConversionRate rate : rates) {
            if (!ratesByIso.containsKey(rate.IsoCode)) {
                ratesByIso.put(rate.IsoCode, new List<DatedConversionRate>());
            }
            ratesByIso.get(rate.IsoCode).add(rate);
        }

        for (ConversionRequest req : requests) {
            Decimal totalDepartmentSalary = 0.0;
            Decimal targetRate = getRate(ratesByIso, req.targetCurrencyIso, req.calculationDate);

            if (req.employees != null && !req.employees.isEmpty()) {
                for (Employee__c emp : req.employees) {
                    if (emp.Salary__c != null) {
                        String empCurrency = (String)emp.get('CurrencyIsoCode');
                        Decimal empRate = getRate(ratesByIso, empCurrency, req.calculationDate);
                        
                        if (empRate != null && empRate > 0) {
                            Decimal amountInCorporate = emp.Salary__c / empRate;
                            totalDepartmentSalary += amountInCorporate * targetRate;
                        }
                    }
                }
            }
            results.add(totalDepartmentSalary);
        }

        return results;
    }

    private static Decimal getRate(Map<String, List<DatedConversionRate>> ratesMap, String iso, Date calcDate) {
        if (String.isBlank(iso) || iso == corporateCurrencyIso) {
            return 1.0; 
        }
        
        if (ratesMap.containsKey(iso)) {
            for (DatedConversionRate r : ratesMap.get(iso)) {
                if (r.StartDate <= calcDate && r.NextStartDate > calcDate) {
                    return r.ConversionRate;
                }
            }
        }
        
        return 1.0; 
    }
}