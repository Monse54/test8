@istest
public class Check_Account_Duplicate_Websitetest {
  @istest
    public static void AccountRecordsTrigger(){
        Account acc = new Account(name='Test Account', Website = 'www.test.com',Recordtypeid = '0123x000001dXFEAA2' );
        Account acc1 = new Account(name='Test Account1', Website = 'www.test1.com',Recordtypeid = '0123x000001dXFEAA2' );
        Account acc2 = new Account(name='Test Account2', Recordtypeid = '0123x000001dXFFAA2' );
        insert acc;
        insert acc1;
        insert acc2;
    }
}