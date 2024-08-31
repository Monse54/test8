import { LightningElement,api,wire} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/CustomLookupLwcController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/CustomLookupLwcController.fetchDefaultRecord';
import getNameFromRecord from '@salesforce/apex/CustomLookupLwcController.getNameFromRecord';
const DELAY = 300; // dealy apex callout timing in miliseconds  
export default class CustomLookupLwc extends LightningElement {
    // public properties with initial default values 
    @api label = 'custom lookup label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:account';
    @api sObjectApiName = 'Account';
    @api defaultRecordId = '';
    @api defaultValue = '';
    @api displayField = 'Name'; // Shows to the user
    @api dbValueField = 'Id'; // Value updated to the backend
    @api sameDisplayDb = 'false';
    @api nameLookupObject = ''; //This must be passed if we want to display name instead of salesfoceid
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 
   // initial function to populate default selected lookup record if defaultRecordId provided  
//    renderedCallback(){
//         if(this.defaultValue != ''){
//             var outRecord = {Value : this.defaultValue, Name: this.defaultValue};
//             this.selectedRecord = outRecord;
//             this.handelSelectRecordHelper();
//         }
//    }
    connectedCallback(){

        console.log('connectedCallback1');
        

         if(this.defaultRecordId != '' || this.defaultValue != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName, displayField : this.displayField, dbValueField : this.dbValueField })
            .then((result) => {
                if(result != null){
                    console.log('connectedCallback');
                    // var outRecord = Object.create(result);
                    outRecord['Name'] = this.handleRelationship(this.displayField, result);
                    // outRecord['Name'] = result[this.displayField];
                    if(this.sameDisplayDb === "true"){
                        outRecord['Value'] = this.handleRelationship(this.displayField, result);
                        // outRecord['Value'] = result[this.displayField];
                    }else{
                        outRecord['Value'] = this.handleRelationship(this.dbValueField, result);
                        // outRecord['Value'] = result[this.dbValueField];
                    }
                    this.selectedRecord = outRecord;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }else if(this.defaultValue != ''){
                    // In our case, Default value might be coming from differetn object (OLI or Flight) than we query from (Product Price List).
                    if(this.nameLookupObject != ''){
                        getNameFromRecord({recId: this.defaultValue , 'nameLookupObject' : this.nameLookupObject})
                        .then((nameResult)=> {
                            if(nameResult != null){
                                this.selectedRecord = nameResult;
                                this.handelSelectRecordHelper();
                            }
                        });
                    }else{
                        var outRecord = {Value : this.defaultValue, Name: this.defaultValue};
                        this.selectedRecord = outRecord;
                        this.handelSelectRecordHelper();
                    }
                    
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }
    }
    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName', displayField : '$displayField', dbValueField : '$dbValueField' })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
            this.hasRecords = data.length == 0 ? false : true; 
            var outData = [];
            var uniqueCheck = [];
            data.forEach((record) => {
                console.log(record);
                var outRecord = Object.create(record);
                // var splitArray = this.displayField.split('.')
                //     outRecord['Name'] = record;
                //     splitArray.forEach(element => {
                //         outRecord['Name'] = outRecord['Name'][element];
                //     });

                outRecord['Name'] = this.handleRelationship(this.displayField, record);
                //outRecord['Name'] = record[this.displayField];
                if(this.sameDisplayDb === "true"){
                    outRecord['Value'] = this.handleRelationship(this.displayField, record);
                    // outRecord['Value'] = record[this.displayField];
                }else{
                    outRecord['Value'] = this.handleRelationship(this.dbValueField, record);
                    // outRecord['Value'] = record[this.dbValueField];
                }
                
                // Check if already there
                if(!uniqueCheck.includes(outRecord['Value'])){
                    outData.push(outRecord);
                    uniqueCheck.push(outRecord['Value']);
                }
            });

             this.lstResult = JSON.parse(JSON.stringify(outData)); 
             
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };

    handleRelationship(fieldName, input){
        var splitArray = fieldName.split('.')
        var outRecord = Object.create(input);
        splitArray.forEach(element => {
            outRecord = outRecord[element];
        });
        return outRecord;
    }
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }
    // method to toggle lookup result section on UI 
    toggleResult(event){
        console.log('toggleResult');
        console.log(this.lstResult);
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        console.log(whichEvent);
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }
   // method to clear selected lookup record  
   handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
  }
  // method to update selected record from search result 
handelSelectedRecord(event){   
     var objId = event.target.getAttribute('data-recid'); // get selected record Id 
     this.selectedRecord = this.lstResult.find(data => data.Value === objId); // find selected record from list 
     this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}
/*COMMON HELPER METHOD STARTED*/
handelSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');     
}
// send selected lookup record to parent component using custom event
lookupUpdatehandler(value){    
    const oEvent = new CustomEvent('lookupupdate',
    {
        'detail': {selectedRecord: value}
    }
);
this.dispatchEvent(oEvent);
}
}