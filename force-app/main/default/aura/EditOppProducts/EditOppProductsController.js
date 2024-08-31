({
	doInit : function(component, event, helper) {
		helper.fetchOppLineItems(component, event, helper);
		helper.fetchProductList(component, event, helper);
		component.set("v.todayDate", new Date());
	},
	
	handleRemoveItem : function(component, event, helper) {
		var index = event.getSource().get("v.value");
		var lineItemList = component.get("v.lineItemList");
		lineItemList.splice(index, 1);
		component.set("v.lineItemList",lineItemList);
	},
	
	handleEdit : function(component, event, helper) {
		var index = event.getSource().get("v.value");
		var lineItemList = component.get("v.lineItemList");
		var recId = lineItemList[index].Id;
		var viewRecordEvent = $A.get("e.force:navigateToURL");
		viewRecordEvent.setParams({
			"url": "/" + recId
		});
		viewRecordEvent.fire();
	},
	
	handleSubmit : function(component, event, helper) {
		var spCmp = component.find("salesPrice");
		if(spCmp.length) {
			for(var i in spCmp) {
				$A.util.removeClass(spCmp[i], "highlight");
			}
		} else {
			$A.util.removeClass(spCmp, "highlight");
		}
		var validFields = component.find('validateFields');
		let opp = component.get("v.opp");
		if(validFields != null && validFields != '' && validFields != undefined) {
			var validForm = component.find('validateFields').reduce(
				function (validSoFar, inputCmp) {
					// Displays error messages for invalid fields
					inputCmp.showHelpMessageIfInvalid();
					return validSoFar &&
						inputCmp.get(
						'v.validity'
					).valid;
				}, true);
			var itemList = component.get("v.lineItemList");
			var totalBudget = 0;
			var oProductsMap = new Map();
			var spHigherIndex = [];
			for(var i in itemList) {
				if(itemList[i].IMC_BU__c == null) {
					alert('IMC BU is mandatory.');
					return;
				}
				if(itemList[i].ProductType__c == null) {
					alert('Product Type is mandatory.');
					return;
				}
				if(itemList[i].Product2Id == null) {
					alert('Product Sub Type is mandatory.');
					return;
				}
				/*if(itemList[i].Geo__c == null) {
					alert('Geo is mandatory.');
					return;
				}
				if(itemList[i].Channel_Type__c == null) {
					alert('Channel Type is mandatory.');
					return;
				}*/
				if(itemList[i].Pricing_Model__c == null) {
					alert('Pricing Model is mandatory.');
					return;
				}
				if(itemList[i].Budget__c == null) {
					alert('Budget is mandatory.');
					return;
				}
				if(itemList[i].List_Price__c == null) {
					alert('List Price is mandatory, if list price not populated for the KPI combination please contact administrator.');
					return;
				}
				if(itemList[i].Sales_Price__c == null && itemList[i].Pricing_Model__c != 'dCPM') {
					alert('Sales Price is mandatory.');
					return;
				}
				if(itemList[i].Start_Date__c == null) {
					alert('Start Date is mandatory.');
					return;
				}
				if(itemList[i].End_Date__c == null) {
					alert('End Date is mandatory.');
					return;
				}
				if(itemList[i].End_Date__c != null && itemList[i].Start_Date__c != null && itemList[i].Start_Date__c > itemList[i].End_Date__c) {
					alert('End Date must be greater than Start Date');
					//itemList[i].End_Date__c = "";
					component.set("v.lineItemList", itemList);
					return;
				}
				if(itemList[i].Budget__c && (itemList[i].Budget__c == 0 || itemList[i].Budget__c < 0)){
					alert('Budget cannot be zero or less than 0');
					//alert('Budget cannot be zero or less than 0, when Impression is not filled');
					return;
				}/*else if(!itemList[i].Budget__c && itemList[i].Impression__c && (itemList[i].Impression__c == 0 || itemList[i].Impression__c < 0)){
					alert('Impression cannot be zero or less than 0, when Budget is not filled.');
					return false;
				}
				if(itemList[i].Impression__c && itemList[i].Budget__c){
					alert('Either of the Budget/Impression field only should be filled.');
					return false;
				}*/
				if(itemList[i].Budget__c) totalBudget = parseFloat(totalBudget) + parseFloat(itemList[i].Budget__c);
				var oProduct = itemList[i];
				var oProducts = oProductsMap.get(itemList[i].Product2Id);
				if(oProducts) {
					oProducts.push(oProduct);
				} else {
					var oProducts = [];
					oProducts.push(oProduct);
				}
				oProductsMap.set(itemList[i].Product2Id, oProducts);
				if(itemList[i].Sales_Price__c && itemList[i].List_Price__c && itemList[i].Sales_Price__c > (10 * parseFloat(itemList[i].List_Price__c))) {
					spHigherIndex.push(i);
				}
			}
		}
		/*var overlapping = false;
		if(oProductsMap) {
			oProductsMap.forEach((value, key) => {
				var oProducts = value;
				var oProductsLength = oProducts.length;
				if(oProductsLength > 1) {
					var startDate;
					var endDate;
					for(var i=0; i<oProductsLength; i++) {
						var oProduct = oProducts[i];
						if(endDate && endDate > oProduct.Start_Date__c) {
							overlapping = true;
							break;
						}
						startDate = oProduct.Start_Date__c;
						endDate = oProduct.End_Date__c;
					}
				}
			});
		}
		if(overlapping) {
			alert('Same KPI combination products can\'t have date overlapping.');
			return;
		}*/
			
		if(spHigherIndex && spHigherIndex.length > 0) {
			component.set('v.showConfirmDialogHigherSP', true);
			component.set('v.indexes', spHigherIndex);
			return;
		}
			
		if(opp.StageName == 'Closed Won') {
			if(opp && opp.Amount && opp.StageName && totalBudget) {
				if(totalBudget > opp.Amount) { 
					component.set('v.showConfirmDialog', true);
					return;
				}
			}
		}
		
		if(validForm || validFields === undefined) {
			component.set("v.spinner", true);
			var relatedProductList = component.get("v.lineItemList");
			helper.callActionAsPromise(
				component,
				helper,
				{ 'lineItemList' : JSON.stringify(relatedProductList),
				 'recordId' : component.get("v.recordId") }
			).then(function(r) {
				if(r.r == true || r.r == 'true') {
					helper.fetchOppLineItems(component, event, helper);
					component.set("v.spinner", false);
				} else if(r.r == false || r.r == 'false') {
					return;
				} else {
					alert('Error in updating Product, please contact administrator.');
				}
			})		   
		}
	},
	
	addNewRow : function(component, event, helper) {
		var lineItemList = component.get("v.lineItemList");
		var oSubType = component.get("v.opp.Opportunity_SubType__c");
		if((oSubType && oSubType != 'Etisalat' && oSubType != 'BING' && oSubType != 'Telco' && oSubType != 'Glance') 
		   || !oSubType) oSubType = 'IMC AdTech Sales';
		let lastEndDate = '';
		let startDate = '';
		var country = '';
		//var olEndDate = component.get("v.endDate");
		//if(olEndDate) lastEndDate = olEndDate;
		//if(!lastEndDate) {
		var opp = component.get("v.opp");
		if(opp.End_Date__c && lineItemList && lineItemList.length == 0) lastEndDate = opp.End_Date__c;
		if(opp.Launch_Date__c && lineItemList && lineItemList.length == 0) startDate = opp.Launch_Date__c;
		if(opp.Account.BillingCountry) country = opp.Account.BillingCountry;
		else {
			alert('Please fill the BillingCountry field of the account.');
			return;
		}
		//}
		lineItemList.push({"Name": "","IMC_BU__c":oSubType,"End_Date__c": lastEndDate,"Start_Date__c": startDate});
		component.set("v.lineItemList",lineItemList);
	},
	
	getPrice : function(component, event, helper) {
		helper.fetchListPrice(component, event, helper);
	},
	
	updateQuantity : function(component, event, helper) {
		var index = event.getSource().get("v.name");
		var lineItemList = component.get("v.lineItemList");
		var budget = lineItemList[index].Budget__c;
		var salesPrice = lineItemList[index].Sales_Price__c;
		var pModel = lineItemList[index].Pricing_Model__c;
		if(budget && salesPrice) {
			if(pModel && pModel == 'CPM') {
				lineItemList[index].Impression__c = Math.floor(budget/salesPrice * 1000);
			} else lineItemList[index].Impression__c = Math.floor(budget/salesPrice);
		}
		component.set("v.lineItemList",lineItemList);
	},
	
	validateEndDate : function(component, event, helper) {
		var opp = component.get("v.opp");
		if(opp && opp.StageName != 'Closed Won') return;
		var index = event.getSource().get("v.name");
		var lineItemList = component.get("v.lineItemList");
		var endDateString = lineItemList[index].End_Date__c;
		if(!endDateString) return;
		var endDate = new Date(endDateString);
		var todayDate = new Date();
		let firstDayOfStartDateMonth = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
		if(endDate && endDate < firstDayOfStartDateMonth) {
			alert('End Date can\'t be less than first day of current month.');
			lineItemList[index].End_Date__c = "";
			component.set("v.lineItemList", lineItemList);
			return;
		}
	},
	 
	handleConfirmDialogYes : function(component, event, helper) {
		component.set('v.showConfirmDialog', false);
		var validFields = component.find('validateFields');
		var validForm = component.find('validateFields').reduce(
			function (validSoFar, inputCmp) {
				// Displays error messages for invalid fields
				inputCmp.showHelpMessageIfInvalid();
				return validSoFar &&
					inputCmp.get(
					'v.validity'
				).valid;
			}, true);
		if(validForm || validFields === undefined) {
			component.set("v.spinner", true);
			var relatedProductList = component.get("v.lineItemList");
			helper.callActionAsPromise(
				component,
				helper,
				{ 'lineItemList' : JSON.stringify(relatedProductList),
				 'recordId' : component.get("v.recordId") }
			).then(function(r) {
				if(r.r == true || r.r == 'true') {
					helper.fetchOppLineItems(component, event, helper);
					component.set("v.spinner", false);
					alert('Opportunity successfully sent for finance team approval.');
				} else if(r.r == false || r.r == 'false') {
					return;
				} else {
					alert('Error in updating Product, please contact administrator.');
				}
			})		   
		}
	},
	 
	handleConfirmDialogNo : function(component, event, helper) {
		component.set('v.showConfirmDialog', false);
		return;
	},
	 
	handleConfirmDialogHigherSPYes : function(component, event, helper) {
		component.set('v.showConfirmDialogHigherSP', false);
		let opp = component.get("v.opp");
		var itemList = component.get("v.lineItemList");
		var totalBudget = 0;
		for(var i in itemList) {
			if(itemList[i].Budget__c) totalBudget = parseFloat(totalBudget) + parseFloat(itemList[i].Budget__c);
		}
			
		if(opp.StageName == 'Closed Won') {
			if(opp && opp.Amount && opp.StageName && totalBudget) {
				if(totalBudget > opp.Amount) { 
					component.set('v.showConfirmDialog', true);
					return;
				}
			}
		}

		var validFields = component.find('validateFields');
		if(validFields != null && validFields != '' && validFields != undefined) {
			var validForm = component.find('validateFields').reduce(
				function (validSoFar, inputCmp) {
					// Displays error messages for invalid fields
					inputCmp.showHelpMessageIfInvalid();
					return validSoFar &&
						inputCmp.get(
						'v.validity'
					).valid;
				}, true);
			if(validForm || validFields === undefined) {
				component.set("v.spinner", true);
				var relatedProductList = component.get("v.lineItemList");
				helper.callActionAsPromise(
					component,
					helper,
					{ 'lineItemList' : JSON.stringify(relatedProductList),
					 'recordId' : component.get("v.recordId") }
				).then(function(r) {
					if(r.r == true || r.r == 'true') {
						helper.fetchOppLineItems(component, event, helper);
						component.set("v.spinner", false);
					} else if(r.r == false || r.r == 'false') {
						return;
					} else {
						alert('Error in updating Product, please contact administrator.');
					}
				})		   
			}
		}
	},
	 
	handleConfirmDialogHigherSPNo : function(component, event, helper) {
		component.set('v.showConfirmDialogHigherSP', false);
		var indexes = component.get("v.indexes");
		var spCmp = component.find("salesPrice");
		if(spCmp.length) {
			for(var i in indexes) {
				$A.util.addClass(spCmp[indexes[i]], "highlight");
			}
		} else {
			$A.util.addClass(spCmp, "highlight");
		}
		return;
	},
	 
	openNotes : function(component, event, helper) {
		component.set('v.updateNotes', false);
		component.set('v.opId', '');
		var lineItemList = component.get("v.lineItemList");
		let index = event.getSource().get("v.value");
		if(lineItemList[index]['Id']) {
			component.set('v.opId', lineItemList[index]['Id']);
			component.set('v.updateNotes', true);
		}
	},
	 
	handleConfirmCancel : function(component, event, helper) {
		component.set('v.updateNotes', false);
		return;
	}
})