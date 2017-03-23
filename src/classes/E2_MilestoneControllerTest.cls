@isTest(seeAllData=false)
public class E2_MilestoneControllerTest {
    public static CMC_Presales_LOE__c estimate;
    public static E2_Estimate_Milestone__c milestone;
    public static E2_Milestone_Library__c milestoneLib;
    
    public static testmethod void testMilestoneWS(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      
      estimate = [SELECT Id, E2_Parent_Estimate__c FROM CMC_Presales_LOE__c ];
      milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
      milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
      
      System.runAs(sysAdmin){
        PageReference pageRef = Page.E2_Milestone;
        Test.setCurrentPage(pageRef);
      
        ApexPages.StandardController sc = new ApexPages.StandardController(estimate);
        E2_MilestoneController controller = new E2_MilestoneController(sc);

        //start test
        Test.startTest();
        controller.pageAction();
        controller.selectedTemplate ='Test Milestone 1';
        List<SelectOption> selOpts = controller.getAvailableMilestoneSchTemplates();
        system.assert(selOpts.size() > 0);
        //stop test
        Test.stopTest();
      }
    
    }
    
    @testSetup
    private static void createTestData(){
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
        estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
        
        milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
    }



}