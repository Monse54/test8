import { LightningElement, api, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/OpportunityStageController.getPickListValues';
import saveValues from '@salesforce/apex/OpportunityStageController.saveValues';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PopupModal extends LightningElement {
    @api recordId;
    @track showModal = false;
    channelName = '/data/OpportunityChangeEvent';
    subscription = {};
    subscribed;
    options = [];
    @track selectedValue;
    // @track eventName;
     checklostreason = false;
     reason;
    @track comment;
    @track backGroundColor;
    @track closeButton = false;

    @api
    async connectedCallback() {
        console.log('connectedCallback called');
        this.handleSubscribe();
        console.log(this.recordId);
    }
    /*  @wire(getReason, { recordid: '$recordId' })
    wiredResult({ error, data }) {
        if (data) {
            this.lostReason = data;
            console.log('lostreason: '+this.lostReason);
        } else if (error) {
            console.error(error);
        }
    }
 */
    @api
    async disconnectedCallback() {
        this.unsubscribeFromMessageChannel();
    }

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            MessageContext,
            OPPORTUNITY_STAGE_CHANGE_MESSAGE,
            (message) => {
                if (message.recordId === this.recordId && message.stage === 'Closed') {
                    this.showModal = true;
                }
            }
        );
           }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // this.loadLostReason();
            // Response contains the payload of the new message received
            this.handleMessage(response);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
        this.callPickListFunction();
    }
    //fetch picklist options
    callPickListFunction(){
        getPicklistValues({	
            strObjectName: 'Opportunity',
            strPicklistField: 'Reason__c'	
        })	
        .then(data => {	
            this.options = data;	
            console.log('this.marketData-->>'+this.options);	
           
            //this.error = undefined;	
        })	
        .catch(error => {	
            //this.error = error;    	
            console.log('error for PickList Data-->>'+JSON.stringify(error));      	
        })

    }

    unsubscribeFromMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    closeModal() {
        this.showModal = false;
        saveValues({
            recordid: this.recordId,
            lostReason: this.selectedValue,
            comment: this.comment	
        })	
        .then(data => {	
            console.log(data);
            location.reload()
        })	
        .catch(error => {	
            console.log('error while saving Data-->>'+JSON.stringify(error));      	
        })

    }
    /*handleReasonChange(event){
        if(this.reason != null){
            this.selectedValue = this.reason;
            console.log('This selected value @@@@@@'+this.selectedValue);
        }else{
            this.selectedValue = event.target.value;
        }            
    }*/

    handleMessage(response) {
        console.log('handleMessage');
        if (response) {
            if (response.hasOwnProperty('data')) {
                let responsePayload = response.data.payload;
                if (responsePayload.hasOwnProperty('StageName') && responsePayload.hasOwnProperty('ChangeEventHeader')) {
                    if (responsePayload.ChangeEventHeader.hasOwnProperty('recordIds') && responsePayload.StageName == 'Dead/Lost') {
                        let currentRecordId = responsePayload.ChangeEventHeader.recordIds.find(element => element == this.recordId);
                        //this.loadLostReason();
                        console.log('currentRecordId', currentRecordId);
                        this.showModal = true;
                    }

                }
                if (responsePayload.hasOwnProperty('Reason__c') && responsePayload.hasOwnProperty('ChangeEventHeader')) {
                    if (responsePayload.ChangeEventHeader.hasOwnProperty('recordIds') && responsePayload.Reason__c != null) {
                        let currentRecordId = responsePayload.ChangeEventHeader.recordIds.find(element => element == this.recordId);
                        //this.loadLostReason();
                        console.log('currentRecordId', currentRecordId);
                        console.log('current reason ', responsePayload.Reason__c);
                        this.checklostreason = true;
                        this.reason = responsePayload.Reason__c;
                    }

                }
            }
        }
    }
    handleInputValue(event){
        // this.eventName = event.target.name;


        // if(event.target.name === 'LossReason'){
        // this.lossReason = event.target.value;}
        
        console.log('handleInputValue')
        if(event.target.name === 'Comments'){
            this.selectedValue = this.reason;
            this.comment = event.target.value;
        }

        if(event.target.name === 'Lost Reason'){
            if(this.reason != null){
                this.selectedValue = this.reason;
                console.log('hello i am here '+this.selectedValue);
            }else{
                this.selectedValue = event.target.value;
                console.log('hello i am here '+this.selectedValue);
            }
        }

        if(this.selectedValue !== undefined && this.comment !== undefined && this.comment.length>0){

            console.log('this.selectedValue-->'+this.selectedValue);
            console.log('this.comment-->'+this.comment);
            this.closeButton = true;
            // this.backGroundColor= 'background-color: #6f7172;';

        }
        else{
            this.closeButton = false;
            // this.backGroundColor= 'background-color: hsl(204, 64%, 40%);';
        }


    }
    // get backGroundColor() {
    //     if (this.closeButton === false) {
    //         return `background-color: #6f7172;`;
    //     } else {
    //         return `background-color: hsl(204, 64%, 40%);`;
    //     }
        
    // }
    
}