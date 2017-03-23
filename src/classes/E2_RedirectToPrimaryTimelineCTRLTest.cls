/**=====================================================================
 * Appirio, Inc
 * Name         : E2_RedirectToPrimaryTimelineControllerTest
 * Description  : This class includes test method to run unit test over E2_RedirectToPrimaryTimelineController class.
 * Created Date : 2016-12-19
 * Created By   : Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
 * 
 * *  =====================================================================*/

@isTest
public class E2_RedirectToPrimaryTimelineCTRLTest {

  public static Presales_Request__c psr;
    
  public static testmethod void testPrimaryEstimateOnPsr(){
    
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    psr =  [SELECT Id, Name FROM Presales_Request__c];
            
    List<CMC_Presales_LOE__c> primaryEstimates = new List<CMC_Presales_LOE__c>([SELECT Id, Name 
                                                                                FROM CMC_Presales_LOE__c 
                                                                                WHERE Default__c = true]);
    PageReference pageRef = Page.E2_RedirectToPrimaryTimeline;
    Test.setCurrentPage(pageRef);
    
    System.runAs(sysAdmin){
      
      Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(psr);
        E2_RedirectToPrimaryTimelineController controller = new E2_RedirectToPrimaryTimelineController(stdController);
        
        system.assertEquals('', controller.primaryEstimateId);
        system.assertEquals('', controller.primaryEstimateType);
        
        controller.pageAction();
        
        system.assertEquals(primaryEstimates[0].Id, controller.primaryEstimateId);
       
        
      Test.stopTest(); 
    }  
  }
    
  //create test data
  @testSetup 
  public static void createTestData(){
    Account acc;
    Opportunity opp;
          
    acc = E2_Test_Utils.insertAccount(true);
    opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    
    List<CMC_Presales_LOE__c> estimates = new List<CMC_Presales_LOE__c>();
    
    estimates.add(E2_Test_Utils.insertEstimate(psr.id, false));
    estimates.add(E2_Test_Utils.insertEstimate(psr.id, false));
    estimates[0].Default__c = true;
    
    insert estimates;
  }    
}