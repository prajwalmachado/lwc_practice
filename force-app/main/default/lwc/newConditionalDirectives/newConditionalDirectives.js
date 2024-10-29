import { LightningElement } from 'lwc';

export default class NewConditionalDirectives extends LightningElement {

    country="";
    status = 'ready'; 
    // Can be 'ready', 'loading', or 'error'

    setStatus(event) {
        // Retrieve the status from the button's data-status attribute
        this.status = event.target.dataset.status;
    }

    get isReady() {
        return this.status === 'ready';
    }
    
    get isLoading() {
        return this.status === 'loading';
    }
    

    country = 'India';
    newCountry = ''

    get isCountryIndia(){
        console.log("iscountryIndia getter called");
        return this.newCountry === 'India';
    }
    get isCountryAustralia(){
        console.log("iscountryAustralia getter called");
        return this.newCountry === 'Australia';
    }
    get isCountryCanada(){
        console.log("isCountryCanada getter called");
        return this.newCountry === 'Canada';
    }

    changeHandler(event){
        this.newCountry = event.target.value;
    }
}