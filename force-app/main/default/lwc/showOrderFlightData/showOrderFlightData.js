import { LightningElement,track,api,wire } from 'lwc';
import getOrderFlightData from '@salesforce/apex/OrderFlightDataController.getOrderFlightData';
import getProductData from '@salesforce/apex/OrderFlightDataController.getProductData';
import SVG_LOGO from '@salesforce/resourceUrl/editIcon';
import updateField from '@salesforce/apex/OrderFlightDataController.updateField';
import deleteRecord from '@salesforce/apex/OrderFlightDataController.deleteRecord';
import insertFlightItem from '@salesforce/apex/OrderFlightDataController.insertFlightItem';
import insertOrderItem from '@salesforce/apex/OrderFlightDataController.insertOrderItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';



export default class ShowOrderFlightData extends LightningElement {

  @track orders = [];
  @track productData = [];
  @track  ordersItems = [];
  @track salePrice;
  @track budget;
  @track quantity;
  @track salesPriceId;
  @track budgetId;
  @track eventName;
  @track eventBValue;
  @track eventSValue;
  @track currentDataId;
  @track currentDataId2;
  error;
  tempId;
  
  @track expandedRows = [];

 @track svgURL = SVG_LOGO;

 get statusOptions() {
  return [
      { label: 'Active', value: 'Active' },
      { label: 'Not Active', value: 'Not Active' },
  ];
}

// @wire(getProductData) getProdData ({error, data}){
//    if(data){
//        console.log('wire method called');
//        this.productData = data;
//        //this.getFlightData();
//        console.log('this.productData--->',this.productData);
//        console.log('this.productData--->'+JSON.stringify(this.productData));
      
//        }
//        else if (error) {
//            this.error = error;
//          }
//  }

  @wire(getOrderFlightData, {orderId:'$_recordId'}) getString1 ({
   // {orderId:'8013K0000011w9sQAA'}) getString1 ({
    error, data

  }){

    if(data){
        console.log('wire method called');
        this.orders = JSON.parse(data);
        refreshApex(this.orders);
        //this.getFlightData();
        console.log('this.ordersItems--->',this.orders);
        console.log('this.ordersItems--->'+JSON.stringify(this.orders));
       
        }
        else if (error) {
            this.error = error;
            this.ordersItems = undefined;
          }
  }
  
  getFlightData(){
    getOrderFlightData({
        orderId: this._recordId
    })
    .then(data => {
        this.orders = JSON.parse(data);
        let parseData = [];
        console.log('this.orders-->>'+this.orders);
       
    })
    .catch(error => {
        this.error = error;          
    })
}


    get expandedRowItems() {
        return this.expandedRows;
      }
      getRowActions(row, doneCallback) {
        const actions = [];
        actions.push({
          label: "Edit",
          name: "edit"
        });
        actions.push({
          label: "Delete",
          name: "delete"
        });
        doneCallback(actions);
      }  

    _recordId;
    @api set recordId(value) {
    this._recordId = value;

    // do your thing right here with this.recordId / value
}

get recordId() {
    return this._recordId;
}
   
showOrHideChildrenRows(event){
  try {
    
  console.log(event);
  console.log(event.target);
  let rowId = event.target.dataset.rowid;
  console.log('rowId-->>'+rowId);
  let isExpanded = event.target.dataset.expanded;
  console.log('isExpanded-->>'+isExpanded);
  event.target.iconName = JSON.parse(isExpanded) ? "utility:chevronright": "utility:chevrondown";
  console.log('event.target.iconName-->>'+event.target.iconName);
  event.target.dataset.expanded = JSON.stringify(!JSON.parse(isExpanded));
  console.log('event.target.dataset.expanded-->>'+event.target.dataset.expanded);

  this.orders = this.orders.map((obj) => {
    console.log('obj.Id'+obj.Id);
      if(obj.Id == rowId &&  !JSON.parse(isExpanded)){
          obj.rowStyle = "";
      }
      if(obj.Id == rowId && JSON.parse(isExpanded)){
          obj.rowStyle = "slds-hide";
      }
      return obj;
  });
  console.log(this.orders);
} catch (error) {
    console.log('error11-->>'+error);
}
}

add(event) {
  let currentId = this._recordId;

  insertOrderItem({orderId : currentId})
  .then((result) =>{
    if(result != null){
      let orders = this.orders;
      console.log('orders1-->>'+orders);
      orders.push({OrderItemNumber : "", Oli_Product__c : "",Id: "", Impressions__c : "", List_Price__c : "",  Name: "TBD",
      Notes__c : "", Oli_Budget__c : "", Oli_Cost_Type__c :  "", Oli_End_Date__c :  "", Oli_Placement__c :  "",
      Oli_Product__c :  "", Oli_Start_Date__c : "", Oli_Status__c : "", Oli_Sub_Product__c : "",
      OrderItemNumber : "", Price__c : null, Oli_Quantity : 1, ROO__c : null, Sales_Price__c : "", Target_GEO__c : "",
      TotalPrice : "", UnitPrice : "1", isExpandable : true, isVisible : true, nameStyle : "", Id : result, OrderItemNumber: "TBD",
        key : Math.random().toString(36).substring(2, 15), orderdetailch:[], rowStyle : 'slds-hide'});
      this.orders = orders;
    }
    else{
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Unable to Insert Order Item. Please contact your Salesforce Admin',
        variant: 'error'
  }));
    }
  });
    
  
}

