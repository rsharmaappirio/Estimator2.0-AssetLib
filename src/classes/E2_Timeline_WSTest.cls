/**=====================================================================
 * Appirio, Inc
 * Name: E2_Timeline_WSTest
 * Description: test class for E2_TimelineWS
 * Created Date: Aug 31, 2016
 * Created By: arpita Bose (Appirio)
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_Timeline_WSTest {
  public static CMC_Presales_LOE__c estimate;
  public static pse__Rate_Card__c rateCard;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static CMC_Estimate_Resource__c resource;
  public static CMC_Estimate_Week__c week;
  public static CMC_Estimate_Resource_Week__c resWeek;
  
  //test method
  public static testmethod void testWSMethods(){
    estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
    rateCard = [SELECT Id FROM pse__Rate_Card__c];
    estimateRC = [SELECT Id FROM E2_Estimate_Rate_Card__c];
    resource = [SELECT Id FROM CMC_Estimate_Resource__c];
    week = [SELECT Id FROM CMC_Estimate_Week__c];
    resWeek = [SELECT Id FROM CMC_Estimate_Resource_Week__c];
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
	      string skill = E2_TimelineWS.updateSkill(estimate.Id, resource.Id, 'Salesforce');
	      system.assert(skill <> null);
	      List<E2_Estimate_Rate_Card__c> rcList = E2_TimelineWS.getEstimateRateCards(estimate.Id);
	      system.assert(rcList.size() > 0);
	      string phase = E2_TimelineWS.updatePhase(week.Id, 'Plan');
	      system.assert(phase <> null);
	      string milestone = E2_TimelineWS.updateMilestone(week.Id, null);
	      system.assert(milestone <> null);
	      string hours = E2_TimelineWS.updateHours(week.Id, resource.Id, 2);
	      system.assert(hours <> null);
	      
	      String jsonColor = '[{"weekId":"' + week.id + '", "value":"Green", "type":"test"}]';
	      string colorStr = E2_TimelineWS.updateColorCode(jsonColor);
	      system.assertEquals(colorStr,'Success');
	      
	      string phaseColStr = E2_TimelineWS.updatePhaseColorCode(week.Id, 'Green');
	      system.assert(phaseColStr<>null);
	      
	      string milestoneColStr = E2_TimelineWS.updateMilestoneColorCode(week.Id, 'Red');
	      system.assert(milestoneColStr<>null);
	      
	      String jsonString = '[{"resourceId":"' + resource.id + '", "weekId":"' + week.Id + '", "hours":"' + 1 +'"}]';
          string autoFillStr = E2_TimelineWS.autoFill(jsonString);
          system.assertEquals(autoFillStr, 'Success');
        
          String jsonString1 = '[{"resourceId":"' + resource.id + '", "displayOrder":"1"}]';
          string reorderStr = E2_TimelineWS.reOrderResources(jsonString1);
          system.assertEquals(reorderStr, 'Success');
	      
	      List<E2_TimelineWS.E2_TimelineRow> timelineRowLst = new List<E2_TimelineWS.E2_TimelineRow>();
	      timelineRowLst = E2_TimelineWS.getTimelineRows(estimate.Id);
	      system.assert(timelineRowLst.size() > 0);
	      
	      List<E2_TimelineWS.E2_TimelineColumn> timelineColLst = new List<E2_TimelineWS.E2_TimelineColumn>();
	      timelineColLst = E2_TimelineWS.getTimelineColumns(estimate.Id);
          system.assert(timelineColLst.size() > 0);
        
          E2_TimelineWS.E2_TimelineRowColumn rowCol = new E2_TimelineWS.E2_TimelineRowColumn(null, null, 5);
        
	      string newRow = E2_TimelineWS.addRow(estimate.Id, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
	      system.assert(newRow <> null);
	      string updateRow = E2_TimelineWS.updateRow(estimate.Id, resource.Id, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
	      system.assert(updateRow <> null);
	      string deleteRow = E2_TimelineWS.deleteRow(null);
	      system.assert(deleteRow <> null);
	      string deleteCol = E2_TimelineWS.deleteColumn(estimate.Id, week.Id);
	      system.assert(deleteCol <> null);
	      string addColOnLeft = E2_TimelineWS.addMoreColumnsOnLeft(estimate.Id, week.Id, 2);
	      system.assert(addColOnLeft <> null);
	      string addColOnRight = E2_TimelineWS.addMoreColumnsOnRight(estimate.Id, week.Id, 4);
	      system.assert(addColOnRight <> null);
	      string onbuildStr = E2_TimelineWS.onBuild(estimate.Id, '2013-05-05', 4);
	      system.assert(onbuildStr <> null);
	      string selectchange = E2_TimelineWS.onStartDateSelectionChange(estimate.Id, '2013-05-05', 2, null);
	      system.assert(selectchange <> null);
	      
	      string milestoneColStr1 = E2_TimelineWS.updateMilestoneColorCode1(week.Id, 'Brown');
      system.assert(milestoneColStr1 <> null);
      
      string milestoneColStr2 = E2_TimelineWS.updateMilestoneColorCode2(week.Id, 'Green');
      system.assert(milestoneColStr2 <> null);
      
      string milestone1 = E2_TimelineWS.updateMilestone1(week.Id, 'milestone1');
      system.assert(milestone1 <> null);
      
      string milestone2 = E2_TimelineWS.updateMilestone2(week.Id, 'milestone2');
      system.assert(milestone2 <> null);
      
      string phaseandcolor = E2_TimelineWS.updatePhaseAndColorCode(week.Id, 'Plan', 'Green');
      system.assert(phaseandcolor <> null);
      
      String jsonMilestone = '[{"weekId":"' + week.Id + '", "value":"milestone",' + '"colorCode":"Red",' + '"type":"phase"}]';
      string milestoneStr = E2_TimelineWS.updateMilestoneWeeks(jsonMilestone);
      system.assert(milestoneStr <> null);
      
      string devCapacity = E2_TimelineWS.updateDevCapacity(estimate.Id, 5) ;
      system.assertEquals(devCapacity, E2_Constants.BLANK + 5);
      
      String jsonCell2 = '[{"rowId":"milestone2",' + '"cellId":"' + week.Id +'", "value":1}]';
      string resourceWeek2 = E2_TimelineWS.updateResourceWeeks(jsonCell2);
      system.assert(resourceWeek2 <> null);
        
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
    
    
    
    
  }

}