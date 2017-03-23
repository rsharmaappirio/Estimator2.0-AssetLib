/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineControllerTest
 * Description: Includes unit test method for E2_TimelineController class
 * Created Date: Aug 08, 2016
 * Created By: Arpita Boss (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Feb 27, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate.
*  =====================================================================*/


@isTest(seeAllData=false)
public class E2_TimelineControllerTest {
  public static Account acc1;
  public static CMC_Presales_LOE__c estimate;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static List<E2_Capacity__c> capcityList ;
  public static CMC_Estimate_Resource__c estimateResource;
  
  public static testmethod void testTimeline(){
    acc1 = [SELECT Id FROM Account];
    estimate = [SELECT Id, Discount_Percent__c,E2_Parent_Estimate__c, CurrencyIsoCode,E2_Is_specific_to_timeline__c,E2_Is_Active__c,CreatedDate,E2_Timeline_Name__c FROM CMC_Presales_LOE__c];
    capcityList = [SELECT Id FROM E2_Capacity__c];
    estimateResource = [SELECT Id, Rate__c, E2_Role__c, Role__c, Cost__c 
                          FROM CMC_Estimate_Resource__c
                          WHERE Estimate__c = : estimate.Id];
    E2_System_setting__c customsetting = new E2_System_setting__c(Refresh_Ratacard__c = true, Fixed_Fee_Buffer__c = 20, Fixed_Fee_Cost_Uplift__c = 5);
    insert customsetting;
    
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      PageReference pageRef = Page.E2_Timeline;
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
      E2_TimelineController controller = new E2_TimelineController(stdController);
      
    //   Creating timeline version from existing timeline
    
    //   String timelineJSON='[{"cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'"}]';
      String timelineJSON=getEstimateWrapper(estimate.ID,estimate.CurrencyIsoCode);
      timelineJSON=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
      timelineJSON=E2_Clone_Estimate_WSManager.cloneTimelineRateCards(timelineJSON);
      E2_Clone_Estimate_WSManager.cloneTimelineVersion(timelineJSON);
      list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
    	
      //start test
      Test.startTest();  
        controller.pageAction();
        // controller.estimateRateCards member variable has removed during implementation of multi timeline. so, updated the assert statement.[Jitendra Jangid: 02/20/2017]
        system.assert(controller.timelineEstimates.size() > 0);
        controller.newTimelineId=mappingList.get(0).newTimelineId;
        // Called controller.updateTimelineStatus() method to cover catch part.
        pageRef=controller.updateTimelineStatus();
        controller.timelineStatusActive=true;
        // Called again to cover Happy path
        pageRef=controller.updateTimelineStatus();
        
        pageRef=controller.refreshTimelineEstimates();
        controller.timelineName='Phase 0';
        pageRef=controller.updateTimelineName();
      Test.stopTest();
    }
  }
  
  private static String getEstimateWrapper(String estimateID,String CurrencyIsoCode){
       E2_Clone_Estimate_WSManager.EstimateWrapper eWrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
       eWrapper.cloneFrom=estimateID;
       eWrapper.currencyISOCode=CurrencyIsoCode;
       eWrapper.isNewTimeline=false;
       List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsEstimateWrapper=new List<E2_Clone_Estimate_WSManager.EstimateWrapper>();
       lsEstimateWrapper.add(eWrapper);
       return JSON.serialize(lsEstimateWrapper);
      
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
    
    List<pse__Rate_Card__c> rateCards = new List<pse__Rate_Card__c>();
    rateCards.add(E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false));
    rateCards.add(E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false));
    rateCards.add(E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false));
    rateCards.add(E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false));
    
    rateCards.get(0).pse__Role__c = 'Developer';
    rateCards.get(0).Code__c = 'GSDev';
    rateCards.get(1).pse__Role__c = 'Development Lead';
    rateCards.get(1).Code__c = 'GSDevL';
    rateCards.get(2).pse__Role__c = 'Business Analyst';
    rateCards.get(2).Code__c = 'GSBus';
    
    insert rateCards;
    
    //estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
    E2_Capacity__c capacity1 = new E2_Capacity__c(Estimator__c = estimate.Id, Hours__c = 40, Phase__c = 'Strategy', Role__c = 'Business Analyst');
    E2_Capacity__c capacity2 = new E2_Capacity__c(Estimator__c = estimate.Id, Hours__c = 40, Phase__c = 'Plan', Role__c = 'Business Analyst');
    E2_Capacity__c capacity3 = new E2_Capacity__c(Estimator__c = estimate.Id, Hours__c = 5, Phase__c = 'Plan', Role__c = 'Developer');
    E2_Capacity__c capacity4 = new E2_Capacity__c(Estimator__c = estimate.Id, Hours__c = 40, Phase__c = 'Build', Role__c = 'Developer');
    E2_Capacity__c capacity5 = new E2_Capacity__c(Estimator__c = estimate.Id, Hours__c = 40, Phase__c = 'Test', Role__c = 'Developer');
    
    capcityList = new List<E2_Capacity__c>();
    capcityList.add(capacity1);
    capcityList.add(capacity2);
    capcityList.add(capacity3);
    capcityList.add(capacity4);
    capcityList.add(capacity5);
    insert capcityList;
    
    estimateResource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
  }

}