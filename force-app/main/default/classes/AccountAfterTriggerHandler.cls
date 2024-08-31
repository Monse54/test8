/* Author- Wipro
* Created - as part of R1 for Project Symphony
* Purpose - Handler class for AccountAfterTrigger - update top account of the account before rollup calculation, Update revenue rollup for old hierarchy,
Update revenue rollup for new hierarchy
*/

public without sharing class AccountAfterTriggerHandler {
    // Tesing now again with the team
    //   IAccountPayableService apService = new AccountPayableService();
    IAccountERPService erpService = new AccountERPService();
    
    //This method will update the Top Account for an account before rollup calculation
    public static void updateTopAccount(Account acc)
    {
        TopAccountService.updateTopAccount(acc);
    }
    
    //This method will update the Old Parent Linked/Direct Revenue and call AccountRollup class for old hierarchy revenue rollup
    public static void onUpdateOldParentAccountRollup(Account acc, Id oldParentAccId)
    {  
        Id oldParentId = TopAccountService.updateOldParentAccRevenue(acc, oldParentAccId);
        
        //Same parameters are being passed for Direct Sales and Linked Sales revenue calculation for the same account as the linked accnt
        AccountRollupFuture.doAccountRollup(oldParentId, oldParentId);
    }
    
    //This method will call the AccountRollup class for Revenue rollup
    public static void onUpdateAccountRollup(Id accId)
    {  
        //Same parameters are being passed for Direct Sales and Linked Sales revenue calculation for the same account as the linked accnt
        AccountRollupFuture.doAccountRollup(accId, accId);
    } 
    
    public void onUpdateAccountAPICall(Map<Id, Account> AccUpdate_Map){
        for(Account acc : AccUpdate_Map.values())
        {
            System.debug('onUpdateAccountAPICall acc account stage :: '+acc.Account_Stage__c);
            System.debug('onUpdateAccountAPICall acc record type :: '+acc.RecordType.DeveloperName);
            //  AccountPayableService.createAPAccountInERP(acc.Id);
            AccountERPService.createAccountInERP(acc.Id);
        }
    }
    
    //05/01/22 This method is update the Accountlist 
    public static void AccountStatusChange(Map<Id, Account> AccUpdate_Map, String stage){
        
        AccountConstants.isStageChangeFromTrigger = true;
        List<Account> AccountList = new List<Account>();
        For(Account acc : AccUpdate_Map.values())
        {   
            System.debug('@acc account stage :: '+acc.Account_Stage__c);
            System.debug('@acc No_of_Won_Opportunities__c :: '+acc.No_of_Won_Opportunities__c);
            Account acc1 =  new Account();
            acc1.id = acc.id;
            acc1.Account_Stage__c = stage;
            if(stage == AccountConstants.ACCOUNT_STAGE_CUSTOMER){
                acc1.Account_Status__c = AccountConstants.ACCOUNT_STAGE_CUSTOMER;
            }else if(stage == AccountConstants.ACCOUNT_STAGE_PIPELINE){
                acc1.Account_Status__c = 'Pipeline';
            }
            AccountList.add(acc1);
        }
        update AccountList;
    }
    
    
    

    public void isAfterupdateHandler(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        Account oldAcc = null;
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
        Set<Id> accountIdsForNonExchangeReplenish = new Set<Id>();
        List<Account> accCurrencyUpdList = new List<Account>();
        
        for(Account acc : newMap.Values())
        {
            Id oldParentAccId = oldMap.get(acc.Id).ParentId;
            
            if(acc.ParentId != oldParentAccId) 
            {  
                //Added to update top account of the account before running rollup calculation
                updateTopAccount(acc); 
                
                system.debug('New Parent and Old Parent:'+acc.ParentId + ' '+ oldParentAccId);
                
                //Update revenue rollup for old hierarchy 
                if(oldParentAccId != null){
                    onUpdateOldParentAccountRollup(acc, oldParentAccId);
                }
                
                //Update revenue rollup for new hierarchy
                onUpdateAccountRollup(acc.Id);        
            }
            
            // API call
            // - For Pub accounts if account status changes from Draft to Submit For Integration --> send the account to MSD
            // - For rest of the accounts if account status is Awaiting Credit Update --> send the account to MSD
            
            String rtName = rtMap.get(acc.RecordTypeId).getName();
            
            if(rtName == AccountConstants.ACCOUNT_RECORDTYPE_PUBLISHER){
                system.debug('inside pub account');
                
                //Ankita: 20092022 : Removed old account stage from the condition as part of defect- SR2-14
                //if(acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_SUBMIT_FOR_INTEGRATION && oldMap.get(acc.Id).Account_Stage__c == AccountConstants.ACCOUNT_STAGE_DRAFT)
                //   if(acc.Account_Stage__c != oldMap.get(acc.Id).Account_Stage__c && acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_SUBMIT_FOR_INTEGRATION) // Removed MAID check - 23092022 : Ankita
                if(acc.Account_Stage__c != oldMap.get(acc.Id).Account_Stage__c && acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_SUBMIT_FOR_INTEGRATION && (acc.MasterAccountId__c == '' || acc.MasterAccountId__c == null)) // Added MAID check - 30092022 : Ankita
                {
                    if(acc.Delivery_Channel__c != AccountConstants.ACCOUNT_CHANNEL_IAP && acc.Delivery_Channel__c != AccountConstants.ACCOUNT_CHANNEL_EXCHANGE){
                        system.debug('inside pub account - status changed from Draft to Submit for Integration');
                        onUpdateAccountAPICall(newMap);
                    }
                }
            }else{
                
                //Ankita: 20092022 : Removed old account stage from the condition as part of defect- SR2-14
                //  if(acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_AWAITING_CREDIT_UPDATE && oldMap.get(acc.Id).Account_Stage__c == AccountConstants.ACCOUNT_STAGE_DRAFT)
                //   if(acc.Account_Stage__c != oldMap.get(acc.Id).Account_Stage__c && acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_AWAITING_CREDIT_UPDATE) // Removed MAID check - 23092022 : Ankita
                if(acc.Account_Stage__c != oldMap.get(acc.Id).Account_Stage__c && acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_AWAITING_CREDIT_UPDATE && (acc.MasterAccountId__c == '' || acc.MasterAccountId__c == null)) // Added MAID check - 30092022 : Ankita
                {
                    system.debug('inside non pub account - status changed from Draft to Awaiting Credit Update');
                    onUpdateAccountAPICall(newMap);
                    //AccountAfterTriggerHandler.onUpdateAccountAPICall1(acc.Id); //Future method cannot be called from another future / batch method
                }
            }
            
            /*
* account status "awaiting credit update" & credit limit changes from 0 to +ve value then account status becomes "prospecting"
account status "prospecting" & first opportunity is won then account status becomes "customer" 
*/
            oldAcc = oldMap.get(acc.Id);
            if(acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_AWAITING_CREDIT_UPDATE){
                if(oldAcc.Credit_Limit__c == 0 && acc.Credit_Limit__c > 0){
                    AccountStatusChange(newMap, AccountConstants.ACCOUNT_STAGE_PIPELINE);
                }
            }
            
            if(acc.No_of_Won_Opportunities__c != oldAcc.No_of_Won_Opportunities__c && acc.No_of_Won_Opportunities__c > 0){
                if(rtName == AccountConstants.ACCOUNT_RECORDTYPE_PUBLISHER)
                {
                    AccountStatusChange(newMap, AccountConstants.ACCOUNT_STAGE_CUSTOMER);
                }
                else
                {
                    if(acc.Account_Stage__c == AccountConstants.ACCOUNT_STAGE_PROSPECTING){
                        AccountStatusChange(newMap, AccountConstants.ACCOUNT_STAGE_CUSTOMER);
                    }
                }
            }
            
            //Added below code for Replenishment IO check once credit limit on Account is updated
            if(acc.Credit_Available_OO__c > oldAcc.Credit_Available_OO__c && acc.Credit_Available_OO__c > 0 &&  
              (rtName == AccountConstants.ACCOUNT_RECORDTYPE_ADVERTISER || rtName == AccountConstants.ACCOUNT_RECORDTYPE_AGENCY )){
                 accountIdsForNonExchangeReplenish.add(acc.Id); 
                 
             } 
            
            //Ankita: 09092022: SU-289 : Added below code to populate conversion Rate on Account on currency update
            if(acc.CurrencyIsoCode != oldAcc.CurrencyIsoCode && (acc.CurrencyIsoCode != null || acc.CurrencyIsoCode != ''))
            {
                accCurrencyUpdList.add(acc);
            }
        } //for
        
        if(accountIdsForNonExchangeReplenish.size() > 0)
        {
            checkForReplenishmentIO(accountIdsForNonExchangeReplenish);
        }
        
        if(accCurrencyUpdList.size() > 0)
        {
            setAccountConversionRateonUpdate(accCurrencyUpdList);
        }
    }
    
    public void checkForReplenishmentIO(Set<Id> accountIds)
    {
        
        
        
        List<Main_IO__c> mainIOs = [SELECT Id,Opportunity_Name__c,Opportunity_Name__r.IO_Conversion_Rate__c,CurrencyIsoCode,Account_Name__c FROM Main_IO__c WHERE Account_Name__c IN: accountIds 
                                    AND Non_Exchange_Replenishment_Valid__c = true
                                    AND IO_status__c NOT IN('Closed','Cancelled') Order by lastmodifieddate asc]; 
       
        map<Id,Id> accIdOppIdmap = new  map<Id,Id>();
        List<Opportunity> oppsForConversionRateUpdate = new List<Opportunity>();
        if(mainIOs.size() > 0)
        {
            for(Main_IO__c mainIO : mainIOs)
            {   
                if(!accIdOppIdmap.containsKey(mainIO.Account_Name__c))
                {
                    accIdOppIdmap.put(mainIO.Account_Name__c,mainIO.Opportunity_Name__c);
                    if(mainIO.CurrencyIsoCode!='USD' && mainIO.Opportunity_Name__r.IO_Conversion_Rate__c ==null)
                    {
                        oppsForConversionRateUpdate.add(new Opportunity(Id=mainIO.Opportunity_Name__c));
                    }
                }
                //oppIds.add(mainIO.Opportunity_Name__c);
            } 
        }

        system.debug('oppsForConversionRateUpdate++'+oppsForConversionRateUpdate);

        if(oppsForConversionRateUpdate.size()>0) 
        {
           
            update oppsForConversionRateUpdate;
        }
        


        if(accIdOppIdmap.size()>0 )
        processNonExchangeReplenishmentIO(accIdOppIdmap.values());
          
        
       
    }

    
    @future
    public static void processNonExchangeReplenishmentIO(List<Id> oppIds)
    {   
        
        Set<Id> oppIdsforreplenish = new Set<Id>();
        oppIdsforreplenish.addAll(oppIds);
        RevisionIOService.autoReplenishment = true;
        RevisionIOService.createRevisionIO(oppIdsforreplenish) ; 

    }

    //Ankita: 09092022: SU-289 : Added below code to populate conversion Rate on Account on currency update
    public static void setAccountConversionRateonUpdate(List<Account> accList)
    {
        Map<ID, Decimal> accIdConvRateMap = new Map<ID, Decimal>();
        Map<ID, Account> accIdMap = new Map<ID, Account>();
        Set<String> currCodes = new Set<String>();
        List<Account> accToBeUpdatedList = new List<Account>();
        String FIELD_CURRENCYCODE = 'CurrencyIsoCode';
        String FIELD_DATE='LastModifiedDate';
        
        if(accList != null && accList.size() > 0)
        {
            for(Account acc : accList)
            {
                System.debug(' the iso currency of Account-- ' + acc.Id + ' is -- ' + acc.CurrencyIsoCode );
                accIdMap.put(acc.Id, acc);
                currCodes.add(acc.CurrencyIsoCode);
                //  accIdConvRateMap.put(acc.Id, acc.CurrencyIsoCode);
            }
        }
        
        if(currCodes.size() > 0)
        {
            // Do SOQL in Dated Coversion rate and get the conversion rate  
            List<DatedConversionRate> ExchRateCache= [SELECT ISOCode, ConversionRate,StartDate, NextStartDate FROM DatedConversionRate WHERE ISOCode in :currCodes]; 
            system.debug('ExchRateCache :'+ExchRateCache);
            
            if(accIdMap.size() > 0)
            {
                for(Account acc1 : accList)
                {
                    double nRate = -1;
                    datetime dDateFieldValue = (datetime)acc1.Get(FIELD_DATE);
                    system.debug('dDateFieldValue:'+dDateFieldValue);
                    
                    for(DatedConversionRate exchRate : ExchRateCache)
                    {
                        if( acc1.Get(FIELD_CURRENCYCODE) == exchRate.ISOCode && exchRate.StartDate <= dDateFieldValue && exchRate.NextStartDate >=dDateFieldValue)
                        {
                            nRate = exchRate.ConversionRate;
                            accIdConvRateMap.put(acc1.Id, nRate);
                            system.debug('nRate:'+nRate+', for currency:'+acc1.Get(FIELD_CURRENCYCODE));
                            break;
                        }//if
                    }//for
                    //    acc1.Conversion_Rate__c = nRate;   
                } //for
            } //if
        } //if   
        
        if(accIdConvRateMap.size() > 0)
        {
            for(Id accId : accIdConvRateMap.keyset())
            {
                if(accIdMap.containsKey(accId))
                {
                    Account acc2 =  new Account();
                    acc2.id = accId;
                    acc2.Conversion_Rate__c = accIdConvRateMap.get(accId); 
                    //     accIdMap.get(accId).Conversion_Rate__c = accIdConvRateMap.get(accId);
                    //   accToBeUpdatedList.add(accIdMap.get(accId));
                    accToBeUpdatedList.add(acc2);
                } //if
            } //for
        } //if
        
        if(accToBeUpdatedList.size() > 0)
        {
            update accToBeUpdatedList;
        }
    }      
}