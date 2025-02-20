// import { createElement } from 'lwc';
import InvoiceTree from 'c/invoiceTree';
import getInvoices from '@salesforce/apex/InvoiceController.getInvoices';
import getMoreInvoiceLineItems from '@salesforce/apex/InvoiceController.getMoreInvoiceLineItems';

// Mock Apex Methods
jest.mock('@salesforce/apex/InvoiceController.getInvoices', () => ({
    default: jest.fn(),
}), { virtual: true });

jest.mock('@salesforce/apex/InvoiceController.getMoreInvoiceLineItems', () => ({
    default: jest.fn(),
}), { virtual: true });

const MOCK_INVOICES = [
    { Id: '1', Name: 'Invoice 1', lineItems: [], isExpanded: false, canLoadMore: true, offset: 0 },
    { Id: '2', Name: 'Invoice 2', lineItems: [], isExpanded: false, canLoadMore: true, offset: 0 },
];

const MOCK_LINE_ITEMS = [
    { Id: '1.1', Name: 'Invoice Line Item 1.1' },
    { Id: '1.2', Name: 'Invoice Line Item 1.2' },
];

describe('c-invoice-tree', () => {
    afterEach(() => {
        // Cleanup DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders invoices fetched from Apex', async () => {
        getInvoices.mockResolvedValue(MOCK_INVOICES);

        const element = createElement('c-invoice-tree', {
            is: InvoiceTree
        });
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await Promise.resolve();

        const invoiceItems = element.shadowRoot.querySelectorAll('li.invoice-item');
        expect(invoiceItems.length).toBe(2);
        expect(invoiceItems[0].textContent).toContain('Invoice 1');
        expect(invoiceItems[1].textContent).toContain('Invoice 2');
    });

    it('toggles line items on invoice click', async () => {
        getInvoices.mockResolvedValue(MOCK_INVOICES);
        getMoreInvoiceLineItems.mockResolvedValue(MOCK_LINE_ITEMS);

        const element = createElement('c-invoice-tree', {
            is: InvoiceTree
        });
        document.body.appendChild(element);

        // Wait for invoices to render
        await Promise.resolve();

        const invoiceHeaders = element.shadowRoot.querySelectorAll('.invoice-header');
        invoiceHeaders[0].click(); // Simulate click to expand

        // Wait for line items to load
        await Promise.resolve();

        const lineItems = element.shadowRoot.querySelectorAll('li.line-item');
        expect(lineItems.length).toBe(2);
        expect(lineItems[0].textContent).toBe('Invoice Line Item 1.1');
        expect(lineItems[1].textContent).toBe('Invoice Line Item 1.2');
    });

    it('loads more line items on "View More" click', async () => {
        getInvoices.mockResolvedValue(MOCK_INVOICES);
        getMoreInvoiceLineItems.mockResolvedValue(MOCK_LINE_ITEMS);

        const element = createElement('c-invoice-tree', {
            is: InvoiceTree
        });
        document.body.appendChild(element);

        // Wait for invoices to render
        await Promise.resolve();

        const viewMoreButton = element.shadowRoot.querySelector('button.view-more-btn');
        expect(viewMoreButton).not.toBeNull();

        viewMoreButton.click(); // Simulate View More click

        // Wait for additional line items to load
        await Promise.resolve();

        const lineItems = element.shadowRoot.querySelectorAll('li.line-item');
        expect(lineItems.length).toBe(2); // Since MOCK_LINE_ITEMS returns 2 items
    });
});
