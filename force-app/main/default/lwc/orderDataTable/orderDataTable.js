import { LightningElement, track } from "lwc";
// import getOrderData from "@salesforce/apex/OrderDataController.getOrderData";

export default class OrderDataTable extends LightningElement {
    @track unifiedRecordId = ""; // UnifiedRecordId entered by the user
    @track data = []; // Data fetched from the server
    @track error = ""; // Error messages

    // Columns for the datatable
    columns = [
        { label: "Subscription Key", fieldName: "subscriptionKey", type: "text" },
        {
            label: "Order IDs",
            fieldName: "orderIds",
            type: "text",
            cellAttributes: {
                class: "slds-truncate"
            }
        },
        {
            label: "Total Amount",
            fieldName: "totalAmount",
            type: "currency",
            typeAttributes: { currencyCode: "USD" }
        },
        {
            label: "Product Name",
            fieldName: "productName",
            type: "text"
        },
        {
            label: "Product",
            fieldName: "product",
            type: "text"
        },
        {
            label: "Subscription Amount",
            fieldName: "subscriptionAmount",
            type: "currency",
            typeAttributes: { currencyCode: "USD" }
        }
    ];

    // Handle input change for UnifiedRecordId
    handleInputChange(event) {
        this.unifiedRecordId = event.target.value;
    }

    // Fetch orders based on UnifiedRecordId
    fetchOrders() {
        // Validate input
        if (!this.unifiedRecordId) {
            this.error = "Unified Record ID cannot be empty.";
            this.data = [];
            return;
        }

        // Call Apex method
        getOrderData({ unifiedRecordId: this.unifiedRecordId })
            .then((result) => {
                // Map and format the orderIds into a comma-separated string for display
                this.data = result.map((record) => ({
                    ...record,
                    orderIds: record.orderIds.join(", ") // Convert list to string
                }));
                this.error = "";
            })
            .catch((error) => {
                // Handle errors
                this.error = error.body ? error.body.message : "An unexpected error occurred.";
                this.data = [];
            });
    }
}
