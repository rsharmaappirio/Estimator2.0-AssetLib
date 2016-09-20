@isTest(seeAllData=false)
public class E2_TimelineControllerTest {
  public static CMC_Presales_LOE__c estimate;
  public static pse__Rate_Card__c rateCard;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static List<E2_Capacity__c> capcityList ;
  public static CMC_Estimate_Resource__c estimateResource;
  
  public static testmethod void testTimeLine(){
    estimate = [SELECT Id, Discount_Percent__c, CurrencyIsoCode FROM CMC_Presales_LOE__c];
    system.debug('estimate>>>' +estimate);
    rateCard = [SELECT Id, pse__Role__c, pse__Region__r.Name, pse__Practice__r.Name,
                  Code__c, pse__Average_Cost_Rate__c,pse__Suggested_Bill_Rate__c, CurrencyIsoCode
                  FROM pse__Rate_Card__c];
    capcityList = [SELECT Id FROM E2_Capacity__c];
    estimateResource = [SELECT Id, Rate__c, E2_Role__c, Role__c, Cost__c 
                          FROM CMC_Estimate_Resource__c
                          WHERE Estimate__c = : estimate.Id];
    E2_System_setting__c customsetting = new E2_System_setting__c(Refresh_Ratacard__c = true);
    insert customsetting;
    
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
    System.runAs(sysAdmin){
      PageReference pageRef = Page.E2_Timeline;
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
      E2_TimelineController controller = new E2_TimelineController(stdController);
      //start test
      Test.startTest();  
        controller.pageAction();
        system.assert(controller.estimateRateCards.size() > 0);

        controller.populateCapacityNeeds();
        system.assert(controller.capacityNeeds_JSON <> null);
        
        estimateRC = controller.getEstimateRateCard(rateCard, E2_Constants.CURRENCY_ISO_CODE_USD);
        estimateRC = [SELECT Id, Estimate__c, Resource_Role__c, Region__c, Practice__c, Code__c, Rate_Card__c, 
                    CurrencyIsoCode, Bill_Rate__c, Discounted_Rate__c, Category__c 
                    FROM E2_Estimate_Rate_Card__c WHERE Estimate__c = : estimate.Id];
                    
        estimateRC.Bill_Rate__c = 2000;
        estimateRC.Resource_Cost__c = 5000;
        controller.updateEstimateRateCards();
        
        controller.refreshRateCardRatesAndCost();
        estimate.Discount_Percent__c = 5 ;
        controller.changeDiscount();
        controller.refreshOverviewPanel();
        
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