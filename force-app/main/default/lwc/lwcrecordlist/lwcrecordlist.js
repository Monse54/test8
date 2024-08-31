import { LightningElement, api } from 'lwc';

export default class Lwcrecordlist extends LightningElement {
    /* Public Property to pass the single record & iconname */
    @api rec;
    @api iconname = 'standard:order_item';
    @api orderItemBoolean;
    @api orderProductBoolean;
    @api orderSubproductBoolean;


    handleSelect(  ) {
console.log('handle select called!!!!!');
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.rec
        } ) );
        console.log("Str Input",JSON.stringify(this.rec));

        let selectEvent = new CustomEvent('select',{
            detail : { selRec : this.rec },
            
        });console.log("selectEvent",JSON.stringify(this.rec));
        this.dispatchEvent( selectEvent );
        console.log("detail",JSON.stringify(this.selRec));
    }

    handleRemove(  ) {
        let selectEvent = new CustomEvent('select',{
            detail : { selRec : undefined }
        });console.log("Removedetail"+this.detail);
        this.dispatchEvent( selectEvent );
    }


    strInput;

    handleChange( event ) {

        this.strInput = event.target.rec;
        console.log("Str Input handle",this.strInput);
    }
    connectedCallback(){
        console.log('connectedCallBack from recordList!!!!');
    }
}