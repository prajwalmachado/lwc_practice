import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'; // Import CurrentPageReference
import getOrderDataByContactId from '@salesforce/apex/OrderDataController.getOrderDetailsByContactId';

export default class OrderDetailsTable extends LightningElement {
    @api recordId; // Automatically provided by Salesforce on Contact record page
    @track data = []; 
    @track error = ''; 

    columns = [
        { label: 'Subscription Key', fieldName: 'subscriptionKey', type: 'text' },
        { label: 'Order IDs', fieldName: 'orderIds', type: 'text' },
        { label: 'Product', fieldName: 'product', type: 'text' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        {
            label: 'Subscription Amount',
            fieldName: 'subscriptionAmount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' }
        },
        {
            label: 'Total Amount',
            fieldName: 'totalAmount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' }
        }
    ];

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.attributes) {
            this.recordId = currentPageReference.attributes.recordId;
            this.fetchOrderData(); // Fetch the data when recordId is available
        }
    }

    fetchOrderData() {
        if (this.recordId) {
            getOrderDataByContactId({ contactId: this.recordId })
                .then((result) => {
                    console.log(result);
                    if (result && result.length > 0) {
                        this.data = result.map((record) => ({
                            ...record,
                            orderIds: record.orderIds ? record.orderIds.join(', ') : ''
                        }));
                        this.error = '';
                    } else {
                        this.error = 'No order data found for this Contact.';
                        this.data = [];
                    }
                })
                .catch((error) => {
                    this.error = error.body ? error.body.message : 'An unexpected error occurred.';
                    this.data = [];
                });
        } else {
            this.error = 'Contact ID is missing or empty.';
        }
    }
}
