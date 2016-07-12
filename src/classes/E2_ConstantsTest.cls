@isTest
public class E2_ConstantsTest {
    
  public static testmethod void testE2_TreeNode() {
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    System.runAs(sysAdmin){
        Test.startTest();
            E2_Constants constant = new E2_Constants();
            constant.testConstantsMethod();
        Test.stopTest();    
    }
  }
}