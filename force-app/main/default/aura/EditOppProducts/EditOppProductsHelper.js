({
	fetchOppLineItems : function(component, event, helper) {
		// Assign server method to action variable
		var action = component.get("c.getOppLineItemsList");
		// Getting the Opportunity id from page
		var opportunityId = component.get("v.recordId");
		// Setting parameters for server method
		action.setParams({
			oppId: opportunityId
		});
		// Callback function to get the response
		action.setCallback(this, function(response) {
			// Getting the response state
			var state = response.getState();
			// Check if response state is success
			if(state === 'SUCCESS') {
				// Getting the list of OpportunityLineItems from response and storing in js variable
				let oppLineItemsList = response.getReturnValue();
				let oppLineLength = oppLineItemsList.length;
				if(oppLineItemsList) {
					for(var i=0; i<oppLineLength; i++) {
						let oppLineItem = oppLineItemsList[i];
						if(oppLineItem && oppLineItem.Start_Date__c) {
							let oppLineStartDate = new Date(oppLineItem.Start_Date__c);
							oppLineItem.oppLineStartDate = oppLineStartDate;
							let lastDayOfStartDateMonth = new Date(oppLineStartDate.getFullYear(), oppLineStartDate.getMonth() + 1, 0);
							oppLineItem.lastDayOfStartDateMonth = lastDayOfStartDateMonth;
						}
					}
					if(oppLineItemsList[oppLineLength - 1] && oppLineItemsList[oppLineLength - 1].End_Date__c) component.set("v.endDate", oppLineItemsList[oppLineLength - 1].End_Date__c);
				}
				// Set the list attribute in component with the value returned by function
				component.set("v.lineItemList", oppLineItemsList);
			}
			else {
				// Show an alert if the state is incomplete or error
				alert('Error in getting data');
			}
		});
		// Adding the action variable to the global action queue
		$A.enqueueAction(action);
	},
	
	fetchProductList : function(component, event, helper){
		var action = component.get("c.getProductList");
		action.setParams({'recordId' : component.get("v.recordId")});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
				var plValues = [];
				var ptValues = [];
				var pmValues = [];
				var pcValues = [];
				var helper = JSON.parse(response.getReturnValue());
				//var productList = helper.products;
				//var pTypes = helper.pTypes;
				//var pModels = helper.pModels;
				//var pCountrys = helper.pCountrys;
				component.set("v.recordTypeName", helper.recordType);
				component.set("v.opp", helper.opp);
				component.set("v.isAdmin", helper.isAdmin);
				/*for (var i = 0; i < productList.length; i++) {
					plValues.push({
						label: productList[i].Name,
						value: productList[i].Id
					});						
				}
				component.set("v.productList", plValues);
				for (var i = 0; i < pTypes.length; i++) {
					ptValues.push({
						label: pTypes[i],
						value: pTypes[i]
					});						
				}
				component.set("v.pTypes", ptValues);
				for (var i = 0; i < pModels.length; i++) {
					pmValues.push({
						label: pModels[i],
						value: pModels[i]
					});						
				}
				component.set("v.pModels", pmValues);
				for (var i = 0; i < pCountrys.length; i++) {
					pcValues.push({
						label: pCountrys[i],
						value: pCountrys[i]
					});						
				}
				component.set("v.pCountrys", pcValues);*/
			}else {
				alert('Error in getting data');
			}
		});
		$A.enqueueAction(action);
	},
	
	callActionAsPromise : function(component, helper, params) {
		return new Promise($A.getCallback(function(resolve, reject) {			
			let action = component.get("c.updateOppLineItems"); 
			action.setParams(params);
			action.setCallback(helper, function(a){
				var state = a.getState(); // get the response state				
				if(state == 'SUCCESS') {  
					resolve({'c':component, 'h':helper, 'r':true});
				} else {
					component.set("v.spinner", false);
					var errors = a.getError();
					if (errors) { 
						this.handleError(errors); 
					} else {
						alert('error message: ' + ', please contact administrator.');
					}
					resolve({'c':component, 'h':helper, 'r':false});
					//reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
				}
			});
			$A.enqueueAction(action);
		}));
	},

	fetchListPrice : function(component, event, helper) {
		// Assign server method to action variable
		var action = component.get("c.getPriceList");
		var lineItemList = component.get("v.lineItemList");
        console.log('lineItemList-->>'+lineItemList);
        console.log('lineItemList-->>'+JSON.stringify(lineItemList));
        let ctarget = event.currentTarget;
        let index = ctarget.dataset.value;
        if(lineItemList[index]['Id']) return;
		//var imc = lineItemList[index]['IMC_BU__c'];
		var pType = lineItemList[index]['ProductType__c'];
		var productId = lineItemList[index]['Product2Id'];
		//var cType = lineItemList[index]['Channel_Type__c'];
		var pModel = lineItemList[index]['Pricing_Model__c'];
		//var country = lineItemList[index]['Geo__c'];
		var listPrice = lineItemList[index]['ListPrice'];
		var opp = component.get("v.opp");
		var accountId = opp.AccountId;
		var linkedAccountId = opp.Brand_Name1__c;
		var currencyIsoCode = opp.CurrencyIsoCode;
		if(!pType || !pModel) return;
		var lineItemLength = lineItemList.length;
		var lastEndDate;
		for(var i=0; i<(lineItemLength-1); i++) {
			if(!(pType == lineItemList[i].ProductType__c && productId == lineItemList[i].Product2Id
			   && pModel == lineItemList[i].Pricing_Model__c)) continue;
			if(!lastEndDate && lineItemList[i] && lineItemList[i].End_Date__c) lastEndDate = lineItemList[i].End_Date__c;
			else if(lastEndDate < lineItemList[i].End_Date__c) lastEndDate = lineItemList[i].End_Date__c;
		}
		if(lineItemList[index] && !lineItemList[index]['Start_Date__c'] && lastEndDate) {
			lastEndDate = lastEndDate.split("-");
			lastEndDate = new Date(lastEndDate[0], lastEndDate[1], lastEndDate[2]);
			lastEndDate.setDate(lastEndDate.getDate() + 1);
			lineItemList[index]['Start_Date__c'] = lastEndDate.getFullYear() + "-" + (parseInt(lastEndDate.getMonth()) < 10 ? ('0' + lastEndDate.getMonth()) : lastEndDate.getMonth()) 
												+ "-" + (parseInt(lastEndDate.getDate()) < 10 ? ('0' + lastEndDate.getDate()) : lastEndDate.getDate());
		}
		component.set("v.lineItemList", lineItemList);
		action.setParams({'pType' : pType,
						  'productId' : productId,
						  'pModel' : pModel,
						  'accountId' : accountId,
						  'linkedAccountId' : linkedAccountId,
						  'currencyIsoCode' : currencyIsoCode});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
				var lPrice = response.getReturnValue();
				if(lPrice) {
					lineItemList[index]['List_Price__c'] = lPrice.List_Price__c;
					component.set("v.lineItemList", lineItemList);
				}
			} else {
				var errors = response.getError();
				if (errors) { 
					this.handleError(errors); 
				} else {
					alert('error message:' + 'Unknown error, please contact administrator.');
				}
			}
		});
		$A.enqueueAction(action);
	},

	handleError: function(errors) {
		if (errors) {
			if (errors[0] && errors[0].message) {
				console.log(errors);
				alert('error message: ' + errors[0].message);
			} else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
				console.log(errors);
				alert('error message: ' + errors[0].pageErrors[0].message);
			} else if (errors[0] && errors[0].fieldErrors) {
				console.log(errors);
				var errorsMap = errors[0].fieldErrors; 
				for (var m in errorsMap){
					for (var i=0; i<errorsMap[m].length; i++) {
						alert('error message: ' + errorsMap[m][0].message);
					}
				}
			} else {
				console.log(errors);
				alert('error message: ' + JSON.stringify(errors));
			}
		} else {
			alert('error message: ' + 'Unknown error, please contact administrator.');
		}
	}
})