import { LightningElement } from 'lwc';

export default class ChildComponent extends LightningElement {
    sendMessage() {
        const event = new CustomEvent('message', {
            detail: 'Hello Grandparent!'
        });
        this.dispatchEvent(event); // Send event to parent
    }
}
