@isTest(seeAllData=false)
public class E2_RecordTypeClassTest {
  
  public static testmethod void testRecordType() {
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    System.runAs(sysAdmin){
        Test.startTest();
          E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
        Test.stopTest();    
    }
  }

}