addFlightItem(event){
  let currentId = event.target.dataset.name;
  console.log(event);
  console.log('eventdetails-->'+event.target.dataset.name);
  insertFlightItem({orderItem : currentId})
  .then((result) =>{
    if(result != null){
      for(let i = 0; i < this.orders.length; i++){
      if(currentId === this.orders[i].Id){
        let orders2 = this.orders[i].orderdetailch;
        console.log('orders2-->>'+JSON.stringify(orders2));
        orders2.push({Fli_Product__c : "", Fli_Sub_Product__c : "",Target_GEO__c: "", ROO__c : "", Fli_Cost_Type__c : "",  Fli_Budget__c: "",
        Quantity__c : "", Fli_Placement__c : "", Channel__c :  "", Price__c :  "", Fli_Start_Date__c :  "",
        Fli_End_Date__c :  "", Channel__c : "", key : result, orderFlightId: result, Name : "TBD", Id: result, Fli_Status__c:"", Creative__c:"", Channel_Account__c:""});
        this.orders[i].orderdetailch = orders2;
      }
    }}
    else{

    }
  });
  
}

fetchValue(event) {
  console.log('event called for Child');
  this.strOutput = event.detail;
  console.log(JSON.stringify(this.strOutput));
  console.log(this.strOutput.selectedRecord);
  console.log(this.strOutput.selectedLabel); // In label I am paasing Id which we can pass as record id in below apex method
  let passId = event.target.dataset.id;
  if(passId == '' || passId == null){
    console.log('Gone Inside');
      passId = this._recordId;
  }
  if(this.strOutput.selectedLabel == '' || this.strOutput.selectedLabel == null){
    passId = this.strOutput.selectedLabel;
  }
  
  console.log(event.target.name);
  console.log(this.strOutput.selectedRecord.Name);
  console.log('passId-->>'+passId);

  updateField({ fieldName: event.target.name, fieldValue: this.strOutput.selectedRecord.Name, recordId: passId })
    .then(() => {
        // Handle success
        console.log('Record field updated successfully');
    })
    .catch(error => {
        // Handle error
        console.log(error);
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error',
          message: error.body.message,
          variant: 'error'
    }));
  });
}

lookupRecord(event){
  console.log('lookup record called!!');
  console.log(event);
  console.log(event.target.name);
  console.log(event.target.value);
  console.log(event.target.dataset.id);
}

handleInputChange(event){
  console.log('Name-->'+event.target.name);
  console.log('Value-->>'+event.target.value);
  console.log('datasetId-->'+event.target.dataset.id);

  var finalValue;
  
  if(event.detail.selectedRecord)
    finalValue = event.detail.selectedRecord.Value;

  if(event.target.value)
    finalValue = event.target.value;

  console.log('finalValue-->'+finalValue);
  updateField({ fieldName: event.target.name, fieldValue: finalValue, recordId: event.target.dataset.id })
    .then(() => {
        // Handle success
        refreshApex(this.orders);
        console.log('Record field updated successfully');
      
    })
    .catch(error => {
      console.log(error);
        // Handle error
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error',
          message: error.body.message,
          variant: 'error'
    }));
  });



