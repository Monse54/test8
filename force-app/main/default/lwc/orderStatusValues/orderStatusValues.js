import { api, LightningElement } from 'lwc';
const options = [
    { label: 'Placement Name', value: 'contact'},
    { label: 'Cost Type', value: 'phone'},
    { label: 'Budget', value: 'contact'},
    { label: 'Impressions', value: 'phone'},
    { label: 'List Price', value: 'contact'},
    { label: 'Sales Price', value: 'phone'},
    { label: 'Start Date', value: 'phone'},
    { label: 'End Date', value: 'contact',},
    { label: 'Status', value: 'phone'},
];

export default class OrderStatusValues extends LightningElement {
    @api label;
    @api placeholder;
    @api value;
    @api options = [];
    @api parentrecord;

    connectedCallback(){
       
    }

    handleChange(event){
        console.log('Inside handle change of Assessment type >>>>>');
        console.log('options in picklist components >>>>>',this.options);
        const eventPick = new CustomEvent('picklistchanged', {
            bubbles : true,
            composed : true,
            cancelable : true,
            detail: {
                data : {
                    selectedValue : event.target.value,
                    relatedRecord : this.parentrecord
                }
            }
        });
        this.dispatchEvent(eventPick);
    }
}