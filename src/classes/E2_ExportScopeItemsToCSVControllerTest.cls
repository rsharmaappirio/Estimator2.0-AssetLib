@isTest
private class E2_ExportScopeItemsToCSVControllerTest {
	public static CMC_Presales_LOE__c estimate;
  
  static testMethod void testExportScopeList() {
  	Profile p = [SELECT Id FROM Profile WHERE Name =: E2_Constants.PROFILE_SYS_ADMIN ];
    User sysAdmin = new User();
    sysAdmin.Id = UserInfo.getUserId(); 
    sysAdmin.profileid = p.Id;
    update sysAdmin;
    
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    
    System.runAs(sysAdmin){
    	Test.startTest();    
        PageReference pageRef = Page.E2_ExportScopeItemsToCSV;
        ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
        E2_ExportScopeItemsToCSVController controller = new E2_ExportScopeItemsToCSVController(stdController);
        controller.pageAction();
        system.assertEquals(1, controller.lstScopeWrapper.size());
      Test.stopTest();
    } 
  }
  
  @testSetup
  private static void createTestData(){
  	Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    E2_Scope__c childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Complexity__c = 'Medium';
    insert childSC;
  }
     
}