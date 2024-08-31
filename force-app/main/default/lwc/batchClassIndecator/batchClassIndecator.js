import { LightningElement } from 'lwc';
//importing the apex methods
import getJobDetails from '@salesforce/apex/batchProgressIndicatorController.getJobDetails';
import executeBatch from '@salesforce/apex/batchProgressIndicatorController.executeBatch';
import BATCH_CLASS_NAMES_LABEL from '@salesforce/label/c.BatchClassNamesLabel';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class batchClassIndecator extends LightningElement {
    
    batchJobId;
    executedPercentage;
    executedIndicator;
    executedBatch;
    totalBatch;
    isBatchCompleted = false;
    batchClassName;
    batchSize = 50;
    disableExecuteBatch = false;

    batchOptions = [];

    connectedCallback() {
        this.batchOptions = BATCH_CLASS_NAMES_LABEL.split(',').map(name => ({
            label: name.trim(),
            value: name.trim()
        }));
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    /* batchOptions = [
        { label: 'AzureAccountExtractionBatch', value: 'AzureAccountExtractionBatch' },
        { label: 'AzureOpportunityExtractionBatch', value: 'AzureOpportunityExtractionBatch' }
    ]; */

    handleBatchNameChange(event) {
        this.batchClassName = event.currentTarget.value;
    }

    handleBatchSizeChange(event) {
        this.batchSize = parseInt(event.currentTarget.value);
    }
    handleReset(){
        this.executedIndicator = 0;
        this.executedBatch = 0;
        this.totalBatch = 0;
        this.executedPercentage = 0;
        this.batchClassName = '';
        this.batchJobId = '';
    }
    //execute the batch class
    handleExecuteBatch() {
        //this.disableExecuteBatch = true;
        if (this.batchSize > 200) {
        this.showToast('Error', 'Batch size cannot exceed 200', 'error');
    }else{
        this.executedIndicator = 0;
        this.executedBatch = 0;
        this.totalBatch = 0;
        this.executedPercentage = 0;
        executeBatch({
            className: this.batchClassName,
            chunkSize: this.batchSize
        }).then(res => {
            console.log('response => ', res);
            if (res) {
                this.batchJobId = res;
                //this.getBatchStatus();
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }        
    }
    
    //get the batch status
    getBatchStatus() {
        getJobDetails({ jobId: this.batchJobId }).then(res => {
            console.log('response => ', res);
            if (res[0]) {
                this.totalBatch = res[0].TotalJobItems;
                if (res[0].TotalJobItems == res[0].JobItemsProcessed) {
                    this.isBatchCompleted = true;
                }
                this.executedPercentage = ((res[0].JobItemsProcessed / res[0].TotalJobItems) * 100).toFixed(2);
                this.executedBatch = res[0].JobItemsProcessed;
                var executedNumber = Number(this.executedPercentage);
                this.executedIndicator = Math.floor(executedNumber);
                // this.refreshBatchOnInterval();  //enable this if you want to refresh on interval
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }


    refreshBatchOnInterval() {
        this._interval = setInterval(() => {
            if (this.isBatchCompleted) {
                clearInterval(this._interval);
            } else {
                this.getBatchStatus();
            }
        }, 10000); //refersh view every time
    }
}