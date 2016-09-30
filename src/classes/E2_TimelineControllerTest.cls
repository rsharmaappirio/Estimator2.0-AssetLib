@isTest(seeAllData=false)
public class E2_TimelineControllerTest {
  public static Account acc1;
  public static CMC_Presales_LOE__c estimate;
  public static E2_Estimate_Rate_Card__c estimateRC;
  public static List<E2_Capacity__c> capcityList ;
  public static CMC_Estimate_Resource__c estimateResource;
  
  public static testmethod void testTimeLine(){
    acc1 = [SELECT Id FROM Account];
    estimate = [SELECT Id, Discount_Percent__c, CurrencyIsoCode FROM CMC_Presales_LOE__c];
    system.debug('estimate>>>' +estimate);
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
        id eRCId = null;
        for(E2_Estimate_Rate_Card__c eRC : controller.estimateRateCards) {
            eRC.Discounted_Rate__c = 2000;
            eRC.Resource_Cost__c = 5000;
            if(eRC.Resource_Role__c == 'Developer') {
                eRCId = eRC.Id;
            }
        }
        
        CMC_Estimate_Resource__c er = new CMC_Estimate_Resource__c();
        er.Estimate__c = estimate.Id;
        er.Role__c = 'GS - North America Delivery - Developer';
        er.E2_Role__c = 'Test Practice - GS - North America Delivery - Developer';
        er.E2_Estimate_Rate_Card__c = eRCId;
        er.Order__c = 0;
        er.Rate__c = 250;
        er.Cost__c = 105;
    	insert er;
    	
    	CMC_Estimate_Week__c ew = new CMC_Estimate_Week__c();
    	ew.Estimate__c = estimate.Id;
    	ew.Date__c = Date.Today();
    	ew.Order__c = 0;
    	insert ew;
    	
    	CMC_Estimate_Resource_Week__c erw = new CMC_Estimate_Resource_Week__c();
    	erw.Hours__c = 20;
    	erw.Estimate_Resource__c = er.Id;
    	erw.Estimate_Week__c = ew.Id;
    	insert erw;
    	
        controller.updateEstimateRateCards();
        
        
        
        List<pse__Rate_Card__c> rateCard = [SELECT Id, pse__Role__c, pse__Region__r.Name, pse__Practice__r.Name,
                  Code__c, pse__Average_Cost_Rate__c,pse__Suggested_Bill_Rate__c, CurrencyIsoCode
                  FROM pse__Rate_Card__c];
        
        for(pse__Rate_Card__c rC : rateCard) {
            rC.pse__Average_Cost_Rate__c = 30;
            rC.pse__Suggested_Bill_Rate__c = 100;
        }
        update rateCard;
        
        pse__Region__c region = [SELECT Id FROM pse__Region__c];
        pse__Practice__c practice = [SELECT Id FROM pse__Practice__c];
        List<pse__Rate_Card__c> rateCards = new List<pse__Rate_Card__c>();
        rateCards.add(E2_Test_Utils.insertRateCard(acc1.Id, region.Id, practice.Id, false));
        rateCards.add(E2_Test_Utils.insertRateCard(acc1.Id, region.Id, practice.Id, false));
        
        rateCards.get(0).pse__Role__c = 'Project Manager';
        rateCards.get(0).Code__c = 'GSPM';
        rateCards.get(1).pse__Role__c = 'BI Business Analyst';
        rateCards.get(1).Code__c = 'GSBBus';
        
        insert rateCards;
        
        
        
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