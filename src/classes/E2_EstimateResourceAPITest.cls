@isTest
private class E2_EstimateResourceAPITest {

// 
// (c) Appirio
//
// 2014-10-10     Will Supinski     Original
//

    static testMethod void testJSONParser() {
        Presales_Request__c psR = [SELECT Id FROM Presales_Request__c];
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
        
        System.runAs(sysAdmin){
            Test.startTest();
            List<E2_EstimateResource> resourceData = E2_EstimateResourceAPI.getResources(psr.id);
            
        //     System.assertEquals(resourceData.size(), 3);
            
        //     System.assertEquals(resourceData.get(0).role, 'Developer');
    	   // System.assertEquals(resourceData.get(0).rate, 250);
            
        //     System.assertEquals(resourceData.get(1).role, 'Development Lead');
    	   // System.assertEquals(resourceData.get(1).rate, 250);
    	   
    	   //When no SA is specified for primary estimate
    	   CMC_Presales_LOE__c estimate=[SELECT Id, default__c FROM CMC_Presales_LOE__c where E2_SA__c=null and E2_Parent_Estimate__c = null];
           estimate.default__c=true;
           update estimate;
           
           estimate=[SELECT Id, default__c FROM CMC_Presales_LOE__c where E2_SA__c!=null and E2_Parent_Estimate__c = null];
           estimate.default__c=false;
           update estimate;
           
           resourceData = E2_EstimateResourceAPI.getResources(psr.id);
            
           
            Test.stopTest();
        }
    	
    	//run the api call
    	
    	
    	//ensure there is 1 resource returned
    	
    	
    	/*
    	
    	System.assertEquals(erObj.role, 'Project Manager');
    	System.assertEquals(erObj.rate, 250);
    	System.assertEquals(erObj.regionId, 'a1oW0000000kmj9IAA');
    	*/

     }
     
     @testSetup 
  public static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    User solArchitect, accExecutive, delReviewer; 
    
    solArchitect = E2_Test_Utils.insertSysAdminUser(false);
    solArchitect.firstName = 'Test SA';
    insert solArchitect;
    
    accExecutive = E2_Test_Utils.insertSysAdminUser(false);
    accExecutive.firstName = 'Test AE';
    insert accExecutive;
    
    delReviewer = E2_Test_Utils.insertSysAdminUser(false);
    delReviewer.firstName = 'Test Reviewer';
    insert delReviewer;
    
    CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.id, false); 
    estimate.default__c = true;
    estimate.E2_SA__c = solArchitect.Id;
    estimate.Delivery_Reviewer__c = delReviewer.Id;
    estimate.Account_Executive__c = accExecutive.Id;
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
    
    E2_Estimate_Rate_Card__c e2RateCard=E2_Test_Utils.insertEstimateRateCard(estimate.ID,false);
    e2RateCard.Resource_Role__c='Developer';
    e2RateCard.Discounted_Rate__c = 2000;
    e2RateCard.Resource_Cost__c = 5000;
    e2RateCard.Rate_Card__c=rateCards.get(0).ID;
    insert e2RateCard;
    
    
    PageReference pageRef = Page.E2_Timeline;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
    E2_TimelineController controller = new E2_TimelineController(stdController);
    controller.pageAction();
    
    CMC_Estimate_Resource__c er = new CMC_Estimate_Resource__c();
    er.Estimate__c = estimate.Id;
    er.Role__c = 'GS - North America Delivery - Developer';
    er.E2_Role__c = 'Test Practice - GS - North America Delivery - Developer';
    er.E2_Estimate_Rate_Card__c = e2RateCard.ID;
    er.Rate__c = 250;
    er.Cost__c = 105;
    er.Order__c = 1;
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
	
	CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false); 
	estimate1.E2_SA__c = null;
	estimate1.default__c = false;
	estimate1.E2_Is_Active__c=false;
	estimate1.Ratecard_JSON__c =E2_Test_Utils.getRateCardJSON(E2_Constants.CURRENCY_ISO_CODE_USD) ;
    insert estimate1;
    
    CMC_Presales_LOE__c estimate2 = E2_Test_Utils.insertEstimate(psr.id, false); 
	estimate2.E2_SA__c = null;
	estimate2.default__c = false;
	estimate2.E2_Parent_Estimate__c=estimate.ID;
	estimate2.E2_Is_Active__c=true;
	estimate2.E2_Is_specific_to_timeline__c=true;
    insert estimate2;
    
    er = new CMC_Estimate_Resource__c();
    er.Estimate__c = estimate1.Id;
    er.Role__c = 'GS - North America Delivery - Development Lead';
    er.Rate__c = 250;
    er.Cost__c = 105;
    er.Order__c = 2;
	insert er;
	
	ew = new CMC_Estimate_Week__c();
	ew.Estimate__c = estimate1.Id;
	ew.Date__c = Date.Today();
	ew.Order__c = 0;
	insert ew;
	
	erw = new CMC_Estimate_Resource_Week__c();
	erw.Hours__c = 20;
	erw.Estimate_Resource__c = er.Id;
	erw.Estimate_Week__c = ew.Id;
	insert erw;
	
	er = new CMC_Estimate_Resource__c();
    er.Estimate__c = estimate1.Id;
    er.Role__c = 'Business Analyst';
    er.Rate__c = 250;
    er.Cost__c = 105;
    er.Order__c = 3;
	insert er;
	
	ew = new CMC_Estimate_Week__c();
	ew.Estimate__c = estimate1.Id;
	ew.Date__c = Date.Today();
	ew.Order__c = 0;
	insert ew;
	
	erw = new CMC_Estimate_Resource_Week__c();
	erw.Hours__c = 20;
	erw.Estimate_Resource__c = er.Id;
	erw.Estimate_Week__c = ew.Id;
	insert erw;
  }
  
  
  
}