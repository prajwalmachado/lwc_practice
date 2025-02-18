@RestResource(urlMapping='/insertCustomersV2/')
global with sharing class CustomerData {

    @HttpPost
    global static ResponseWrapper insertCustomers(String requestBody) { 
        ResponseWrapper response = new ResponseWrapper();

        try {
            System.debug('Incoming JSON: ' + requestBody);

            // Deserialize request JSON into the wrapper class
            CustomerRequestWrapper requestData = (CustomerRequestWrapper) JSON.deserialize(requestBody, CustomerRequestWrapper.class);

            List<Customer__c> customerRecords = new List<Customer__c>();

            // Loop through each customer and create a record
            for (CustomerWrapper cust : requestData.CustomerDetails) {
                Customer__c newCustomer = new Customer__c();
                newCustomer.Name = cust.Name;
                newCustomer.Email__c = cust.email;
                newCustomer.Phone__c = cust.phone;
                newCustomer.City__c = requestData.city; // Common field
                newCustomer.Status__c = requestData.Status; // Common field
                newCustomer.Source__c = requestData.Source; // Common field
                customerRecords.add(newCustomer);
            }

            // Bulk insert customers
            if (!customerRecords.isEmpty()) {
                insert customerRecords;
                response.success = true;
                response.message = 'Inserted ' + customerRecords.size() + ' records successfully!';
                response.recordCount = customerRecords.size();
            } else {
                response.success = false;
                response.message = 'No records to insert.';
                response.recordCount = 0;
            }

        } catch (Exception e) {
            response.success = false;
            response.message = 'Error: ' + e.getMessage();
            response.recordCount = 0;
        }

        return response;
    }

    // Wrapper Class for JSON Structure
    global class CustomerRequestWrapper {
        public String city;
        public String Status;
        public String Source;
        public List<CustomerWrapper> CustomerDetails;
    }

    global class CustomerWrapper {
        public String Name;
        public String email;
        public String phone;
    }

    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public Integer recordCount;
    }
}
