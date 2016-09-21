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
        system.assert(skill <> null);
        List<E2_Estimate_Rate_Card__c> rcList = E2_TimelineWSManager.getEstimateRateCards(estimate.Id);
        system.assert(rcList.size() > 0);
        string phase = E2_TimelineWSManager.updatePhase(week.Id, 'Plan');
        system.assert(phase <> null);
        string milestoneStr = E2_TimelineWSManager.updateMilestone(week.Id, null);
        system.assert(milestoneStr <> null);
        
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
	    
	    string phaseandcolor = E2_TimelineWSManager.updatePhaseAndColorCode(week.Id, 'Plan', 'Green');
	    system.assert(phaseandcolor <> null);
	      
	    string milestoneColStr = E2_TimelineWSManager.updateMilestoneColorCode(week.Id, 'Red');
	    system.assert(milestoneColStr <> null);
	    
	    string milestoneColStr1 = E2_TimelineWSManager.updateMilestoneColorCode1(week.Id, 'Brown');
      system.assert(milestoneColStr1 <> null);
      
      string milestoneColStr2 = E2_TimelineWSManager.updateMilestoneColorCode2(week.Id, 'Green');
      system.assert(milestoneColStr2 <> null);
      
      string milestone1 = E2_TimelineWSManager.updateMilestone1(week.Id, 'milestone1');
      system.assert(milestone1 <> null);
      
      string milestone2 = E2_TimelineWSManager.updateMilestone2(week.Id, 'milestone2');
      system.assert(milestone2 <> null);
	      
        string newRow = E2_TimelineWSManager.addRow(estimate.Id, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
        system.assert(newRow <> null);
        string updateRow = E2_TimelineWSManager.updateRow(estimate.Id, resource.Id, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
        system.assertEquals(updateRow, 'Success');
        
        string addColOnLeft = E2_TimelineWSManager.addMoreColumnsOnLeft(estimate.Id, week.Id, 2);
        system.assertEquals(addColOnLeft, 'Success');
        string addColOnRight = E2_TimelineWSManager.addMoreColumnsOnRight(estimate.Id, week.Id, 4);
        system.assertEquals(addColOnRight, 'Success');
        
        string onbuildStr = E2_TimelineWSManager.onBuild(estimate.Id, '2017-05-05', 4);
        system.assert(onbuildStr <> null);
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
        
        String jsonString1 = '[{"resourceId":"' + resource.id + '", "displayOrder":"1"}]';
        string reorderStr = E2_TimelineWSManager.reOrderResources(jsonString1);
        system.assertEquals(reorderStr, 'Success');
       
        List<E2_TimelineWS.E2_TimelineRow> timelineRowLst = new List<E2_TimelineWS.E2_TimelineRow>();
        timelineRowLst = E2_TimelineWSManager.getTimelineRows(estimate.Id);
        system.assert(timelineRowLst.size() > 0);
        
        List<E2_TimelineWS.E2_TimelineColumn> timelineColLst = new List<E2_TimelineWS.E2_TimelineColumn>();
        timelineColLst = E2_TimelineWSManager.getTimelineColumns(estimate.Id);
        system.assert(timelineColLst.size() > 0);
        
        CMC_Estimate_Week__c testweek = E2_TimelineWSManager.createTimelineColumn(estimate.Id, '2013-05-05',2,'Test column');
        system.assert(testweek <> null);
        
        CMC_Estimate_Week__c testweek1 = E2_TimelineWSManager.createTimelineColumnOverload(estimate.Id,system.today(),2,'Test column');
        system.assert(testweek1 <> null);
        
        string deleteRow = E2_TimelineWSManager.deleteRow(resource.Id);
        system.assertEquals(deleteRow, 'Success');
        string deleteCol = E2_TimelineWSManager.deleteColumn(estimate.Id, week.Id);
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
        
        String jsonCell = '[{"rowId":"' + resource.Id + '", "cellId":"' + week.Id +'", "value":1}]';
        string resourceWeek = E2_TimelineWSManager.updateResourceWeeks(jsonCell);
        system.assert(resourceWeek <> null);
        
        String jsonCell1 = '[{"rowId":"' + milestone.Id + '", "cellId":"' + week.Id +'", "value":1}]';
        string resourceWeek1 = E2_TimelineWSManager.updateResourceWeeks(jsonCell1);
        system.assert(resourceWeek1 <> null);
        
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