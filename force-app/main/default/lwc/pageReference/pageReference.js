import { LightningElement, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class PageReference extends NavigationMixin(LightningElement) {
    @api recordId; // Automatically provided by the record page
    handleCreate(event){
        event.preventDefault();

        let nav = {
            type: 'standard__objectPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'new'
            }
        };

        this[NavigationMixin.Navigate](nav);
    }

    handleEdit(evt){
        evt.preventDefault();

        //const recordId = evt.target.dataset.recordid;
        this[NavigationMixin.Navigate] ({
            type: 'standard__recordPage',
            attributes: {
                recordId:'001F900001oUhdFIAS',
                objectApiName: 'Account',
                actionName: 'edit'
            }
        });
    }

    handleView(evt){
        evt.preventDefault();

    }


}