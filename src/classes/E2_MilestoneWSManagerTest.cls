/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneWSManagerTest
 * Description: Test class for E2_MilestoneWSManager 
 * Created Date: 
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
@isTest(seeAllData = false)
public class E2_MilestoneWSManagerTest{
    public static CMC_Presales_LOE__c estimate;
    public static E2_Estimate_Week_Milestone__c week;
    public static E2_Estimate_Milestone__c milestone;
    public static E2_Estimate_Milestone_Week__c milestoneWeek;
    public static E2_Milestone_Library__c milestoneLib, milestoneLib1;
    public static E2_Timeline_Milestone__c timelineMilestone;
    
    public static testmethod void testDeleteMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWSManager.deleteAllRows(estimate.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddMilestoneFromLib(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ].get(0);
        system.assert(E2_MilestoneWSManager.addFromTemplate(milestoneLib.Id, estimate.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUnmergeCell(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonStr1 = '[{"milestoneId":"' +milestone.Id + '", "weekId":"'+week.Id +'", "text":"Test", "textcolorcode":"Red"}]';
        system.assert(E2_MilestoneWSManager.mergeUnmerge(jsonstr1) <> null);
        
        week = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, true);
        string jsonStr2 = '[{"milestoneId":"' +milestone.Id + '", "weekId":"'+week.Id +'", "text":"Test", "textcolorcode":"Red"}]';
        system.assert(E2_MilestoneWSManager.mergeUnmerge(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateColorCode(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonStr2 = '[{"weekId":"' +week.Id + '", "rowId":"'+ milestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneWSManager.updateColorCode(jsonstr2) <> null);
        
        week = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, true);
        string jsonStr1 = '[{"weekId":"' +week.Id + '", "rowId":"'+ milestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneWSManager.updateColorCode(jsonstr1) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWSManager.updateMilestone1(estimate.Id, milestone.Id, 'milestone1') <> null);
        system.assert(E2_MilestoneWSManager.updateMilestone2(estimate.Id, milestone.Id, 'milestone 2') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateBulkText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        milestoneWeek = E2_Test_Utils.insertMilestoneWeek(milestone.Id, week.Id, true);
        
        E2_Estimate_Week_Milestone__c week2 = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, true);
        
        string jsonStr2 = '[{"milestoneId":"' +milestone.Id + '", "weekId":"'+week.Id +'", "text":"Test", "textcolorcode":"Red"},'+
                            '{"milestoneId":"' +milestone.Id + '", "weekId":"milestone1", "text":"Test", "textcolorcode":"Red"},'+
                            '{"milestoneId":"' +milestone.Id + '", "weekId":"milestone2", "text":"Test", "textcolorcode":"Red"},'+
                            '{"milestoneId":"' +milestone.Id + '", "weekId":"'+week2.Id +'", "text":"Test", "textcolorcode":"Red"}]';
        system.assert(E2_MilestoneWSManager.updateBulkText(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWSManager.updateText(week.Id, milestone.Id, 'Test') <> null);
        system.assert(E2_MilestoneWSManager.updateText(null, null, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testReorderRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonRowWrapper = '[{"milestoneId":"' +milestone.Id + '", "displayOrder":"1"}]';
        system.assert(E2_MilestoneWSManager.reOrderRows(jsonRowWrapper) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddDeleteRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWSManager.addRow(estimate.Id, 10, 'milestone1', 'milestone2') <> null);
        system.assert(E2_MilestoneWSManager.deleteRow(milestone.Id) <> null);
        system.assertNotEquals(E2_MilestoneWSManager.deleteRow(null), 'Success');
        system.assert(E2_MilestoneWSManager.addRow(null, 10, 'milestone1', 'milestone2') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        E2_Estimate_Week_Milestone__c week1 = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, false);
    	week1.Order__c = 4;
    	insert week1;
        system.assert(E2_MilestoneWSManager.addMoreColumnsOnLeft(estimate.Id, week.Id, 2) <> null);
        week1 = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, false);
    	week1.Order__c = 1;
    	insert week1;
        system.assert(E2_MilestoneWSManager.addMoreColumnsOnRight(estimate.Id, week.Id, 1) <> null);
        system.assert(E2_MilestoneWSManager.deleteColumn(estimate.Id, week.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testBuild(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWSManager.onBuild(estimate.Id, '2013-05-05', 3) <> null);
        Presales_Request__c psr = [Select ID from Presales_Request__c];
        estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
        system.assert(E2_MilestoneWSManager.onBuild(estimate.Id, '2013-05-05', 3) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testSelectionDate(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWSManager.onStartDateSelectionChange(estimate.Id, '2013-05-05', 10, 'Test') <> null);
        system.assert(E2_MilestoneWSManager.createMilestoneColumn(estimate.Id, '2013-05-05', 10, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        List<E2_MilestoneWS.E2_MilestoneRow> rowList = new List<E2_MilestoneWS.E2_MilestoneRow>();
        rowList = E2_MilestoneWSManager.getMilestoneRows(estimate.Id);
        system.assert(rowList.size() > 0);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        List<E2_MilestoneWS.E2_MilestoneColumn> colList = new List<E2_MilestoneWS.E2_MilestoneColumn>();
        colList = E2_MilestoneWSManager.getMilestoneColumns(estimate.Id);
        system.assert(colList.size() > 0);
        Test.stopTest();
      }
    }
    
    @testSetup
    private static void createTestData(){
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
        estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
        
        week = E2_Test_Utils.insertEstimateWeekMilestone(estimate.Id, false);
        week.Order__c = 3;
        insert week;
        milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
        milestoneWeek = E2_Test_Utils.insertMilestoneWeek(milestone.Id, week.Id, true);
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
        E2_Week_Milestone_Template__c milestoneTemaplateWeek=E2_Test_Utils.insertTemplateWeek(milestoneLib.ID,true);
        
        milestoneLib1 = E2_Test_Utils.insertMilestoneLibrary(false);
        milestoneLib1.Is_Active__c = false;
        insert milestoneLib1;
        timelineMilestone = E2_Test_Utils.insertTimelineMilestone (milestoneLib.Id, true);
        E2_Milestone_Week_Template_Junction__c milestoneTemplate=E2_Test_Utils.insertTemplateMilestoneWeek(Id.valueOf(timelineMilestone.ID),Id.valueOf(milestoneTemaplateWeek.ID),true);
    }



}