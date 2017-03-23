@isTest(seeAllData = false)
public class E2_MilestoneDataUtil_WSTest{
    public static CMC_Presales_LOE__c estimate;
    public static E2_Estimate_Week_Milestone__c week;
    public static E2_Estimate_Milestone__c milestone;
    public static E2_Estimate_Milestone_Week__c milestoneWeek;
    public static E2_Milestone_Library__c milestoneLib;
    public static E2_Timeline_Milestone__c timelineMilestone;
    
    public static testmethod void testEstimateMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assertEquals(E2_MilestoneDataUtil_WS.getEstimateMilestones(estimate.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestoneWeek(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        Set<String> weekIds = new Set<String>();
        weekIds.add(week.Id);
        Set<String> milestoneIds = new Set<String>();
        milestoneIds.add(milestone.Id);
        system.assertEquals(E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeks(weekIds, milestoneIds).size(), 1);
        system.assertEquals(E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeksforWeek(week.Id, milestone.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assertEquals(E2_MilestoneDataUtil_WS.getMilestone(estimate.Id, milestone.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testEstimateWeekMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assertEquals(E2_MilestoneDataUtil_WS.getEstimateMilestoneAndAllWeeks(estimate.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestonelib(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assertEquals(E2_MilestoneDataUtil_WS.getTimelineMilestones(milestoneLib.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    @testSetup
    private static void createTestData(){
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
        estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
        
        week = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, true);
        milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
        milestoneWeek = E2_Test_Utils.insertMilestoneWeek(milestone.Id, week.Id, true);
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
        timelineMilestone = E2_Test_Utils.insertTimelineMilestone (milestoneLib.Id, true);
    }    


}