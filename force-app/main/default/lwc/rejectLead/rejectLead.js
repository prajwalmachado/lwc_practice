import { LightningElement, api } from 'lwc';
import rejectLeadStatus from '@salesforce/apex/LeadContoller.rejectLeadStatus'; // Apex method to update lead status
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RejectLead extends LightningElement {
    @api recordId; // This will automatically be populated with the record's ID in the quick action context

    // This method will be invoked when the button is clicked
    rejectLead() {
        rejectLeadStatus({ leadId: this.recordId })
            .then(result => {
                // Show success toast message
                this.showToast('Success', 'Lead status updated to Rejected/Disqualified.', 'success');
                // Close the action panel after success (on mobile)
                this.dispatchEvent(new CustomEvent('close'));
            })
            .catch(error => {
                // Show error toast message
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Helper method to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
