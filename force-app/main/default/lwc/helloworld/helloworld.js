import { LightningElement,track } from 'lwc';

export default class Helloworld extends LightningElement {
    coursename = 'Zero to Hero';
    title = "LWC"
    changeHandler(event){
        this.title = event.target.value;

    }

 /***@track binding example */
 @track address={
    city:'Melbourne',
    postcode:3008,
    country:'Australia'
}

trackHandler(event){
    this.address.city = event.target.value
}
   

     /***getter example */
     users = ["john", "smith", "nik"]
     num1 = 10
     num2 = 20
     // this.firstUser =this.users[0]
     get firstUser(){
         return this.users[0].toUpperCase()
     }
 
     get multiply(){
         return this.num1*this.num2
     }
    
}