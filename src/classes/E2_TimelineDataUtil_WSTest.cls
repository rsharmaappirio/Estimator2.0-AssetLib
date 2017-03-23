@isTest(seeAllData=false)
public class E2_TimelineDataUtil_WSTest {
  public static CMC_Presales_LOE__c estimate;
  public static pse__Rate_Card__c rateCard;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static CMC_Estimate_Resource__c resource;
  public static CMC_Estimate_Week__c week;
  public static CMC_Estimate_Resource_Week__c resWeek;
  
  public static testmethod void testDataUtil(){
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
        system.assertEquals(E2_TimelineDataUtil_WS.getEstimateRateCards(estimate.Id).size(),1);
        system.assertEquals(E2_TimelineDataUtil_WS.getHoursforEstimateResourceWeek(week.Id, resource.Id).size(),1);
        Set<String> weekIds = new Set<String>();
        weekIds.add(week.Id);
        Set<String> resourceIds = new Set<String>();
        resourceIds.add(resource.Id);
        system.assertEquals(E2_TimelineDataUtil_WS.getEstimateResourceWeekRecords(weekIds, resourceIds).size(), 1);
        system.assertEquals(E2_TimelineDataUtil_WS.getCurrencyISOCodeonEstimate(estimate.Id).size(), 1);
        system.assertEquals(E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimate.Id).size(), 1);
        system.assertEquals(E2_TimelineDataUtil_WS.getEstimateResourceAndResourceWeekRec(estimate.Id).size(), 1);
        system.assertEquals(E2_TimelineDataUtil_WS.getEstimateResourceForSkill(estimate.Id, resource.Id).size(), 1);
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