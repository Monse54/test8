// /**
//  * Default settings values
//  */
//  export const KEYFIELD = 'name';

 
//  /**
//   * Columns definition
//   * :: used in examples
//   */
//  export const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
//      {
//          type: 'text',
//          fieldName: 'orderLineItemID',
//          label: 'Order Line Item Id',
//          initialWidth: 300,
//      },
//      {
//         type: 'text',
//         fieldName: 'name',
//         label: 'Name',
//     },
//      {
//          type: 'number',
//          fieldName: 'employees',
//          label: 'Quantity',
//      },
//      {
//          type: 'phone',
//          fieldName: 'phone',
//          label: 'Product code',
//      },
//      {
//          type: 'url',
//          fieldName: 'accountOwner',
//          label: 'Unit Price',
//          typeAttributes: {
//              label: { fieldName: 'accountOwnerName' },
//          },
//      },
//  ];
 
//  /**
//   * Sample data
//   * :: valid basic version, no missing children content
//   */
//  export const DATA_BASIC = [
//      {
//          name: '125313-7j',
//          accountName: 'Dach-Welch',
//          phone: '837-555-0100',
//      },
//      {
//          name: '584996-s7',
//          accountName: 'Corkery-Windler',
//          phone: '837-555-0100',
//          _children: [
//              {
//                  name: '747773-jw',
//                  accountName: 'Corkery-Abshire',
//                  phone: '837-555-0100',
//              },
//              {
//                  name: '377526-zg',
//                  accountName: 'Robel, Friesen and Flatley',
//                  phone: '837-555-0100',
//                  _children: [
//                      {
//                          name: '955330-wp',
//                          accountName: 'Donnelly Group',
//                          phone: '837-555-0100',
//                      },
//                      {
//                          name: '343693-9x',
//                          accountName: 'Kshlerin Group',
//                          phone: '837-555-0100',
//                      },
//                  ],
//              },
//              {
//                  name: '638483-y2',
//                  accountName: 'Bruen, Steuber and Spencer',
//                  phone: '837-555-0100',
//              },
//          ],
//      },
//      {
//          name: '306979-mx',
//          accountName: 'Spinka LLC',
//          phone: '837-555-0100',
//      },
//      {
//          name: '066195-o1',
//          accountName: 'Koelpin LLC',
//          phone: '837-555-0100',
//          _children: [],
//      },
//  ];
 
//  /**
//   * Sample data
//   * :: valid basic version, with missing children content
//   */
//  export const DATA_MISSING_CHILDREN_CONTENT = [
//      {
//          name: '125313-7j',
//          accountName: 'Dach-Welch',
//          phone: '837-555-0100',
//      },
//      {
//          name: '584996-s7',
//          accountName: 'Corkery-Windler',
//          phone: '837-555-0100',
//          _children: [],
//      },
//      {
//          name: '816682-xr',
//          accountName: 'Schmitt-Littel',
//          phone: '837-555-0100',
//          _children: [
//              {
//                  name: '118985-mf',
//                  accountName: 'Hegmann-Turcotte',
//                  phone: '837-555-0100',
//              },
//              {
//                  name: '841476-yo',
//                  accountName: 'Kuhlman LLC',
//                  phone: '837-555-0100',
//              },
//          ],
//      },
//      {
//          name: '653331-j4',
//          accountName: 'Swaniawski-Hilpert',
//          phone: '366-145-6134',
//          _children: [
//              {
//                  name: '605249-ei',
//                  accountName: 'Swaniawski, Veum and Barton',
//                  phone: '837-555-0100',
//              },
//              {
//                  name: '686777-5d',
//                  accountName: 'Lubowitz, McClure and Russel',
//                  phone: '837-555-0100',
//              },
//              {
//                  name: '582166-n4',
//                  accountName: 'Reichel-Jerde',
//                  phone: '837-555-0100',
//                  _children: [
//                      {
//                          name: '513683-mm',
//                          accountName: 'Tromp Inc',
//                          phone: '837-555-0100',
//                      },
//                  ],
//              },
//          ],
//      },
//      {
//          name: '306979-mx',
//          accountName: 'Spinka LLC',
//          phone: '837-555-0100',
//      },
//      {
//          name: '066195-o1',
//          accountName: 'Koelpin LLC',
//          phone: '837-555-0100',
//          _children: [],
//      },
//  ];
 
//  /**
//   * Sample data
//   * :: used by examples
//   */
//  export const EXAMPLES_DATA_BASIC = [
//      {
//          name: '123555',
//          orderLineItemID: '8023K0000026elcQAA',
//          employees: 3100,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'Jane Doe',
//          billingCity: 'Phoeniz, AZ',
//      },
 
