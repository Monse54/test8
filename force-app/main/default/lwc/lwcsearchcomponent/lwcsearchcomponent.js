import { LightningElement,api, track, wire } from 'lwc';
import getPriceListValues from '@salesforce/apex/CustomLookupController.SearchRecords';

export default class Lwcsearchcomponent extends LightningElement {

    @track searckKeyword;
    products = [];
    @track searchString;
    ObjectName = 'Product_Price_List__c';
    ReturnFields = 'Product_Type__c';
    QueryFields = 'Product_Type__c';
    // @track SearchText = 'Product_Price_List__c';
    SortColumn = 'CreatedDate';
    SortOrder = 'DESC';
    MaxResults = '1000';
    Unique = 'true';
    Filter = '';
    @track isrequired;
    @api showLabel   = 'true';
    @api isReadOnly = 'true';
    @api orderValue;
    @api orderValue2;
    @api orderValue3;
    @api orderItemBoolean;
    @api orderProductBoolean;
    @api orderSubproductBoolean;
    /* Check the isrequired prop is true then set the prop to true*/

    @wire(getPriceListValues, {ObjectName:'$ObjectName',ReturnFields:'$ReturnFields', QueryFields:'$QueryFields',SearchText:'$SearchText',SortColumn:'$SortColumn',SortOrder:'$SortOrder',MaxResults:'$MaxResults',Filter:'$Filter', Unique:'$Unique'}) getString1 ({
        // {orderId:'8013K0000011w9sQAA'}) getString1 ({
         error, data
     
       }){
     
         if(data){
             console.log('wire method called');
             this.products = JSON.parse(data);
             //this.getFlightData();
             console.log('this.products--->',this.products);
             console.log('this.products--->'+JSON.stringify(this.products));
            
             }
             else if (error) {
                 this.error = error;
                 
                 this.ordersItems = undefined;
                 console.log('error in wire'+error);
               }
       }
    renderedCallback() {
        // if ( this.isrequired === "false" )
        //     return;
        // if ( this.isrequired === "true") {
        //     let picklistInfo = this.template.querySelector('lightning-input');
        //     picklistInfo.required = true;
        //     this.isrequired = "false";
        // }
        
    }

    handleChange(event) {

        var keyword = event.target.value;
        console.log('keyword-->>'+keyword);
        /* Create & dispatch the event to parent component with the search keyword */
        if ( keyword && keyword.length > 0 ) {
            let searchEvent = new CustomEvent('search',{
                detail : { value : keyword }
            });
            this.dispatchEvent(searchEvent);
            console.log('here it is===>>>');
            
        }else{
            let searchEvent = new CustomEvent('search',{
                detail : { value : keyword }
            });
            this.dispatchEvent(searchEvent);
        }
        
    }
    handleChange2(event){
        console.log('calledd');

        getPriceListValues({ObjectName:this.ObjectName, ReturnFields:this.ReturnFields, QueryFields:this.QueryFields, SearchText:'', SortColumn:this.SortColumn, SortOrder:this.SortOrder, MaxResults:this.MaxResults, Filter:this.Filter, Unique:this.Unique})
            .then(data => {
                console.log('data-->>'+data);
                this.products = data;
                
                console.log('this.orders-->>'+this.products);
                console.log('this.orders-->>'+JSON.stringify(this.products));
               
            })
            .catch(error => {
                this.error = error;   
                console.log(error);       
            })
        var keyword = event.target.value;
        this.searchString = event.target.value;
        /* Create & dispatch the event to parent component with the search keyword */
        if ( keyword && keyword.length > 0 ) {
            let searchEvent = new CustomEvent('search',{
                detail : { value : keyword }
            });
            this.dispatchEvent(searchEvent);
            console.log('here it is===>>>');
            
        }else{
            let searchEvent = new CustomEvent('search',{
                detail : { value : keyword }
            });
            this.dispatchEvent(searchEvent);
        }
        
    }

    filterOptions(event) {
        this.searchString = event.target.value;
       
        getPriceListValues({ObjectName:this.ObjectName, ReturnFields:this.ReturnFields, QueryFields:this.QueryFields, SearchText:this.SearchText, SortColumn:this.SortColumn, SortOrder:this.SortOrder, MaxResults:this.MaxResults, Filter:this.Filter, Unique:this.Unique})
            .then(data => {
                this.products = data;
                
                console.log('this.orders-->>'+this.products);
                console.log('this.orders-->>'+JSON.stringify(this.products));
               
            })
            .catch(error => {
                this.error = error;   
                console.log(error);       
            })
        

    console.log('searchString-->'+this.searchString);
    }
    connectedCallback() {
        console.log('Is read only in LWCSearch is '  +this.isReadOnly);
        console.log('Filter-->>'+this.Filter);
        this.isrequired == true;
    }
}