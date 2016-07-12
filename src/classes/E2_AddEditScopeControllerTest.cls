@isTest(seeAllData=false)
public class E2_AddEditScopeControllerTest {
  private static Presales_Request__c psr;
  private static CMC_Presales_LOE__c estimate;
  
  public static testmethod void testAddEditScope(){
    estimate = E2_DataUtil.getEstimateDetailOnId([SELECT Id FROM CMC_Presales_LOE__c][0].id)[0];
    //create sys admin user
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
    PageReference pageRef = Page.E2_AddEditScope;
    Test.setCurrentPage(pageRef);
    
    ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
    E2_AddEditScopeController controller = new E2_AddEditScopeController(stdController);
    //start test
    Test.startTest();
      controller.pageAction();
      System.assertEquals(controller.estimate.id, estimate.id, 'estimates are different');  
      PageReference pg = controller.buildCapacity();
      
        System.assertEquals(pg.getUrl(), Page.E2_Capacity.getURL() + '?id=' + controller.estimate.id, 'build capacity button should redirect to capacity page');
    //stop test
    Test.stopTest(); 
    //Assert to check estimate record is created
    List<CMC_Presales_LOE__c> result = [SELECT Id FROM CMC_Presales_LOE__c WHERE Id =: estimate.Id];
    system.assertEquals(result.size(),1, 'Estimate record is created');    
    }    
  }
  
  //create test data
  @testSetup
  private static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
  }
}