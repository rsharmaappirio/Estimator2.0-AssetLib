@isTest(seeAllData=false)
public class E2_AddEditScopeTemplatesControllerTest {
  
  public static testmethod void testSelectDerivedEffort(){
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    E2_Scope_Group__c scopeGrp = E2_Test_Utils.insertScopeGroup(true);
    
    System.runAs(sysAdmin){
      //start test
        Test.startTest();
        
            PageReference pageRef = Page.E2_AddEditScopeTemplates;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(scopeGrp);
            E2_AddEditScopeTemplatesController controller = new E2_AddEditScopeTemplatesController(sc);
            //assert
            system.assertEquals(controller.scopeGroup, scopeGrp);
        //stop test    
        Test.stopTest();  
     }
  }

}