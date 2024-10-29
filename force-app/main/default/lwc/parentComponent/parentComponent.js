// parentComponent.js
import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
    handleChildMessage(event) {
        const customEvent = new CustomEvent('childaction', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent); // Bubble the event to grandparent
    }
}
