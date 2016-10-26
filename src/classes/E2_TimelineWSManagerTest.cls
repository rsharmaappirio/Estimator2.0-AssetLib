/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWSManager
 * Description: This is a manager test class for E2_TimelineWSManager
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
 * 17 Oct 2016: Modified RS : I-239841 : Condition added to save Phase on copy paste, method updateResourceWeeks
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_TimelineWSManagerTest {
  public static CMC_Presales_LOE__c estimate;
  public static pse__Rate_Card__c rateCard;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static CMC_Estimate_Resource__c resource;
  public static CMC_Estimate_Week__c week;
  public static CMC_Estimate_Resource_Week__c resWeek;
  public static E2_Estimate_Milestone__c milestone;
  public static E2_Estimate_Milestone_Week__c milestoneWeek;
  
  //test method
  public static testmethod void testWSMangerMethods(){
    estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
    rateCard = [SELECT Id FROM pse__Rate_Card__c];
    estimateRC = [SELECT Id FROM E2_Estimate_Rate_Card__c];
    resource = [SELECT Id FROM CMC_Estimate_Resource__c];
    week = [SELECT Id FROM CMC_Estimate_Week__c];
    resWeek = [SELECT Id FROM CMC_Estimate_Resource_Week__c];
    milestone = [SELECT Id FROM E2_Estimate_Milestone__c ];
    milestoneWeek = [SELECT Id FROM E2_Estimate_Milestone_Week__c ];
      
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
        string skill = E2_TimelineWSManager.updateSkill(estimate.Id, resource.Id, 'Salesforce');
        system.assertEquals(skill, 'Success');
        system.assert(E2_TimelineWSManager.updateSkill(null, null, 'Salesforce') <> null);
        
        List<E2_Estimate_Rate_Card__c> rcList = E2_TimelineWSManager.getEstimateRateCards(estimate.Id);
        system.assert(rcList.size() > 0);
        string phase = E2_TimelineWSManager.updatePhase(week.Id, 'Plan');
        system.assert(phase == week.Id);
        string phaseErr = E2_TimelineWSManager.updatePhase(null, 'Plan');
        system.assert(phase <> null);
        
        string milestoneStr = E2_TimelineWSManager.updateMilestone(week.Id, null);
        system.assert(milestoneStr == week.Id);
        string milestoneStrErr = E2_TimelineWSManager.updateMilestone(null, null);
        system.assert(milestoneStrErr <> null);
        
        String jsonColor1 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"phase"}]';
        string colorStr1 = E2_TimelineWSManager.updateColorCode(jsonColor1);
        system.assertEquals(colorStr1,'Success');

        String jsonColor2 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone"}]';
        string colorStr2 = E2_TimelineWSManager.updateColorCode(jsonColor2);
        system.assertEquals(colorStr2,'Success');
        
        String jsonColor3 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone1"}]';
      string colorStr3 = E2_TimelineWSManager.updateColorCode(jsonColor3);
      system.assertEquals(colorStr3,'Success');
      
      String jsonColor4 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone2"}]';
      string colorStr4 = E2_TimelineWSManager.updateColorCode(jsonColor4);
      system.assertEquals(colorStr4,'Success');
          
        string phaseColStr = E2_TimelineWSManager.updatePhaseColorCode(week.Id, 'Green'); 
        system.assert(phaseColStr<>null);
        string phaseColStr1 = E2_TimelineWSManager.updatePhaseColorCode(null, 'Green'); 
        system.assert(phaseColStr1<>null);
        
        string phaseandcolor = E2_TimelineWSManager.updatePhaseAndColorCode(week.Id, 'Plan', 'Green');
        system.assert(phaseandcolor == week.Id);
        string phaseandcolorErr = E2_TimelineWSManager.updatePhaseAndColorCode(null, 'Plan', 'Green');
        system.assert(phaseandcolorErr <> null);
          
        string milestoneColStr = E2_TimelineWSManager.updateMilestoneColorCode(week.Id, 'Red');
        system.assert(milestoneColStr <> null);
        string milestoneColStrErr = E2_TimelineWSManager.updateMilestoneColorCode(null, 'Red');
        system.assert(milestoneColStrErr <> null);
        
        string milestoneColStr1 = E2_TimelineWSManager.updateMilestoneColorCode1(week.Id, 'Brown');
      system.assert(milestoneColStr1 <> null);
      string milestoneColStr1Err = E2_TimelineWSManager.updateMilestoneColorCode1(null, 'Brown');
      system.assert(milestoneColStr1Err <> null);
      
      string milestoneColStr2 = E2_TimelineWSManager.updateMilestoneColorCode2(week.Id, 'Green');
      system.assert(milestoneColStr2 <> null);
      string milestoneColStr2Err = E2_TimelineWSManager.updateMilestoneColorCode2(null, 'Green');
      system.assert(milestoneColStr2Err <> null);
      
      string milestone1 = E2_TimelineWSManager.updateMilestone1(week.Id, 'milestone1');
      system.assert(milestone1 <> null);
      string milestone1Err = E2_TimelineWSManager.updateMilestone1(null, 'milestone1');
      system.assert(milestone1Err <> null);
      
      string milestone2 = E2_TimelineWSManager.updateMilestone2(week.Id, 'milestone2');
      system.assert(milestone2 <> null);
      string milestone2Err = E2_TimelineWSManager.updateMilestone2(null, 'milestone2');
      system.assert(milestone2Err <> null);
          
        string newRow = E2_TimelineWSManager.addRow(estimate.Id, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
        system.assert(newRow <> null);
        string newRow1 = E2_TimelineWSManager.addRow(null, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
        system.assert(newRow1 <> null);
        
        string updateRow = E2_TimelineWSManager.updateRow(estimate.Id, resource.Id, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
        system.assertEquals(updateRow, 'Success');

        string updateRow1 = E2_TimelineWSManager.updateRow(null, null, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
        system.assert(updateRow1 <> null);
        
        string addColOnLeft = E2_TimelineWSManager.addMoreColumnsOnLeft(estimate.Id, week.Id, 2);
        system.assertEquals(addColOnLeft, 'Success');

        string addColOnRight = E2_TimelineWSManager.addMoreColumnsOnRight(estimate.Id, week.Id, 4);
        system.assertEquals(addColOnRight, 'Success');

        CMC_Estimate_Week__c testweek1 = E2_TimelineWSManager.createTimelineColumnOverload(estimate.Id,system.today(),2,'Test column');
        system.assert(testweek1 <> null);
        
        string onbuildStr = E2_TimelineWSManager.onBuild(estimate.Id, '2016-05-05', 4);
        system.assert(onbuildStr <> null);
        string onbuildStr1 = E2_TimelineWSManager.onBuild(null, '2016-05-05', 4);
        system.assert(onbuildStr1 <> null);
        
        string selectchange = E2_TimelineWSManager.onStartDateSelectionChange(estimate.Id, '2017-05-05', 2, null);
        system.assert(selectchange <> null);
        
        string autoFillWithoutStr = E2_TimelineWSManager.autoFill(null);
        system.assertEquals(autoFillWithoutStr, 'Failed to process: Please note that weeks has to be defined for auto fill'); 
        
        string hours1 = E2_TimelineWSManager.updateHours(null, resource.Id, 2);
        system.assert(hours1 <> null);
        
        string hours2 = E2_TimelineWSManager.updateHours(week.Id, resource.Id, 2);
        string result = week.Id+  '-' + resource.Id;    
        system.assertEquals(hours2, result);
        
        String jsonString = '[{"resourceId":"' + resource.id + '", "weekId":"' + week.Id + '", "hours":"' + 1 +'"}]';
        string autoFillStr = E2_TimelineWSManager.autoFill(jsonString);
        system.assertEquals(autoFillStr, 'Success');
        
        String jsonString0 = '[{"weekId":"' + week.Id + '", "hours":"' + 1 +'"}]';
        string autoFillStr0 = E2_TimelineWSManager.autoFill(jsonString0);
        system.assertNotEquals(autoFillStr0, 'Success');
        
        String jsonString1 = '[{"resourceId":"' + resource.id + '", "displayOrder":"1"}]';
        string reorderStr = E2_TimelineWSManager.reOrderResources(jsonString1);
        system.assertEquals(reorderStr, 'Success');
        
        List<E2_TimelineWS.E2_TimelineRow> timelineRowLst = new List<E2_TimelineWS.E2_TimelineRow>();
        timelineRowLst = E2_TimelineWSManager.getTimelineRows(estimate.Id);
        system.assert(timelineRowLst.size() > 0);
        
        List<E2_TimelineWS.E2_TimelineColumn> timelineColLst = new List<E2_TimelineWS.E2_TimelineColumn>();
        timelineColLst = E2_TimelineWSManager.getTimelineColumns(estimate.Id);
        system.assert(timelineColLst.size() > 0);
        
        CMC_Estimate_Week__c testweek = E2_TimelineWSManager.createTimelineColumn(estimate.Id, '2016-05-05',2,'Test column');
        system.assert(testweek <> null);
        
        string deleteRow = E2_TimelineWSManager.deleteRow(resource.Id);
        system.assertEquals(deleteRow, 'Success');
        string deleteRow1 = E2_TimelineWSManager.deleteRow(null);
        system.assert(deleteRow1 <> null);
        
        string deleteCol = E2_TimelineWSManager.deleteColumn(estimate.Id, week.Id);
        system.assertEquals(deleteCol, 'Success');
        string deleteCol1 = E2_TimelineWSManager.deleteColumn(null, null);
        system.assert(deleteCol <> null);
        
        
        String jsonMilestone = '[{"weekId":"' + week.Id + '", "value":"milestone",' + '"colorCode":"Red",' + '"type":"phase"}]';
        string milestoneStr0 = E2_TimelineWSManager.updateMilestoneWeeks(jsonMilestone);
        system.assert(milestoneStr0 <> null);
        
        String jsonMilestone1 = '[{"weekId":"' + week.Id + '", "value":"milestone",' + '"colorCode":"Red",' + '"type":"milestone"}]';
        string milestoneStr1 = E2_TimelineWSManager.updateMilestoneWeeks(jsonMilestone1);
        system.assert(milestoneStr1 <> null);
        
        String jsonMilestone2 = '[{"weekId":"' + week.Id + '", "value":"milestone",' + '"colorCode":"Red",' + '"type":"milestone1"}]';
        string milestoneStr2 = E2_TimelineWSManager.updateMilestoneWeeks(jsonMilestone2);
        system.assert(milestoneStr2 <> null);
        
        String jsonMilestone3 = '[{"weekId":"' + week.Id + '", "value":"milestone",' + '"colorCode":"Red",' + '"type":"milestone2"}]';
        string milestoneStr3 = E2_TimelineWSManager.updateMilestoneWeeks(jsonMilestone3);
        system.assert(milestoneStr3 <> null);
        
        String jsonCell = '[{"rowId":"milestone",' + '"cellId":"' + week.Id +'", "value":1}]';
        string resourceWeek = E2_TimelineWSManager.updateResourceWeeks(jsonCell);
        system.assert(resourceWeek <> null);
        
        String jsonCell1 = '[{"rowId":"milestone1",' + '"cellId":"' + week.Id +'", "value":1}]';
        string resourceWeek1 = E2_TimelineWSManager.updateResourceWeeks(jsonCell1);
        system.assert(resourceWeek1 <> null);
        
        String jsonCell2 = '[{"rowId":"milestone2",' + '"cellId":"' + week.Id +'", "value":1}]';
        string resourceWeek2 = E2_TimelineWSManager.updateResourceWeeks(jsonCell2);
        system.assert(resourceWeek2 <> null);
        
        string devCapacity = E2_TimelineWSManager.updateDevCapacity(estimate.Id, 5) ;
        system.assertEquals(devCapacity, E2_Constants.BLANK + 5);
        system.assert(E2_TimelineWSManager.updateDevCapacity(null, 5)<> null);
      //stop test
      Test.stopTest();
    }
    
  }
  
  
  
  //create test data
  @testSetup 
  public static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    
    estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate;
    
    pse__Region__c region = E2_Test_Utils.insertRegion(true);
    pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
    
    rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
    
    estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
    
    resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
    week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
    resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
    milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
    milestoneWeek = E2_Test_Utils.insertMilestoneWeek(milestone.Id, week.Id, true);
    
    
    
  }

}