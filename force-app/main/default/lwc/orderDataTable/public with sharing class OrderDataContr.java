public with sharing class OrderDataController {

    // A method accessible to LWC
    @AuraEnabled
    public static List<OrderData> getOrders(String individualId) {

        // Step 1: Fetch data from the database
        List<sObject> orders = [
            SELECT ssot__Id__c, OrderID__c 
            FROM ecommerce_dataERP_OrderDetails_S3csv__dlm
            WHERE ssot__Id__c = :individualId
        ];

        // Step 2: Use a map to group and aggregate data
        Map<String, OrderData> dataMap = new Map<String, OrderData>();
        for (sObject order : orders) {
            String individual = (String) order.get('ssot__Id__c');
            String orderId = (String) order.get('OrderID__c');

            // Add individual to the map if not already present
            if (!dataMap.containsKey(individual)) {
                dataMap.put(individual, new OrderData(individual, new List<String>()));
            }
            // Append orderId to the list of orders
            dataMap.get(individual).orderIds.add(orderId);
        }

        // Step 3: Convert map into a list of results
        List<OrderData> results = new List<OrderData>();
        for (OrderData data : dataMap.values()) {
            data.totalOrders = data.orderIds.size(); // Calculate total orders
            results.add(data);
        }

        return results; // Return to LWC
    }

    // Helper class to structure the response
    public class OrderData {
        @AuraEnabled public String individualId;
        @AuraEnabled public Integer totalOrders;
        @AuraEnabled public List<String> orderIds;

        public OrderData(String individualId, List<String> orderIds) {
            this.individualId = individualId;
            this.orderIds = orderIds;
        }
    }
}
