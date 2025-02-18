public with sharing class OrderDataController {

    @AuraEnabled
    public static List<OrderData> getOrderDetailsByContactId(String contactId) {
        if (String.isEmpty(contactId)) {
            throw new AuraHandledException('Contact ID is required.');
        }

        // Debug the input Contact ID
        System.debug('Contact ID: ' + contactId);

        // Step 1: Fetch UnifiedIndividualID using Contact ID
        String unifiedRecordId = getUnifiedIndividualIdByContactId(contactId);
        if (String.isEmpty(unifiedRecordId)) {
            throw new AuraHandledException('No UnifiedIndividualID found for the provided Contact ID.');
        }

        // Step 2: Fetch order data using UnifiedIndividualID
        return getOrderDataByUnifiedId(unifiedRecordId);
    }

    private static String getUnifiedIndividualIdByContactId(String contactId) {
        if (String.isEmpty(contactId)) {
            throw new AuraHandledException('Contact ID cannot be null or empty.');
        }

        // Query UnifiedIndividualID for Contact ID
        List<UnifiedLinkssotIndividualDefa__dlm> records = [
            SELECT UnifiedRecordId__c
            FROM UnifiedLinkssotIndividualDefa__dlm
            WHERE SourceRecordId__c = :contactId
            LIMIT 1
        ];

        if (records.isEmpty()) {
            return null;
        }

        return records[0].UnifiedRecordId__c;
    }

    private static List<OrderData> getOrderDataByUnifiedId(String unifiedRecordId) {
        if (String.isEmpty(unifiedRecordId)) {
            throw new AuraHandledException('Unified Record ID cannot be null or empty.');
        }

        // Fetch subscription keys based on Unified Record ID
        List<String> subscriptionKeys = new List<String>();
        for (UnifiedLinkssotIndividualDefa__dlm record : [
            SELECT SourceRecordId__c
            FROM UnifiedLinkssotIndividualDefa__dlm
            WHERE UnifiedRecordId__c = :unifiedRecordId
        ]) {
            subscriptionKeys.add(record.SourceRecordId__c);
        }

        // Fetch order data
        Map<String, OrderData> orderDataMap = new Map<String, OrderData>();
        for (ecommerce_dataERP_OrderDetails_S3csv__dlm order : [
            SELECT Subscription__c, OrderID__c, Product_Name__c, Product__c, Total_Amount_Paid__c, Subscription_Amount__c
            FROM ecommerce_dataERP_OrderDetails_S3csv__dlm
            WHERE Subscription__c IN :subscriptionKeys
        ]) {
            if (!orderDataMap.containsKey(order.Subscription__c)) {
                orderDataMap.put(order.Subscription__c, new OrderData(
                    order.Subscription__c, new List<String>(), 0, null, null, 0
                ));
            }

            OrderData data = orderDataMap.get(order.Subscription__c);
            data.orderIds.add(order.OrderID__c);
            data.totalAmount += order.Total_Amount_Paid__c;
            data.productName = order.Product_Name__c;
            data.product = order.Product__c;
            data.subscriptionAmount += order.Subscription_Amount__c;
        }

        return orderDataMap.values();
    }

    public class OrderData {
        @AuraEnabled public String subscriptionKey { get; set; }
        @AuraEnabled public List<String> orderIds { get; set; }
        @AuraEnabled public Decimal totalAmount { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String product { get; set; }
        @AuraEnabled public Decimal subscriptionAmount { get; set; }

        public OrderData(String subscriptionKey, List<String> orderIds, Decimal totalAmount, String productName, String product, Decimal subscriptionAmount) {
            this.subscriptionKey = subscriptionKey;
            this.orderIds = orderIds;
            this.totalAmount = totalAmount;
            this.productName = productName;
            this.product = product;
            this.subscriptionAmount = subscriptionAmount;
        }
    }
}