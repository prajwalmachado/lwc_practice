@RestResource(urlMapping='/insertCustomersV3/')
global with sharing class CustomerDataHandler {

    // Wrapper class to match JSON structure
    global class RequestWrapper {
        public String city;
        public String Status;
        public String Source;
        public List<CustomerDetails> CustomerDetails;
    }

    global class CustomerDetails {
        public String Name;
        public String email;
        public String phone;
    }

    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public Integer recordCount;
    }

    @HttpPost
    global static ResponseWrapper insertCustomers() {
        ResponseWrapper res = new ResponseWrapper();
        
        try {
            
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            RequestWrapper inputData = (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);
            
            List<Customer__c> customerRecords = new List<Customer__c>();

            for (CustomerDetails cust : inputData.CustomerDetails) {
                Customer__c newCustomer = new Customer__c();
                newCustomer.Name = cust.Name;
                newCustomer.Email__c = cust.email;
                newCustomer.Phone__c = cust.phone;
                newCustomer.City__c = inputData.city;
                newCustomer.Status__c = inputData.Status;
                newCustomer.Source__c = inputData.Source;
                
                customerRecords.add(newCustomer);
            }

            
            if (!customerRecords.isEmpty()) {
                insert customerRecords;
                res.success = true;
                res.message = 'Inserted ' + customerRecords.size() + ' records successfully!';
                res.recordCount = customerRecords.size();
            } else {
                res.success = false;
                res.message = 'No records to insert.';
                res.recordCount = 0;
            }

        } catch (Exception e) {
            res.success = false;
            res.message = 'Error: ' + e.getMessage();
            res.recordCount = 0;
        }

        return res;
    }
}
