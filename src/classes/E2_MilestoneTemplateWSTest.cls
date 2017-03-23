/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateWSTest
 * Description: S-464465: Test class for E2_MilestoneTemplateWS
 * Created Date: 
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_MilestoneTemplateWSTest{
    
    public static E2_Week_Milestone_Template__c week;
    public static E2_Milestone_Week_Template_Junction__c milestoneWeek;
    public static E2_Milestone_Library__c milestoneLib;
    public static E2_Timeline_Milestone__c timelineMilestone;
    
    public static testmethod void testDeleteMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assert(E2_MilestoneTemplateWS.deleteAllRows(milestoneLib.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUnmergeCell(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        string jsonStr1 = '[{"milestoneId":"' +timelineMilestone.Id + '", "weekId":"'+week.Id +'", "text":"Test", "textcolorcode":"Red"}]';
        system.assert(E2_MilestoneTemplateWS.mergeUnmerge(jsonstr1) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateColorCode(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        string jsonStr2 = '[{"weekId":"' +week.Id + '", "rowId":"'+ timelineMilestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneTemplateWS.updateColorCode(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        system.assert(E2_MilestoneTemplateWS.updateMilestone1(milestoneLib.Id, timelineMilestone.Id, 'milestone1') <> null);
        system.assert(E2_MilestoneTemplateWS.updateMilestone2(milestoneLib.Id, timelineMilestone.Id, 'milestone 2') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateBulkText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        string jsonStr2 = '[{"weekId":"' +week.Id + '", "rowId":"'+ timelineMilestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneTemplateWS.updateBulkText(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        system.assert(E2_MilestoneTemplateWS.updateText(week.Id, timelineMilestone.Id, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testReorderRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        string jsonRowWrapper = '[{"milestoneId":"' +timelineMilestone.Id + '", "displayOrder":"1"}]';
        system.assert(E2_MilestoneTemplateWS.reOrderRows(jsonRowWrapper) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddDeleteRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        timelineMilestone =[SELECT Id FROM E2_Timeline_Milestone__c ];
        system.assert(E2_MilestoneTemplateWS.addRow(milestoneLib.Id, 10, 'milestone1', 'milestone2') <> null);
        system.assert(E2_MilestoneTemplateWS.deleteRow(timelineMilestone.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        system.assert(E2_MilestoneTemplateWS.addMoreColumnsOnLeft(milestoneLib.Id, week.Id, 2) <> null);
        system.assert(E2_MilestoneTemplateWS.addMoreColumnsOnRight(milestoneLib.Id, week.Id, 1) <> null);
        system.assert(E2_MilestoneTemplateWS.deleteColumn(milestoneLib.Id, week.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testBuild(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assert(E2_MilestoneTemplateWS.onBuild(milestoneLib.Id, 3) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testSelectionDate(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assert(E2_MilestoneTemplateWS.onStartDateSelectionChange(milestoneLib.Id, '2013-05-05', 10, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        List<E2_MilestoneTemplateWS.E2_MilestoneRow> rowList = new List<E2_MilestoneTemplateWS.E2_MilestoneRow>();
        rowList = E2_MilestoneTemplateWS.getMilestoneRows(milestoneLib.Id);
        system.assert(rowList.size() > 0);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        List<E2_MilestoneTemplateWS.E2_MilestoneColumn> colList = new List<E2_MilestoneTemplateWS.E2_MilestoneColumn>();
        colList = E2_MilestoneTemplateWS.getMilestoneColumns(milestoneLib.Id);
        system.assert(colList.size() > 0);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneRowsColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Week_Milestone_Template__c ];
        milestoneWeek = [SELECT Id FROM E2_Milestone_Week_Template_Junction__c ];
        E2_MilestoneTemplateWS.E2_MilestoneRowColumn rwColWrap = new E2_MilestoneTemplateWS.E2_MilestoneRowColumn(milestoneWeek.Id,week.Id,'Test','Red');
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