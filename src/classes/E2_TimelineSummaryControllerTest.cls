/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineSummaryControllerTest
 * Description: Test class for E2_TimelineSummaryController apex class
 * Created Date: 2nd March, 2017
 * Created By: Jitendra Jangid (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
 * Mar 02, 2017       Jitendra Jangid     S-467328: Generate summary from the all the timelines created.
*  =====================================================================*/

@isTest(seeAllData=false)
private class E2_TimelineSummaryControllerTest {

    public static CMC_Presales_LOE__c estimate;
    public static pse__Rate_Card__c rateCard;
    public static E2_Estimate_Rate_Card__c estimateRC;
    public static CMC_Estimate_Resource__c resource;
    public static CMC_Estimate_Week__c week;
    public static CMC_Estimate_Resource_Week__c resWeek;
    public static E2_System_setting__c e2SystemSetting;
  
    public static testMethod void testGetHourSummaryMap(){
	    
	   
	   
	    E2_TimelineSummaryController timelineController=new E2_TimelineSummaryController();
	    map<id, map<string, decimal>> mapHourSummary=timelineController.getHourSummaryMap();
	}
	
	@testSetup
	public static void testDataSetup(){
	    
	    e2SystemSetting = E2_System_setting__c.getInstance();
	    e2SystemSetting.Timeline_Discounts__c='5,10,15';
	    insert e2SystemSetting;
	     
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
        insert psr;
        
        estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
        insert estimate;
        
        pse__Region__c region = E2_Test_Utils.insertRegion(true);
        pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
        
        rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
        
        rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false);
        rateCard.E2_Resource_Level__c='Senior Consultant';
        rateCard.pse__Role__c='QA Tester';
        insert rateCard;
        
        estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
        estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, false);
        estimateRC.Resource_Level__c='Senior Consultant';
        estimateRC.Rate_Card__c=rateCard.ID;
        estimateRC.Resource_Role__c='QA Tester';
        estimateRC.Region__c='GS - North America Delivery';
        insert estimateRC;
        
        resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, false);
        resource.E2_Estimate_Rate_Card__c=estimateRC.ID;
        insert resource;
        week = E2_Test_Utils.insertEstimateWeek(estimate.Id, false);
        week.Order__c = 3;
        insert week;
        resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
	}

}