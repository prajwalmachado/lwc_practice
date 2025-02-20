@isTest
public class InvoiceControllerTest {
    @testSetup
    static void setupTestData() {
        // Create Invoice records
        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer i = 1; i <= 3; i++) {
            invoices.add(new Invoice__c(Name = 'Invoice ' + i));
        }
        insert invoices;

        // Create Invoice Line Item records
        List<Invoice_Line_Item__c> lineItems = new List<Invoice_Line_Item__c>();
        for (Invoice__c inv : invoices) {
            for (Integer j = 1; j <= 15; j++) {
                lineItems.add(new Invoice_Line_Item__c(
                    Name = 'Invoice Line Item ' + inv.Name + '.' + j,
                    Invoice__c = inv.Id
                ));
            }
        }
        insert lineItems;
    }

    @isTest
    static void testGetInvoices() {
        // Test the getInvoices method
        List<Invoice__c> result = InvoiceController.getInvoices();
        System.assertNotEquals(null, result, 'Invoices should not be null');
        System.assertEquals(3, result.size(), 'Should return 3 invoices');
    }

    @isTest
    static void testGetMoreInvoiceLineItems() {
        
        Invoice__c testInvoice = [SELECT Id FROM Invoice__c LIMIT 1];

      
        List<Invoice_Line_Item__c> result = InvoiceController.getMoreInvoiceLineItems(testInvoice.Id, 0);
        System.assertNotEquals(null, result, 'Invoice Line Items should not be null');
        System.assertEquals(10, result.size(), 'Should return 10 line items for the first chunk');
    }
}
