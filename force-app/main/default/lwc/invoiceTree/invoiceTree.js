import { LightningElement, track, wire } from 'lwc';
import getInvoices from '@salesforce/apex/InvoiceController.getInvoices';
import getMoreInvoiceLineItems from '@salesforce/apex/InvoiceController.getMoreInvoiceLineItems';

export default class InvoiceTree extends LightningElement {
    @track invoices = []; 

    @wire(getInvoices)
    wiredInvoices({ error, data }) {
        if (data) {
            this.invoices = data.map(invoice => ({
                ...invoice,
                lineItems: [], 
                isExpanded: false,
                canLoadMore: true,
                offset: 0          
            }));
        } else if (error) {
            console.error('Error fetching invoices:', error);
        }
    }

    toggleInvoice(event) {
        const invoiceId = event.currentTarget.dataset.id;
        const invoice = this.invoices.find(inv => inv.Id === invoiceId);

        if (invoice) {
            invoice.isExpanded = !invoice.isExpanded;

            if (invoice.isExpanded && invoice.lineItems.length === 0) {
                // Fetch line items if not loaded
                this.loadLineItems(invoiceId, 0);
            }
        }
    }

    loadMore(event) {
        const invoiceId = event.target.dataset.id;
        const invoice = this.invoices.find(inv => inv.Id === invoiceId);

        if (invoice) {
            this.loadLineItems(invoiceId, invoice.offset);
        }
    }

    loadLineItems(invoiceId, offset) {
        getMoreInvoiceLineItems({ invoiceId, offset })
            .then(data => {
                const invoice = this.invoices.find(inv => inv.Id === invoiceId);
                if (invoice) {
                    invoice.lineItems = [...invoice.lineItems, ...data];
                    invoice.offset += 10;

                    // If fewer than 10 items are returned
                    if (data.length < 10) {
                        invoice.canLoadMore = false;
                    }
                }
            })
            .catch(error => console.error('Error loading line items:', error));
    }
}
