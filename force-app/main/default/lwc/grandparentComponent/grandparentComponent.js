// grandparentComponent.js
import { LightningElement } from 'lwc';

export default class GrandparentComponent extends LightningElement {
    messageFromChild = '';

    handleChildAction(event) {
        this.messageFromChild = event.detail;
    }
}
