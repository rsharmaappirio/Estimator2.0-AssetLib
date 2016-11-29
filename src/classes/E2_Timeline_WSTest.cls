/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWS
 * Description: This is a manager test class for E2_TimelineWS
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
 * 17 Oct 2016: Modified RS : I-239841 : Condition added to save Phase on copy paste, method updateResourceWeeks
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_Timeline_WSTest {
  public static CMC_Presales_LOE__c estimate;
  public static pse__Rate_Card__c rateCard;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static CMC_Estimate_Resource__c resource;
  public static CMC_Estimate_Week__c week;
  public static CMC_Estimate_Resource_Week__c resWeek;
  
  public static testmethod void testUpdateSkill() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      string skill = E2_TimelineWS.updateSkill(estimate.Id, resource.Id, 'Salesforce');
      system.assertEquals(skill, 'Success');
      system.assert(E2_TimelineWS.updateSkill(null, null, 'Salesforce') <> null);
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testGetEstimateRateCard() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      List<E2_Estimate_Rate_Card__c> rcList = E2_TimelineWS.getEstimateRateCards(estimate.Id);
      system.assert(rcList.size() > 0);
      // stop test
      Test.stopTest();
}
  } 
  
  public static testmethod void testUpdatePhase() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      string phase = E2_TimelineWS.updatePhase(week.Id, 'Plan');
      system.assert(phase == week.Id);
      string phaseErr = E2_TimelineWS.updatePhase(null, 'Plan');
      system.assert(phase <> null);
      // stop test
      Test.stopTest();
}
  } 
  
  public static testmethod void testUpdateMilestone() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      string milestoneStr = E2_TimelineWS.updateMilestone(week.Id, null);
      system.assert(milestoneStr == week.Id);
      string milestoneStrErr = E2_TimelineWS.updateMilestone(null, null);
      system.assert(milestoneStrErr <> null);
      string milestone1 = E2_TimelineWS.updateMilestone1(week.Id, 'milestone1');
      system.assert(milestone1 <> null);
      string milestone1Err = E2_TimelineWS.updateMilestone1(null, 'milestone1');
      system.assert(milestone1Err <> null);
      
      string milestone2 = E2_TimelineWS.updateMilestone2(week.Id, 'milestone2');
      system.assert(milestone2 <> null);
      string milestone2Err = E2_TimelineWS.updateMilestone2(null, 'milestone2');
      system.assert(milestone2Err <> null);
      // stop test
      Test.stopTest();
}
  } 
  
  public static testmethod void testUpdateColor() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      String jsonColor1 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"phase"}]';
        string colorStr1 = E2_TimelineWS.updateColorCode(jsonColor1);
        system.assertEquals(colorStr1,'Success');

        String jsonColor2 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone"}]';
        string colorStr2 = E2_TimelineWS.updateColorCode(jsonColor2);
        system.assertEquals(colorStr2,'Success');
        
        String jsonColor3 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone1"}]';
      string colorStr3 = E2_TimelineWS.updateColorCode(jsonColor3);
      system.assertEquals(colorStr3,'Success');
      
      String jsonColor4 = '[{"weekId":"' + week.id + '", "value":"Green", "type":"milestone2"}]';
      string colorStr4 = E2_TimelineWS.updateColorCode(jsonColor4);
      system.assertEquals(colorStr4,'Success');
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testUpdatePhaseColor() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      week = [SELECT Id FROM CMC_Estimate_Week__c];
        string phaseColStr = E2_TimelineWS.updatePhaseColorCode(week.Id, 'Green'); 
        system.assert(phaseColStr<>null);
        string phaseColStr1 = E2_TimelineWS.updatePhaseColorCode(null, 'Green'); 
        system.assert(phaseColStr1<>null);
        
        string phaseandcolor = E2_TimelineWS.updatePhaseAndColorCode(week.Id, 'Plan', 'Green');
        system.assert(phaseandcolor == week.Id);
        string phaseandcolorErr = E2_TimelineWS.updatePhaseAndColorCode(null, 'Plan', 'Green');
        system.assert(phaseandcolorErr <> null);
        
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testUpdateMilestoneColor() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      week = [SELECT Id FROM CMC_Estimate_Week__c];
        string milestoneColStr = E2_TimelineWS.updateMilestoneColorCode(week.Id, 'Red');
        system.assert(milestoneColStr <> null);
        string milestoneColStrErr = E2_TimelineWS.updateMilestoneColorCode(null, 'Red');
        system.assert(milestoneColStrErr <> null);
        
        string milestoneColStr1 = E2_TimelineWS.updateMilestoneColorCode1(week.Id, 'Brown');
      system.assert(milestoneColStr1 <> null);
      string milestoneColStr1Err = E2_TimelineWS.updateMilestoneColorCode1(null, 'Brown');
      system.assert(milestoneColStr1Err <> null);
      
      string milestoneColStr2 = E2_TimelineWS.updateMilestoneColorCode2(week.Id, 'Green');
      system.assert(milestoneColStr2 <> null);
      string milestoneColStr2Err = E2_TimelineWS.updateMilestoneColorCode2(null, 'Green');
      system.assert(milestoneColStr2Err <> null);
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testAddandUpdateTimelineRow() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      estimateRC = [SELECT Id FROM E2_Estimate_Rate_Card__c];
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      
      string newRow = E2_TimelineWS.addRow(estimate.Id, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
        system.assert(newRow <> null);
        string newRow1 = E2_TimelineWS.addRow(null, 1, 100, 200, null, null, 'Salesforce', null, estimateRC.Id);
        system.assert(newRow1 <> null);
        
        string updateRow = E2_TimelineWS.updateRow(estimate.Id, resource.Id, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
        system.assertEquals(updateRow, 'Success');

        string updateRow1 = E2_TimelineWS.updateRow(null, null, null, null, 'Salesforce', null, 100, 200, estimateRC.Id);
        system.assert(updateRow1 <> null);
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testAddNewColumn() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      	CMC_Estimate_Week__c week1 = E2_Test_Utils.insertEstimateWeek(estimate.Id, false);
    	week1.Order__c = 4;
    	insert week1;
        string addColOnLeft = E2_TimelineWS.addMoreColumnsOnLeft(estimate.Id, week.Id, 2);
        system.assertEquals(addColOnLeft, 'Success');
		
		week1 = E2_Test_Utils.insertEstimateWeek(estimate.Id, false);
    	week1.Order__c = 1;
    	insert week1;
        string addColOnRight = E2_TimelineWS.addMoreColumnsOnRight(estimate.Id, week.Id, 4);
        system.assertEquals(addColOnRight, 'Success');
        
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testUpdateOnBuildDate() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      string onbuildStr = E2_TimelineWS.onBuild(estimate.Id, '2016-05-05', 4);
        system.assert(onbuildStr <> null);
        string onbuildStr1 = E2_TimelineWS.onBuild(null, '2016-05-05', 4);
        system.assert(onbuildStr1 <> null);
        string selectchange = E2_TimelineWS.onStartDateSelectionChange(estimate.Id, '2017-05-05', 2, null);
        system.assert(selectchange <> null);
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testautoFill() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      string autoFillWithoutStr = E2_TimelineWS.autoFill(null);
        system.assertEquals(autoFillWithoutStr, 'Failed to process: Please note that weeks has to be defined for auto fill');
        
        String jsonString = '[{"resourceId":"' + resource.id + '", "weekId":"' + week.Id + '", "hours":"' + 1 +'"}]';
        string autoFillStr = E2_TimelineWS.autoFill(jsonString);
        system.assertEquals(autoFillStr, 'Success');
        
        String jsonString0 = '[{"weekId":"' + week.Id + '", "hours":"' + 1 +'"}]';
        string autoFillStr0 = E2_TimelineWS.autoFill(jsonString0);
        system.assertNotEquals(autoFillStr0, 'Success');
      // stop test
      Test.stopTest();
}
  }
  
   public static testmethod void testUpdateHours() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      string hours1 = E2_TimelineWS.updateHours(null, resource.Id, 2);
        system.assert(hours1 <> null);
        
        string hours2 = E2_TimelineWS.updateHours(week.Id, resource.Id, 2);
        string result = week.Id+  '-' + resource.Id;    
        system.assertEquals(hours2, result);
        
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testReorderResources() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      String jsonString1 = '[{"resourceId":"' + resource.id + '", "displayOrder":"1"}]';
        string reorderStr = E2_TimelineWS.reOrderResources(jsonString1);
        system.assertEquals(reorderStr, 'Success');
      // stop test
      Test.stopTest();
}
  }
  
  public static testmethod void testUpdateTimelineRowsColumn() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      week = [SELECT Id FROM CMC_Estimate_Week__c];
       List<E2_TimelineWS.E2_TimelineRow> timelineRowLst = new List<E2_TimelineWS.E2_TimelineRow>();
        timelineRowLst = E2_TimelineWS.getTimelineRows(estimate.Id);
        system.assert(timelineRowLst.size() > 0);
        
        List<E2_TimelineWS.E2_TimelineColumn> timelineColLst = new List<E2_TimelineWS.E2_TimelineColumn>();
        timelineColLst = E2_TimelineWS.getTimelineColumns(estimate.Id);
        system.assert(timelineColLst.size() > 0);
        
        resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
    	week = E2_Test_Utils.insertEstimateWeek(estimate.Id, false);
    	week.Order__c = 2;
    	insert week;
    	resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
        
        
        string deleteRow = E2_TimelineWS.deleteRow(resource.Id);
        system.assertEquals(deleteRow, 'Success');
        string deleteRow1 = E2_TimelineWS.deleteRow(null);
        system.assert(deleteRow1 <> null);
        
        string deleteCol = E2_TimelineWS.deleteColumn(estimate.Id, week.Id);
        system.assertEquals(deleteCol, 'Success');
        string deleteCol1 = E2_TimelineWS.deleteColumn(null, null);
        system.assert(deleteCol <> null);
      // stop test
      Test.stopTest();
}
  }
  
    
  public static testmethod void testUpdateWeeks() {
      User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
      estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
      resource = [SELECT Id FROM CMC_Estimate_Resource__c];
      week = [SELECT Id FROM CMC_Estimate_Week__c];
      
        
        String jsonCell = '[{"rowId":"milestone",' + '"cellId":"' + week.Id +'", "value":1, "colorCode":"#000000"}]';
        string resourceWeek = E2_TimelineWS.updateResourceWeeks(jsonCell);
        system.assert(resourceWeek <> null);
        
        String jsonCell1 = '[{"rowId":"milestone1",' + '"cellId":"' + week.Id +'", "value":1, "colorCode":"#000000"}]';
        string resourceWeek1 = E2_TimelineWS.updateResourceWeeks(jsonCell1);
        system.assert(resourceWeek1 <> null);
        
        String jsonCell2 = '[{"rowId":"milestone2",' + '"cellId":"' + week.Id +'", "value":1, "colorCode":"#000000"}]';
        string resourceWeek2 = E2_TimelineWS.updateResourceWeeks(jsonCell2);
        system.assert(resourceWeek2 <> null);
        
        String jsonCell3 = '[{"rowId":"phase",' + '"cellId":"' + week.Id +'", "value":"Plan", "colorCode":"#000000"}]';
        string resourceWeek3 = E2_TimelineWS.updateResourceWeeks(jsonCell3);
        system.assert(resourceWeek3 <> null);
        
        String jsonCell4 = '[{"rowId":"' + resource.Id + '",' + '"cellId":"' + week.Id +'", "value":8, "colorCode":"#000000"}]';
        string resourceWeek4 = E2_TimelineWS.updateResourceWeeks(jsonCell4);
        system.assert(resourceWeek4 <> null);
        
        week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
        String jsonCell5 = '[{"rowId":"' + resource.Id + '",' + '"cellId":"' + week.Id +'", "value":8, "colorCode":"#000000"}]';
        string resourceWeek5 = E2_TimelineWS.updateResourceWeeks(jsonCell5);
        system.assert(resourceWeek5 <> null);
        
      // stop test
      Test.stopTest();
	}
  }
  
  //test method
  public static testmethod void testDevCapacity(){
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
         estimate = [SELECT Id, Discount_Percent__c FROM CMC_Presales_LOE__c];
        
        string devCapacity = E2_TimelineWS.updateDevCapacity(estimate.Id, 5) ;
        system.assertEquals(devCapacity, E2_Constants.BLANK + 5);
        system.assert(E2_TimelineWS.updateDevCapacity(null, 5)<> null);
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
    week = E2_Test_Utils.insertEstimateWeek(estimate.Id, false);
    week.Order__c = 3;
    insert week;
    resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
    
  }

}