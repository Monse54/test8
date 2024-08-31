import { LightningElement, api, track } from 'lwc';
import searchRecords from '@salesforce/apex/OrderFlightDataController.getOrderItemData';
import searchProducts from '@salesforce/apex/OrderFlightDataController.getOrderItemData';
import getPriceListValues from '@salesforce/apex/CustomLookupController.SearchRecords';
export default class LookupOnOrderItems extends LightningElement {

    /* public property */
    /* these public property will be used when using this component inside other component for the lookup functionality */
    /* objectName is the name of the Object which is parent either master-detail or lookup */
    /* fieldName is the field of parent object in which text needs to be searched */
    /* iconname - icon to display in the list and after selection of the record */
    /* label - to show the label for the lookup */
    /* parentidfield - the apiname of lookup/matser-detail in the child object this field is useful to indentify which parent record has been select if there are multiple lookup for a single child record */
    @api objectName = 'Account';
    @api fieldName  = 'Name';
    @api iconname   = 'standard:record';
    @api label      = 'OrderItem';
    @api parentidfield = 'AccountId';
    @api lookupEdit2;
    @api orderValue;
    @api orderValue2;
    @api orderValue3;
    @api valueId;
    @api orderItemBoolean;
    @api orderProductBoolean;
    @api orderSubproductBoolean;

    ObjectName = 'Product_Price_List__c';
    ReturnFields = 'Product_Type__c';
    QueryFields = 'Product_Type__c';
    // @track SearchText = 'Product_Price_List__c';
    SortColumn = 'CreatedDate';
    SortOrder = 'DESC';
    MaxResults = '1000';
    Unique = 'true';
    Filter = '';

    @api recordId;
    @api recordName;
    @track isReadOnly4 = true;
    @track progressValue = 0;
    @track changeStyle = false;
    @track readOnlyCss;
    /* private property */
    @track records = [];
    @track selectedRecord;
    //slds-border_right slds-border_bottom slds-border_left

    connectedCallback() {
        console.log('Is read only in custom lwwc is '  +this.isReadOnly);
        // if(this.isReadOnly)  {
        //     this.readOnlyCss = 'slds-input slds-combobox__input slds-combobox__input-value borderBox readOnlyClass';
        // }else {
        //     this.readOnlyCss = 'slds-input slds-combobox__input slds-combobox__input-value borderBox editableClass';
        // }
        // if(this.recordId)  {
        //    this.selectedRecord = {};
        //     this.selectedRecord.Id = this.recordId;
        //     this.selectedRecord.Name = this.recordName;
        // }
    }
    
    hanldeSearch(event) {
        console.log('Its searching for data');
        var searchVal = event.detail.value;
        console.log('searchVal-->>'+searchVal);
        console.log('valueId-->>'+this.valueId);
        // if(searchVal.length>0){
            console.log('inside if block==>>');
            getPriceListValues({ObjectName:this.ObjectName, ReturnFields:this.ReturnFields, QueryFields:this.QueryFields, SearchText:'', SortColumn:this.SortColumn, SortOrder:this.SortOrder, MaxResults:this.MaxResults, Filter:this.Filter, Unique:this.Unique})
            .then(data => {
                console.log('data-->>'+data);
                this.records = data;
                
                console.log('this.orders-->>'+this.records);
                console.log('this.orders-->>'+JSON.stringify(this.records));
               
            })
            .catch(error => {
                this.error = error;   
                console.log(error);       
            })
        // }else{
        //     this.records = undefined;
        //     console.log('this.records value is ==>>'+this.records);
        // }
        
    }
    handleSearch2(event){
        console.log('Its searching for data');
        var searchVal = event.detail.value;
        console.log('searchVal-->>'+searchVal);
    }

    handleSelect2(event) {
        console.log('Searching is done data is selected');
        // let thirdClass = this.template.querySelector(".adjustHeight").classList.add('slds-hide'); 
        var selectedVal = event.detail.selRec;
        this.selectedRecord =  selectedVal;
        console.log(JSON.stringify(this.selectedRecord));

        // console.log(event.target.name);
        // console.log(event.target.value);
        // console.log(event.target.dataset.id);
        // updateField({ fieldName: event.target.name, fieldValue: event.target.value, recordId: event.target.dataset.id })
        //     .then(() => {
        //     // Handle success
        //     console.log('Record field updated successfully');
        //     })
        //     .catch(error => {
        //     // Handle error
        //     this.dispatchEvent(new ShowToastEvent({
        //     title: 'Error',
        //     message: error.body.message,
        //     variant: 'error'
        //     }));
        // });
        let firstClass = this.template.querySelector(".abcd").classList.add('slds-hide'); 
        console.log('firstClass'+firstClass);
        let finalRecEvent = new CustomEvent('select',{
            detail : { selectedRecordId : this.selectedRecord.Id, parentfield : this.parentidfield }
        });
        this.dispatchEvent(finalRecEvent);
        console.log( 'Your Final Parent Input is ' + JSON.stringify(this.strOutput) );
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.strOutput
        } ) );

    } 
    handleSelect3(event) {
        console.log('Searching is done data is selected');
        // let thirdClass = this.template.querySelector(".adjustHeight").classList.add('slds-hide'); 
        var selectedVal = event.detail.selRec;
        this.selectedRecord =  selectedVal;
        console.log(JSON.stringify(this.selectedRecord));
        //let firstClass = this.template.querySelector(".abcd").classList.add('slds-hide'); 
        //console.log('firstClass'+firstClass);
        let finalRecEvent = new CustomEvent('select',{
            detail : { selectedRecordId : this.selectedRecord.Id, parentfield : this.parentidfield }
        });
        this.dispatchEvent(finalRecEvent);
        console.log( 'Your Final Parent Input is ' + JSON.stringify(this.strOutput) );
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.strOutput
        } ) );

    } 
    renderedCallback()  {     
        console.log('rendered call back from customlwclookup'); 
        if(this.isReadOnly)  {
            this.readOnlyCss = 'slds-input slds-combobox__input slds-combobox__input-value borderBox readOnlyClass';
        }else {
            this.readOnlyCss = 'slds-input slds-combobox__input slds-combobox__input-value borderBox editableClass';
        }
    }

    handleRemove() {
        //this.template.querySelector('.abcd').classList.toggle('slds-hide');
        
        this.selectedRecord =  undefined;
        this.records = undefined;
        console.log('handleRemove called===>>>>');
        let finalRecEvent = new CustomEvent('select',{
            detail : { selectedRecordId : undefined, parentfield : this.parentidfield, }
        });
        this.strOutput = undefined;
        this.dispatchEvent(finalRecEvent);
        console.log(this.selectedRecord);
        console.log('third class===>>>');
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.strOutput
        } ) );

        

    }

    hanldeProgressValueChange(event) {
        this.progressValue = event.detail;
        console.log("Printed From Parent",this.progressValue);
        console.log("Printed From Parent JSON",JSON.stringify(this.progressValue));
      }

      strOutput;
      fetchValue( event ) {
          console.log( 'Value from Child LWC is ' , JSON.stringify(event.detail ));
          this.strOutput = event.detail;
            console.log( 'Str Output',JSON.stringify(this.strOutput));
      }

      strInput2;
      handleChange( event ) {
        this.strInput2 = event.target.strOutput;
        console.log("strInput2",JSON.stringify(this.strInput2));
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.strInput2
        } ) );
        console.log("Str Input going to Main Parent",JSON.stringify(this.strInput2));
      }
}