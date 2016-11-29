@isTest(seeAllData=false)
public class E2_MilestoneWSTest{
    public static CMC_Presales_LOE__c estimate;
    public static E2_Estimate_Week_Milestone__c week;
    public static E2_Estimate_Milestone__c milestone;
    public static E2_Estimate_Milestone_Week__c milestoneWeek;
    public static E2_Milestone_Library__c milestoneLib;
    public static E2_Timeline_Milestone__c timelineMilestone;
    
    public static testmethod void testDeleteMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWS.deleteAllRows(estimate.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddMilestoneFromLib(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
        system.assert(E2_MilestoneWS.addFromTemplate(milestoneLib.Id, estimate.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUnmergeCell(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonStr1 = '[{"milestoneId":"' +milestone.Id + '", "weekId":"'+week.Id +'", "text":"Test", "textcolorcode":"Red"}]';
        system.assert(E2_MilestoneWS.mergeUnmerge(jsonstr1) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateColorCode(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonStr2 = '[{"weekId":"' +week.Id + '", "rowId":"'+ milestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneWS.updateColorCode(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateMilestone(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWS.updateMilestone1(estimate.Id, milestone.Id, 'milestone1') <> null);
        system.assert(E2_MilestoneWS.updateMilestone2(estimate.Id, milestone.Id, 'milestone 2') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateBulkText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonStr2 = '[{"weekId":"' +week.Id + '", "rowId":"'+ milestone.Id +'", "value":"Red"}]';
        system.assert(E2_MilestoneWS.updateBulkText(jsonstr2) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testUpdateText(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWS.updateText(week.Id, milestone.Id, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testReorderRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        string jsonRowWrapper = '[{"milestoneId":"' +milestone.Id + '", "displayOrder":"1"}]';
        system.assert(E2_MilestoneWS.reOrderRows(jsonRowWrapper) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddDeleteRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
        system.assert(E2_MilestoneWS.addRow(estimate.Id, 10, 'milestone1', 'milestone2') <> null);
        system.assert(E2_MilestoneWS.deleteRow(milestone.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testAddColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        system.assert(E2_MilestoneWS.addMoreColumnsOnLeft(estimate.Id, week.Id, 2) <> null);
        system.assert(E2_MilestoneWS.addMoreColumnsOnRight(estimate.Id, week.Id, 1) <> null);
        system.assert(E2_MilestoneWS.deleteColumn(estimate.Id, week.Id) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testBuild(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWS.onBuild(estimate.Id, '2013-05-05', 3) <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testSelectionDate(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        system.assert(E2_MilestoneWS.onStartDateSelectionChange(estimate.Id, '2013-05-05', 10, 'Test') <> null);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneRows(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        estimate = [SELECT Id FROM CMC_Presales_LOE__c ];
        List<E2_MilestoneWS.E2_MilestoneRow> rowList = new List<E2_MilestoneWS.E2_MilestoneRow>();
        rowList = E2_MilestoneWS.getMilestoneRows(estimate.Id);
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
        colList = E2_MilestoneWS.getMilestoneColumns(estimate.Id);
        system.assert(colList.size() > 0);
        Test.stopTest();
      }
    }
    
    public static testmethod void testGetMilestoneRowsColumn(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      System.runAs(sysAdmin){
        Test.startTest();
        week = [SELECT Id FROM E2_Estimate_Week_Milestone__c ];
        milestoneWeek = [SELECT Id FROM E2_Estimate_Milestone_Week__c ];
        E2_MilestoneWS.E2_MilestoneRowColumn rwColWrap = new E2_MilestoneWS.E2_MilestoneRowColumn(milestoneWeek.Id,week.Id,'Test','Red');
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