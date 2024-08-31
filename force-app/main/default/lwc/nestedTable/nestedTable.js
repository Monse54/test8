import { LightningElement, wire } from 'lwc';
import ORDER_OBJECT from '@salesforce/schema/Order';

const ORDER_COLUMNS = [
    { label: 'Name', fieldName: 'Name', editable: true },
    { label: 'Order Number', fieldName: 'OrderNumber', editable: true },
    { label: 'Order Date', fieldName: 'OrderDate', type: 'date', editable: true },
    { label: 'Status', fieldName: 'Status', editable: true },
    { label: 'Total Amount', fieldName: 'TotalAmount', type: 'currency', editable: true }
];

const PRODUCT_COLUMNS = [
    { label: 'Product Code', fieldName: 'ProductCode', editable: true },
    { label: 'Product Name', fieldName: 'ProductName', editable: true },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency', editable: true },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: true },
    { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency', editable: true }
];

export default class NestedTable extends LightningElement {
    items = [];

    columns = ORDER_COLUMNS;
    productColumns = PRODUCT_COLUMNS;

    // @wire(getOrderData, { accountId: '$recordId' })
    // wiredOrders({ error, data }) {
    //     if (data) {
    //         this.orders = data;
    //     } else if (error) {
    //         console.error(error);
    //     }
    // }
    connectedCallback() {
        // Parse the JSON data and set it to the "orders" property
        console.log('nestedTable');
        this.items = JSON.parse('{"items":[{"Id":"8020Y000000DhdBQAS","Name":"Item #0001","StartDate":"2023-03-01","EndDate":"2023-03-01","Status":"Draft","Impressions":1500,"ProductCode":"PROD-0001","ProductName":"Product 1","UnitPrice":500,"Quantity":2,"TotalPrice":1000,"isExpandable":true,"isVisible":true},{"Id":"8020Y000000DhdBQAS","Name":"Flight #0001","StartDate":"2023-03-01","EndDate":"2023-03-01","Status":"Draft","Impressions":1500,"ProductCode":"PROD-0001","ProductName":"Product 1","UnitPrice":500,"Quantity":2,"TotalPrice":1000,"isExpandable":false,"isVisible":true},{"Id":"8020Y000000DhdBQAS","Name":"Flight #0001","StartDate":"2023-03-01","EndDate":"2023-03-01","Status":"Draft","Impressions":1500,"ProductCode":"PROD-0001","ProductName":"Product 1","UnitPrice":500,"Quantity":2,"TotalPrice":1000,"isExpandable":false,"isVisible":true}]}').items;
    }

    // handleRowAction(event) {
    //     const action = event.detail.action;
    //     const row = event.detail.row;

    //     const rowEl = this.template.querySelector('[data-id="' + row.Id + '"]');
    //             if (rowEl) {
    //                 const detailTable = rowEl.querySelector('.product-table');
    //                 if (detailTable) {
    //                     detailTable.classList.toggle('slds-hide');
    //                 }
    //             }

    //     // switch (action.name) {
    //     //     case 'view_details':
    //     //         const rowEl = this.template.querySelector('[data-id="' + row.Id + '"]');
    //     //         if (rowEl) {
    //     //             const detailTable = rowEl.querySelector('.product-table');
    //     //             if (detailTable) {
    //     //                 detailTable.classList.toggle('slds-hide');
    //     //             }
    //     //         }
    //     //         break;
    //     //     default:
    //     // }
    // }

    // handleCellChange(event) {
    //     const field = event.detail.field;
    //     const value = event.detail.value;
    //     const row = event.detail.row;
    //     // call an Apex method to update the field value
    //     // and refresh the data
    // }

    // handleProductCell(event) {
    //     const field = event.detail.field;
    //     const value = event.detail.value;
    //     const row = event.detail.row;
    //     // call an Apex method to update the field value
    //     // and refresh the data
    // }
}