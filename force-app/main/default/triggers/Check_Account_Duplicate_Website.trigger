trigger Check_Account_Duplicate_Website on Account (before insert,before update) {
    {
        final String errMsg = 'The Website already exists on another Account: ';
        final String errMs = 'The Website already exists on another Account: ';
        final string errmsg1 = 'This account name already use in another Account: ';
        final string errms1 = 'This account name already use in another Account: ';
        //Set< String > WebsiteSet = new Set< String >();
        //Set< String > NameSet = new Set< String >();
        
        /*for( Account acc : Trigger.new ) {
            WebsiteSet.add( acc.Website );
            NameSet.add( acc.name );          
        }*/
        
        Map< String, Id > duplicateAccountMap = new Map< String, Id >();
        Map< String, Id > duplicateAccountName = new Map< String, Id >();
        for(Account accoun : Trigger.new){
            if(accoun.Record_Type_Name__c == 'Advertiser'){
                for( Account acc : [select Id, name, Website,RecordType.name from Account where  RecordType.name in ('Advertiser','Agency')] ){
                    duplicateAccountMap.put( acc.Website, acc.Id );
                    duplicateAccountName.put( acc.Name, acc.Id );
                }
            }else if(accoun.Record_Type_Name__c == 'Agency'){
                for( Account acc1 : [select Id, name, Website,RecordType.name from Account where  RecordType.name in ('Agency', 'Advertiser')] ){
                    duplicateAccountName.put( acc1.Name, acc1.Id );
                }
            }
        }
        if(trigger.isUpdate){
            for(Account newRecord : Trigger.new) {
            Account oldRecord = Trigger.oldMap.get(newRecord.Id);
                Id duplicateAccountId = duplicateAccountMap.get( newRecord.Website );
                Id duplicateaccountname1  = duplicateAccountName.get(newRecord.Name);
                system.debug('Old web @@@@@@@'+oldRecord.website +' new website @@@@@@@@'+newRecord.website);
            if(oldRecord.website != newRecord.website && duplicateAccountId != null) {               
                newRecord.addError(errMs);
            }else if(oldRecord.name != newRecord.Name && duplicateaccountname1 != null ){
                newRecord.addError(errMs1);
            }
        }
        }
        
        
        if(Trigger.isInsert){
            for( Account acc : Trigger.new ){
                Id duplicateAccountId = duplicateAccountMap.get( acc.Website );
                Id duplicateaccountname1  = duplicateAccountName.get(acc.Name);
                if( duplicateAccountId != null ){
                    acc.addError( errMsg + duplicateAccountId );
                }else if(duplicateaccountname1 != null){
                    acc.addError( errmsg1 + duplicateaccountname1 );
                }
            } 
        }
        /*else if(Trigger.isUpdate){
            for(Account acc : trigger.isupdate){
                if(acc.Website){
                    Id duplicateAccountId = duplicateAccountMap.get( acc.Website );  
                }
            }*/
        }
        
        
        
    }