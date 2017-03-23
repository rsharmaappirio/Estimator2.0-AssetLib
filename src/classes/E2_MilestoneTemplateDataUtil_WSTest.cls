/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateDataUtil_WSTest
 * Description: S-464465: This is the test class used by E2_MilestoneTemplateDataUtil_WSTest.cls
 * Created Date: Feb 5th, 2017
 * Created By: Rohit Sharma
 * 
 * Date Modified       Modified By          Description
 * 
*  =====================================================================*/
@isTest(seeAllData = false)
public class E2_MilestoneTemplateDataUtil_WSTest{

    public static E2_Week_Milestone_Template__c week;
    public static E2_Milestone_Week_Template_Junction__c milestoneWeek;
    public static E2_Milestone_Library__c milestoneLib;
    public static E2_Timeline_Milestone__c timelineMilestone;
    
    public static testmethod void testEstimateMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTemplateMilestones(milestoneLib.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestoneWeek(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        timelineMilestone = [SELECT Id FROM E2_Timeline_Milestone__c ];
        Set<String> weekIds = new Set<String>();
        weekIds.add(week.Id);
        Set<String> milestoneIds = new Set<String>();
        milestoneIds.add(timelineMilestone.Id);
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeks(weekIds, milestoneIds).size(), 1);
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeksforWeek(week.Id, timelineMilestone.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        timelineMilestone = [SELECT Id FROM E2_Timeline_Milestone__c ];
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getMilestone(milestoneLib.Id, timelineMilestone.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testEstimateWeekMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        timelineMilestone = [SELECT Id FROM E2_Timeline_Milestone__c ];
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneAndAllWeeks(milestoneLib.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testMilestonelib(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTimelineMilestones(milestoneLib.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    public static testmethod void testWeek(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assertEquals(E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(milestoneLib.Id).size(), 1);
        Test.stopTest();
      }
    }
    
    @testSetup
    private static void createTestData(){
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
        timelineMilestone = E2_Test_Utils.insertTimelineMilestone (milestoneLib.Id, true);
        week = E2_Test_Utils.insertTemplateWeek(milestoneLib.Id, true);
        milestoneWeek = E2_Test_Utils.insertTemplateMilestoneWeek(timelineMilestone.Id, week.Id, true);
    }    


}