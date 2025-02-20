public with sharing class OrderDataController{
    public static List<OrderData> getOrders(String individualId) {
    //Query the parent object
    // List<sObject> individuals = [
    //     SELECT Id, ssot__Id__c
    //     FROM ssot__Individual__dlm
    //     WHERE ssot__Id__c = :individualId
    // ];

     List<OrderDetailsWrapper> orderDetails = new List<OrderDetailsWrapper>();

     
     List<ssot__Individual__dlm> individualRecords = [ 
         SELECT ssot__Id__c, 
            (SELECT OrderID__c, Product__c FROM ecommerce_dataERP_OrderDetails_S3csv__dlm__r) 
         FROM ssot__Individual__dlm 
         WHERE ssot__Id__c = :individualId
     ];
    }
}

