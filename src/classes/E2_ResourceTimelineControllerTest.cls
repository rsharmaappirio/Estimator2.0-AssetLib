/**=====================================================================
 * Appirio, Inc
 * Name: E2_ResourceTimelineControllerTest
 * Description: Includes all unit test methods to check code coverage for E2_ResourceTimelineController class.
 * Created Date: Feb 20th, 2017
 * Created By: Jitendra Jangid (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
 * Feb 27, 2017       Jitendra Jangid     S-404442 - Create multiple timelines on an estimate.
 * Mar 03, 2017       Jitendra Jangid     S-469552 - Adding practice ID and region ID on Estimate Rate card object in e2.
*  =====================================================================*/

@isTest
private class E2_ResourceTimelineControllerTest {
  public static CMC_Presales_LOE__c estimate;
  public static User sysAdmin;

  public static testMethod void testChangeDiscount(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          controller.changeDiscount();
          estimate=[Select ID, Discount__c FROM CMC_Presales_LOE__c];
          system.assertEquals(null, estimate.Discount__c, 'Assert Failed: estimate.Discount__c field should have null value.');
          
         Test.stopTest();
     }
  }

  public static testMethod void testChangeFixedFee(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          
          estimate=[Select ID, Mode__c,Fixed_Fee_Buffer__c FROM CMC_Presales_LOE__c];
          estimate.Mode__c=E2_Constants.ESTIMATE_MODE_FIXED_FEE;
          update estimate;
          
          controller.estimate.Fixed_Fee_Buffer__c=10;
          controller.changeFixedFee();
          
          estimate=[Select Fixed_Fee_Buffer__c FROM CMC_Presales_LOE__c];
          
          system.assertEquals(10, estimate.Fixed_Fee_Buffer__c, 'Expected Fixed Fee buffer: 10 and Actual fixed fee buffer:'+estimate.Fixed_Fee_Buffer__c);
          
          
         Test.stopTest();
     }
  }
  
  public static testMethod void testChangeDiscountAmount(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          controller.discountAmount=200;
          controller.changeDiscountAmount();
          
          CMC_Estimate_Resource__c resource=[Select Total_Hours__c,Rate__c,Total_Price__c from CMC_Estimate_Resource__c];
        //   system.assertEquals(true,false, 'Total_Hours__c: '+resource.Total_Hours__c+' || Rate__c: '+resource.Rate__c+' || Total_Price__c:'+resource.Total_Price__c);
          estimate=[Select ID,Discount__c,Discount_Amount__c,Service_Fees__c,Discount_Percent__c FROM CMC_Presales_LOE__c];
          
          
          system.assertEquals(string.valueOf(200), estimate.Discount__c, 'Assert Failed: Discount amount has not been updated.');
          
          
         Test.stopTest();
     }
  }
  
  public static testMethod void testRefreshRateCardRatesAndCost(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          controller.refreshRateCardRatesAndCost();
          pse__Rate_Card__c rateCard=[SELECT ID,pse__Role__c,pse__Suggested_Bill_Rate__c,pse__Average_Cost_Rate__c FROM pse__Rate_Card__c];
          List<E2_Estimate_Rate_Card__c> lsEstimateRC=[Select ID, Resource_Role__c, Resource_Cost__c,Discounted_Rate__c,Rate_Card__c  FROM E2_Estimate_Rate_Card__c
                                                      WHERE Estimate__c =:controller.estimate.ID
                                                      AND Rate_Card__c=:rateCard.ID
                                                      AND Resource_Cost__c=:rateCard.pse__Average_Cost_Rate__c
                                                      AND Bill_Rate__c=:rateCard.pse__Suggested_Bill_Rate__c];
          system.assert(lsEstimateRC.size() == 1,'Estimate rate card should be refreshed with changes find in corresponding pse rate card.'+lsEstimateRC.size());
       
          // If level gets changed in PSE Ratecard
          rateCard=[SELECT ID,E2_Resource_Level__c FROM pse__Rate_Card__c];
          rateCard.E2_Resource_Level__c='Consultant';
          update rateCard;
          controller.refreshRateCardRatesAndCost();
          rateCard=[SELECT ID,pse__Role__c,pse__Suggested_Bill_Rate__c,pse__Average_Cost_Rate__c FROM pse__Rate_Card__c];
          lsEstimateRC=[Select ID,Resource_Level__c  FROM E2_Estimate_Rate_Card__c
                                                      WHERE Estimate__c =:controller.estimate.ID
                                                      AND Rate_Card__c=:rateCard.ID
                                                      AND Resource_Cost__c=:rateCard.pse__Average_Cost_Rate__c
                                                      AND Bill_Rate__c=:rateCard.pse__Suggested_Bill_Rate__c];
          system.assert(lsEstimateRC[0].Resource_Level__c.equals('Consultant'),'Estimate rate card should be refreshed aginst changed resorce level in corresponding pse rate card.');
          
          
          // To cover new rate card condition
          Account acc=[Select ID from Account];
          pse__Region__c region = [Select ID from pse__Region__c];
          pse__Practice__c practice = [Select ID from pse__Practice__c];
          rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, false);
          rateCard.pse__Role__c='QA Tester';
          insert rateCard;
          controller.refreshRateCardRatesAndCost();
          
          lsEstimateRC=[Select ID, Resource_Role__c, Resource_Cost__c,Discounted_Rate__c,Rate_Card__c  FROM E2_Estimate_Rate_Card__c
                                                      WHERE Estimate__c =:controller.estimate.ID];
                                                      
          system.assert(lsEstimateRC.size() == 2,'Newly created pse rate card should also be attached with estimate based on estimate currency');
          
          // Change Region and Practice of Rate Card
          region=E2_Test_Utils.insertRegion(false);
          region.Name='GS - Jaipur QA';
          insert region;
          practice=E2_Test_Utils.insertPractice(false);
          practice.Name='SFDC';
          insert practice;
          rateCard=[SELECT ID,pse__Region__c,pse__Practice__c FROM pse__Rate_Card__c WHERE pse__Role__c='QA Tester'];
          rateCard.pse__Region__c=region.ID;
          rateCard.pse__Practice__c=practice.ID;
          update rateCard;
          controller.refreshRateCardRatesAndCost();
          
          lsEstimateRC=[Select ID, Resource_Role__c, Region__c,Practice__c FROM E2_Estimate_Rate_Card__c
                                                      WHERE Estimate__c =:controller.estimate.ID AND Resource_Role__c='QA Tester' AND Region__c=:region.Name AND Practice__c=:practice.Name];
                                                      
          system.assert(lsEstimateRC.size() == 1,'Region and Practice name has not been updated in estimate rate card.');
          
          
          
         Test.stopTest();
     }
  }
  
  public static testMethod void testUpdateEstimateRateCards(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          controller.pageAction();
          controller.updateEstimateRateCards();
          
          
         Test.stopTest();
     }
  }
  
  public static testMethod void testchangeEstimateModes(){
     sysAdmin= getSysAdminUser();
     System.runAs(sysAdmin){
         Test.startTest();
          E2_ResourceTimelineController controller = getE2_ResourceTimelineController();
          controller.estimate_Mode=E2_Constants.ESTIMATE_MODE_FIXED_FEE;
          controller.changeEstimateMode();
          
          estimate=[Select Mode__c FROM CMC_Presales_LOE__c];
          system.assertEquals(E2_Constants.ESTIMATE_MODE_FIXED_FEE, estimate.Mode__c, 'Assert Failed: Estimate mode should have value as fixed');
          
          controller.estimate.Fixed_Fee_Buffer__c=0;
          controller.estimate_Mode=E2_Constants.ESTIMATE_MODE_FIXED_FEE;
          controller.changeEstimateMode();
          
           estimate=[Select Mode__c FROM CMC_Presales_LOE__c];
          system.assertEquals(E2_Constants.ESTIMATE_MODE_FIXED_FEE, estimate.Mode__c, 'Assert Failed: Estimate mode should have value as fixed');
          
          
         Test.stopTest();
     }
  }
  
  private static E2_ResourceTimelineController getE2_ResourceTimelineController(){
      
      estimate = [SELECT ID, Name, Service_Fees__c,Service_Costs__c,Service_Margin__c,Calculated_Fees__c,Calculated_Costs__c,Calculated_Margin__c,
                        Discount_Percent__c,Discount_Amount__c,Discount__c,Total_Fees__c,As_Sold_Margin__c,Final_Total__c,Blended_Rate_Number__c,
                        Offshore_Blend__c,Ratecard_JSON__c,Mode__c,Services_Uplifted_Costs__c,Fixed_Fee_Cost_Uplift__c,
                        Fixed_Fee_Cost_Uplift_Percent__c,Fixed_Fee_Buffer__c,Fixed_Fee_Blended__c,Fixed_Fee_Buffer_Amount__c,
                        Topcoder_Challenge_Fees__c,Asset_Fees__c,Total_Resource_Hours__c,E2_Estimate_Total_Weeks__c,CurrencyISOCode FROM CMC_Presales_LOE__c];
     
      PageReference pageRef = Page.E2_Timeline;
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
      E2_ResourceTimelineController controller = new E2_ResourceTimelineController(stdController);
      
      return controller;
      
  }
  
  private static User getSysAdminUser(){
      User admin=[Select Id from user where firstName='test user' AND lastname='Testing'];
      return admin;
  }
  
  @testSetup
  private static void createTestData(){
    sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    Account acc = E2_Test_Utils.insertAccount(false);
    acc.Name= 'Appirio';
    insert acc;
    
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    pse__Region__c region = E2_Test_Utils.insertRegion(true);
    pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
    
    pse__Rate_Card__c rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
    
    E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, false);
    estimateRC.CurrencyIsoCode=E2_Constants.CURRENCY_ISO_CODE_USD;
    estimateRC.Rate_Card__c=rateCard.ID;
    estimateRC.Discounted_Rate__c=1000;
    estimateRC.Resource_Cost__c=70;
    estimateRC.Practice__c=practice.Name;
    estimateRC.Region__c=region.Name;
    estimateRC.Resource_Role__c='Developer';
    insert estimateRC;
    
    CMC_Estimate_Resource__c resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, false);
    resource.E2_Estimate_Rate_Card__c = estimateRC.ID;
    resource.CurrencyIsoCode=E2_Constants.CURRENCY_ISO_CODE_USD;
    resource.E2_Role__c=practice.Name+' - '+region.Name+' - '+estimateRC.Resource_Role__c;
    insert resource;
    
    CMC_Estimate_Week__c week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
    CMC_Estimate_Resource_Week__c resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
    E2_Estimate_Week_Milestone__c weekMilestones = new E2_Estimate_Week_Milestone__c(Name = 'Week1',Estimate__c = estimate.Id, Order__c = 2,
                                                         Date__c = system.today());
    insert weekMilestones;
    E2_Estimate_Milestone__c milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
    E2_Estimate_Milestone_Week__c milestoneWk = new E2_Estimate_Milestone_Week__c(Estimate_Milestone__c = milestone.Id, Estimate_Week_Milestone__c = weekMilestones.Id, 
                                                         TextColorCode__c = 'Red'); 
    insert milestoneWk;
  }

}