/**=====================================================================
 * Appirio, Inc
 * Name: E2_CustomerTimelineControllerTest
 * Description: S-456643: Test class for E2_CustomerTimelineController class
 * Created Date: Feb 01st, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_CustomerTimelineControllerTest {
  public static Account acc1;
  public static CMC_Presales_LOE__c estimate;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static List<E2_Capacity__c> capcityList ;
  public static CMC_Estimate_Resource__c estimateResource;
  
  public static testmethod void testTimeLine(){
    estimate = [SELECT Id, Discount_Percent__c, CurrencyIsoCode,E2_Parent_Estimate__c FROM CMC_Presales_LOE__c];
    system.debug('estimate>>>' +estimate);
    
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      PageReference pageRef = Page.E2_Timeline;
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
      E2_CustomerTimelineController controller = new E2_CustomerTimelineController(stdController);
    	
      //start test
      Test.startTest();  
        controller.pageAction();
        controller.populateCapacityNeeds();
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