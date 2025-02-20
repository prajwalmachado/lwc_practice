@RestResource(urlMapping='/insertProducts/')
global with sharing class ExternalAPI {

    @HttpPost
    global static ResponseWrapper insertProductsFromAPI() {
        ResponseWrapper res = new ResponseWrapper(); 
        try {
            String externalResponse = callExternalAPI();
            System.debug('++++++++++++++ Response ++++++++++++++' + externalResponse);

            //List<ProductWrapper> products = (List<ProductWrapper>) JSON.deserialize(externalResponse, List<ProductWrapper>.class);
            List<ProductWrapper> products = 
            (List<ProductWrapper>) JSON.deserialize(externalResponse, List<ProductWrapper>.class);

            System.debug('++++++++++++++ Products ++++++++++++++' + products);
            List<Product__c> productRecords = new List<Product__c>();

            for (ProductWrapper prod : products) {
                Product__c newProduct = new Product__c();
                newProduct.Product_ID__c = prod.id;
                newProduct.Name = prod.name;
                newProduct.Data_JSON__c = prod.data; // Store JSON data
                productRecords.add(newProduct);
            }

            if (!productRecords.isEmpty()) {
                Database.insert(productRecords, false); // Use Database.insert for partial success handling
                res.success = true;
                res.message = 'Inserted ' + productRecords.size() + ' records successfully!';
                res.recordCount = productRecords.size();
            } else {
              res.success = true;
              res.message = 'No records to insert.';
              res.recordCount = 0;
            }

        } catch (Exception e) {
            res.success = false;
            res.message = 'Error: ' + e.getMessage();
            res.recordCount = 0; // Set recordCount to 0 in case of error
        }

        return res;
    }

    public static String callExternalAPI() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.restful-api.dev/objects/');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        try {
          HttpResponse response = http.send(request);

          if (response.getStatusCode() == 200) {
              return response.getBody();
          } else {
              throw new CalloutException('API call failed: ' + response.getStatusCode() + ' - ' + response.getStatus()); // Include status message
          }
        } catch (System.CalloutException ex) {
          throw new CalloutException('API call failed: ' + ex.getMessage()); // Re-throw the exception to maintain context
        }
    }

    global class ProductWrapper {
        public String id;
        public String name;
        public String data;
    }

    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public Integer recordCount;
    }
}