//UnitPrice Logic Starts
  this.eventName2 =  event.target.name;
  if (this.eventName2 === 'Product__c' || this.eventName2 === 'Sub_Product__c' || this.eventName2 === 'Cost_Type__c') {

    this.currentDataId2 = event.target.dataset.id;
    if (this.eventName2 === 'Product__c') {
      this.productType = finalValue;}
    if (this.eventName2 === 'Sub_Product__c') {
      this.subProductType = finalValue;}
    if (this.eventName2 === 'Cost_Type__c') {
      this.costType = finalValue;}
   
    if(this.currentDataId2 !== event.target.dataset.id){
      this.productType = undefined;
      this.subProductType =  undefined;
      this.costType = undefined;}

      getProductData({
        orderId: this.currentDataId2, 
        productType: this.productType,
        subProductType: this.subProductType,
        costType: this.costType
      })
      .then(data => {
        // this.orders = JSON.parse(data);
         console.log('data-->>'+data);
        // this.productData = data;
        // console.log('this.productData-->>'+this.productData);
        
          for(let i = 0; i < this.orders.length; i++){
            if (this.currentDataId2 === this.orders[i].Id ) {
              if (data !== -1) {
                  this.orders[i].UnitPrice = data;
                }
              else{
                console.log('It came Inside');
                this.orders[i].UnitPrice = '';
            }
          }
        }
        

       
      })
      .catch(error => {
        this.error = error;          
      })

    // for(let i = 0; i < this.productData.length; i++){
    //   console.log('It came Inside2 ProductData');
    //   if (this.eventName2 === 'Product__c') {
    //     if(this.productType === '' || this.productType === undefined){
    //       this.eventSValue = this.orders[i].Sales_Price__c;
    //     }
    //     let orders = this.orders[i];
    //     orders.Oli_Quantity = parseInt(this.eventBValue/this.eventSValue);
    //     this.orders[i] = orders;
    //     console.log('Inside Budget');
    //     console.log('Ifthis.budget-->'+this.eventBValue);
    //   }
    //   if(this.eventName === 'Sales_Price__c' && this.salesPriceId === this.orders[i].Id){
    //     // let salePrice = this.eventSValue;
    //     if(this.eventBValue === '' || this.eventBValue === undefined){
    //       this.eventBValue = this.orders[i].Oli_Budget__c;
    //     }
    //     let orders = this.orders[i];
    //     orders.Oli_Quantity = parseInt(this.eventBValue/this.eventSValue);
    //     this.orders[i] = orders;
    //     console.log('Inside SalesPrice');
    //     console.log('Elsethis.salePrice-->'+this.eventSValue);
    //   }
    //   console.log('quantityInJSON'+this.orders[i].Oli_Quantity);
    //   console.log(JSON.stringify(this.orders[i]));
    // }
    }


}
//Fill Oli_Quantity Logic Starts
handleInputValue(event){
  if(this.currentDataId !== event.target.dataset.id){
    this.eventBValue = undefined;
    this.eventSValue =  undefined;
  }
  if(event.target.name === 'Budget__c'){
    this.currentDataId = event.target.dataset.id;
    this.budgetId = event.target.dataset.id;
     this.eventName = event.target.name;
     this.eventBValue = event.target.value;
  }
  if (event.target.name === 'Sales_Price__c') {
    this.currentDataId = event.target.dataset.id;
    this.salesPriceId = event.target.dataset.id;
     this.eventName = event.target.name;
     this.eventSValue = event.target.value;
  }

  
      for(let i = 0; i < this.orders.length; i++){
        console.log('It came Inside2');
        if (this.eventName === 'Budget__c' && this.budgetId === this.orders[i].Id ) {
          // let budget = this.eventBValue;
          if(this.eventSValue === '' || this.eventSValue === undefined){
            this.eventSValue = this.orders[i].Sales_Price__c;
          }
          let orders = this.orders[i];
          orders.Oli_Quantity = parseInt(this.eventBValue/this.eventSValue);
          this.orders[i] = orders;
          console.log('Inside Budget');
          console.log('Ifthis.budget-->'+this.eventBValue);
        }
        if(this.eventName === 'Sales_Price__c' && this.salesPriceId === this.orders[i].Id){
          // let salePrice = this.eventSValue;
          if(this.eventBValue === '' || this.eventBValue === undefined){
            this.eventBValue = this.orders[i].Oli_Budget__c;
          }
          let orders = this.orders[i];
          orders.Oli_Quantity = parseInt(this.eventBValue/this.eventSValue);
          this.orders[i] = orders;
          console.log('Inside SalesPrice');
          console.log('Elsethis.salePrice-->'+this.eventSValue);
        }
        console.log('quantityInJSON'+this.orders[i].Oli_Quantity);
        console.log(JSON.stringify(this.orders[i]));
    }

}

confirmFlightItemDelete(event) {
    this.tempId = event.target.dataset.id;
    if (confirm('Are you sure you want to delete this record?')) {
        deleteRecord({ recordId: event.target.dataset.id, 
                        objectType: 'Order_Flight__c' })
            .then(() => {
              this.orders.some(item => {
                const childIndex = item.orderdetailch.findIndex(child => child.orderFlightId === this.tempId);
                if (childIndex !== -1) {
                  item.orderdetailch.splice(childIndex, 1);
                }
              });
            })
            .catch(error => {
                console.log('Error deleting record:', error.body.message);
                this.dispatchEvent(new ShowToastEvent({
                  title: 'Error',
                  message: error.body.message,
                  variant: 'error'
            }));                
            });
    }
}

confirmOrderItemDelete(event) {
    this.tempId = event.target.dataset.id;
    if (confirm('Are you sure you want to delete this record?')) {
      deleteRecord({ recordId: event.target.dataset.id, 
                     objectType: 'OrderItem' })
            .then(() => {
              let temp = this.orders.filter(item => item.Id !== this.tempId);
              this.orders = temp;   
            })
            .catch(error => {
                console.log('Error deleting record:', error.body.message);
                this.dispatchEvent(new ShowToastEvent({
                  title: 'Error',
                  message: error.body.message,
                  variant: 'error'
            }));                
            });
    }
}



}