import { LightningElement } from 'lwc';

export default class ConditionalRendering extends LightningElement {
    isVisible = false;
    name;
    handleClick(){
        this.isVisible = true;
    }

    changeHandler(event){
        this.name = event.target.value;
    }

    get inputHello(){
        return this.name === "hello";
    }
}