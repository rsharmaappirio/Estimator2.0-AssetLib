/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateControllerTest
 * Description: S-464465: test class for E2_MilestoneTemplateController
 * Created Date: Feb 02th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_MilestoneTemplateControllerTest {
    public static E2_Milestone_Library__c milestoneLib;
    
    public static testmethod void testMilestoneWS(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      
      milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
      
      System.runAs(sysAdmin){
        PageReference pageRef = Page.E2_MilestoneTemplate;
        Test.setCurrentPage(pageRef);
      
        ApexPages.StandardController sc = new ApexPages.StandardController(milestoneLib);
        E2_MilestoneTemplateController controller = new E2_MilestoneTemplateController(sc);

        //start test
        Test.startTest();
        controller.pageAction();
        //stop test
        Test.stopTest();
      }
    
    }
    
    @testSetup
    private static void createTestData(){
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
    }



}