//      {
//          name: '123556',
//          orderLineItemID: '8023K0000026elcQAA',
//          employees: 10000,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'San Francisco, CA',
//          _children: [
//              {
//                  name: '123556-A',
//                  orderLineItemID: 'Acme Corporation (Bay Area)',
//                  employees: 3000,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'New York, NY',
//                  _children: [
//                      {
//                          name: '123556-A-A',
//                          accountName: 'Acme Corporation (Oakland)',
//                          employees: 745,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'John Doe',
//                          billingCity: 'New York, NY',
//                      },
//                      {
//                          name: '123556-A-B',
//                          accountName: 'Acme Corporation (San Francisco)',
//                          employees: 578,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'Jane Doe',
//                          billingCity: 'Los Angeles, CA',
//                      },
//                  ],
//              },
 
//              {
//                  name: '123556-B',
//                  orderLineItemID: '8023K0000026elcQAA',
//                  employees: 430,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'San Francisco, CA',
//                  _children: [
//                      {
//                          name: '123556-B-A',
//                          accountName: 'Acme Corporation (NY)',
//                          employees: 1210,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'Jane Doe',
//                          billingCity: 'New York, NY',
//                      },
//                      {
//                          name: '123556-B-B',
//                          accountName: 'Acme Corporation (VA)',
//                          employees: 410,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'John Doe',
//                          billingCity: 'New York, NY',
//                          _children: [
//                              {
//                                  name: '123556-B-B-A',
//                                  accountName: 'Allied Technologies',
//                                  employees: 390,
//                                  phone: '837-555-0100',
//                                  accountOwner:
//                                      'http://salesforce.com/fake/url/jane-doe',
//                                  accountOwnerName: 'Jane Doe',
//                                  billingCity: 'Los Angeles, CA',
//                                  _children: [
//                                      {
//                                          name: '123556-B-B-A-A',
//                                          accountName: 'Allied Technologies (UV)',
//                                          employees: 270,
//                                          phone: '837-555-0100',
//                                          accountOwner:
//                                              'http://salesforce.com/fake/url/jane-doe',
//                                          accountOwnerName: 'John Doe',
//                                          billingCity: 'San Francisco, CA',
//                                      },
//                                  ],
//                              },
//                          ],
//                      },
//                  ],
//              },
//          ],
//      },
 
//      {
//          name: '123557',
//          orderLineItemID: '8023K0000026elcQAA',
//          employees: 6000,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'New York, NY',
//          _children: [
//              {
//                  name: '123557-A',
//                  accountName: 'Rhode Enterprises (UCA)',
//                  employees: 2540,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'New York, NY',
//              },
//          ],
//      },
 
//      {
//          name: '123558',
//          orderLineItemID: '8023K0000026elcQAA',
//          employees: 1856,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'New York, NY',
//          _children: [
//              {
//                  name: '123558-A',
//                  accountName: 'Opportunity Resources Inc',
//                  employees: 1934,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'Los Angeles, CA',
//              },
//          ],
//      },
//  ];

//  export const EXAMPLES_DATA_BASIC1 = THIS.orderValues;
 
//  /**
//   * Sample data
//   * :: used by lazy loading example
//   */
//  export const EXAMPLES_DATA_LAZY_LOADING = [
//      {
//          name: '123555',
//          accountName: 'Rewis Inc',
//          employees: 3100,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'Jane Doe',
//          billingCity: 'Phoeniz, AZ',
//      },
 
//      {
//          name: '123556',
//          accountName: 'Acme Corporation',
//          employees: 10000,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'San Francisco, CA',
//          _children: [
//              {
//                  name: '123556-A',
//                  accountName: 'Acme Corporation (Bay Area)',
//                  employees: 3000,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'New York, NY',
//                  _children: [],
//              },
 
//              {
//                  name: '123556-B',
//                  accountName: 'Acme Corporation (East)',
//                  employees: 430,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'San Francisco, CA',
//                  _children: [
//                      {
//                          name: '123556-B-A',
//                          accountName: 'Acme Corporation (NY)',
//                          employees: 1210,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'Jane Doe',
//                          billingCity: 'New York, NY',
//                      },
//                      {
//                          name: '123556-B-B',
//                          accountName: 'Acme Corporation (VA)',
//                          employees: 410,
//                          phone: '837-555-0100',
//                          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                          accountOwnerName: 'John Doe',
//                          billingCity: 'New York, NY',
//                          _children: [],
//                      },
//                  ],
//              },
//          ],
//      },
 
//      {
//          name: '123557',
//          accountName: 'Rhode Enterprises',
//          employees: 6000,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'New York, NY',
//          _children: [
//              {
//                  name: '123557-A',
//                  accountName: 'Rhode Enterprises (UCA)',
//                  employees: 2540,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'New York, NY',
//              },
//          ],
//      },
 
//      {
//          name: '123558',
//          accountName: 'Tech Labs',
//          employees: 1856,
//          phone: '837-555-0100',
//          accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//          accountOwnerName: 'John Doe',
//          billingCity: 'New York, NY',
//          _children: [
//              {
//                  name: '123558-A',
//                  accountName: 'Opportunity Resources Inc',
//                  employees: 1934,
//                  phone: '837-555-0100',
//                  accountOwner: 'http://salesforce.com/fake/url/jane-doe',
//                  accountOwnerName: 'John Doe',
//                  billingCity: 'Los Angeles, CA',
//              },
//          ],
//      },
//  ];