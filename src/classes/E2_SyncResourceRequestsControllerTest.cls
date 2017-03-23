@isTest
private class E2_SyncResourceRequestsControllerTest {

  //create test data
  @testSetup static void createTestData(){
    
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;

    acc = E2_Test_Utils.insertAccount(true);
    opp = E2_Test_Utils.insertOpportunity(acc.Id, false);
    opp.Name = 'TestingOppTime';
	opp.Description = 'testing description';
	opp.StageName = 'Prospecting';
	opp.CloseDate = Date.today() +300;
	insert opp;
    
    solArchitect = E2_Test_Utils.insertSysAdminUser(false);
    solArchitect.firstName = 'Test SA';
    insert solArchitect;
    
    accExecutive = E2_Test_Utils.insertSysAdminUser(false);
    accExecutive.firstName = 'Test AE';
    insert accExecutive;
    
    delReviewer = E2_Test_Utils.insertSysAdminUser(false);
    delReviewer.firstName = 'Test Reviewer';
    insert delReviewer;
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    psr.Name = 'testing JSON';
    psr.Due_Date__c = Date.today();
    psr.Date_Initial_LOE_Anticipated_By__c = Date.today() +1;
    psr.Type__c = 'Prototype/Demo';
    psr.Focus_Area__c = 'Strategy';
    psr.Description__c = 'Testing JSON testing';
    insert psr;
    
    pse__Region__c region = new pse__Region__c();
    region.Name = 'U.S. Delivery';
    region.Assignable_to_Projects__c = true;
    region.Assignable_to_Resource_Requests__c = true;
    region.Assignable_to_Resources__c = true;
    insert region;
    	
	pse__Practice__c practice = new pse__Practice__c();
	practice.Name = 'Salesforce';
	practice.Assignable_to_Projects__c = true;
	practice.Assignable_to_Resource_Requests__c = true;
	practice.Assignable_to_Resources__c = true;
	insert practice;
    
    CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
    estimate1.Default__c = true;
    estimate1.Presales_Request__c = psr.Id;
    estimate1.Name = 'Testing JSON parser';
    estimate1.Ratecard_JSON__c = '[{"Id":"a1nW0000000iOhuIAE","Resource Cost":150,"Suggested Cost":150,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Executive Sponsor","Rate Card":400,"Rate":400,"CurrencyIsoCode":"USD","Code":"ES","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOhvIAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Client Services Director","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"EM","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOhwIAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Project Manager","Rate Card":250,"Rate":250,"CurrencyIsoCode":"USD","Code":"PM","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOhxIAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Program Manager","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"PGM","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOhyIAE","Resource Cost":150,"Suggested Cost":150,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Business Architect","Rate Card":400,"Rate":400,"CurrencyIsoCode":"USD","Code":"BAR","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOhzIAE","Resource Cost":150,"Suggested Cost":150,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Strategy Consultant","Rate Card":400,"Rate":400,"CurrencyIsoCode":"USD","Code":"SC","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi0IAE","Resource Cost":150,"Suggested Cost":150,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Managing Consultant","Rate Card":400,"Rate":400,"CurrencyIsoCode":"USD","Code":"MC","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi1IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Technical Architect","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"TA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi2IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Integration Architect","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"UI-DE","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi3IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Mobile Architect","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"MA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi4IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Data Architect","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"DA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi5IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Community Architect","Rate Card":300,"Rate":300,"CurrencyIsoCode":"USD","Code":"CA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi6IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Change Lead","Rate Card":250,"Rate":250,"CurrencyIsoCode":"USD","Code":"CL","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi7IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Cloud Management Lead","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"CML","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi8IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Change Consultant","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"CC","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOi9IAE","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Trainer","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"TR","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOiAIAU","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Business Analyst","Rate Card":250,"Rate":250,"CurrencyIsoCode":"USD","Code":"BA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOiBIAU","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Release Manager","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"RM","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOiCIAU","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"QA Tester","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"QA","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOiDIAU","Resource Cost":105,"Suggested Cost":105,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"'+region.Id+'","RegionName":"'+region.Name+'","Role":"Consultant","Rate Card":225,"Rate":225,"CurrencyIsoCode":"USD","Code":"C-SC","Category":"'+region.Name+'"},{"Id":"a1nW0000000iOiEIAU","Resource Cost":60,"Suggested Cost":60,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"a1oW0000000kmikIAA","RegionName":"U.S. Indianapolis","Role":"Associate Consultant","Rate Card":200,"Rate":200,"CurrencyIsoCode":"USD","Code":"I-AC","Category":"U.S. Indianapolis"},{"Id":"a1nW0000000iOiFIAU","Resource Cost":19,"Suggested Cost":19,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"a1oW0000000kmipIAA","RegionName":"Jaipur - Delivery","Role":"QA Tester","Rate Card":85,"Rate":85,"CurrencyIsoCode":"USD","Code":"J-QA","Category":"Jaipur - Delivery"},{"Id":"a1nW0000000iOiGIAU","Resource Cost":19,"Suggested Cost":19,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"a1oW0000000kmiuIAA","RegionName":"Jaipur - Team Leads","Role":"Consultant","Rate Card":110,"Rate":110,"CurrencyIsoCode":"USD","Code":"J-L","Category":"Jaipur - Team Leads"},{"Id":"a1nW0000000iOiHIAU","Resource Cost":19,"Suggested Cost":19,"Practice":"'+practice.Id+'","PracticeName":"'+practice.Name+'","RegionId":"a1oW0000000kmipIAA","RegionName":"Jaipur - Delivery","Role":"Consultant","Rate Card":85,"Rate":85,"CurrencyIsoCode":"USD","Code":"J-DE","Category":"Jaipur - Delivery"}]';
    insert estimate1;
    
    CMC_Estimate_Resource__c er = new CMC_Estimate_Resource__c();
    er.Estimate__c = estimate1.Id;
    er.Role__c = 'U.S. Delivery - Project Manager';
    er.Order__c = 0;
    er.Rate__c = 250;
    er.Cost__c = 105;
	insert er;
	
	CMC_Estimate_Week__c ew = new CMC_Estimate_Week__c();
	ew.Estimate__c = estimate1.Id;
	ew.Date__c = Date.Today();
	ew.Order__c = 0;
	insert ew;
	
	CMC_Estimate_Resource_Week__c erw = new CMC_Estimate_Resource_Week__c();
	erw.Hours__c = 20;
	erw.Estimate_Resource__c = er.Id;
	erw.Estimate_Week__c = ew.Id;
	insert erw;
	
	CMC_Estimate_Resource__c er1 = new CMC_Estimate_Resource__c();
    er1.Estimate__c = estimate1.Id;
    er1.Role__c = 'U.S. Delivery - Strategy Consultant';
    er1.Order__c = 0;
    er1.Rate__c = 250;
    er1.Cost__c = 105;
	insert er1;
	
	CMC_Estimate_Resource_Week__c erw1 = new CMC_Estimate_Resource_Week__c();
	erw1.Hours__c = 20;
	erw1.Estimate_Resource__c = er1.Id;
	erw1.Estimate_Week__c = ew.Id;
	insert erw1;
	
	CMC_Estimate_Resource__c er2 = new CMC_Estimate_Resource__c();
    er2.Estimate__c = estimate1.Id;
    er2.Role__c = 'U.S. Delivery - Executive Sponsor';
    er2.Order__c = 0;
    er2.Rate__c = 250;
    er2.Cost__c = 105;
	insert er2;
	
	CMC_Estimate_Resource_Week__c erw2 = new CMC_Estimate_Resource_Week__c();
	erw2.Hours__c = 20;
	erw2.Estimate_Resource__c = er2.Id;
	erw2.Estimate_Week__c = ew.Id;
	insert erw2;
	
	
	
	pse__Skill__c skill = new pse__Skill__c();
	skill.Name= 'Salesforce.com';
	skill.pse__Type__c = 'Vendor Experience';
	insert skill;
	
	pse__Skill__c skill1 = new pse__Skill__c();
	skill1.Name = 'Salesforce';
	skill1.pse__Type__c = 'Vendor Experience';
	insert skill1;
	
	E2_Practice_Skills_Mappings__c psM = new E2_Practice_Skills_Mappings__c(Name = 'Salesforce',
                                                                        	Skill_Id__c = skill1.Id, 
                                                                        	Skill_Type__c = skill1.pse__Type__c,
                                                                        	Skill_Name__c = skill1.Name);
    insert psM;
	
	pse__Permission_Control__c psC = new pse__Permission_Control__c();
    psC.pse__User__c = userinfo.getuserid();
    psC.pse__Region__c = region.Id;
    psC.pse__Resource_Request_Entry__c = true;
    insert psC;
	
	pse__Resource_Request__c rr = new pse__Resource_Request__c();
	rr.pse__Resource_Role__c = 'Project Manager';
	rr.pse__Region__c = region.Id;
	rr.pse__Practice__c = practice.Id;
	rr.pse__Start_Date__c = Date.today();
	rr.pse__End_Date__c = Date.today().addDays(5);
	rr.pse__SOW_Hours__c = 8;
	rr.pse__Primary_Skill_Certification__c = skill.Id;
	rr.pse__Requested_Bill_Rate__c = 222;
	rr.pse__Opportunity__c = opp.Id;
	rr.pse__Status__c = 'Submitted';
	rr.CurrencyISOCode = 'USD';
	rr.Estimate_Resource_Id__c = er.Id;
	insert rr;
	
	pse__Resource_Request__c rr1 = new pse__Resource_Request__c();
	rr1.pse__Resource_Role__c = 'Executive Sponsor';
	rr1.pse__Region__c = region.Id;
	rr1.pse__Practice__c = practice.Id;
	rr1.pse__Start_Date__c = Date.today();
	rr1.pse__End_Date__c = Date.today().addDays(5);
	rr1.pse__SOW_Hours__c = 8;
	rr1.pse__Primary_Skill_Certification__c = skill.Id;
	rr1.pse__Requested_Bill_Rate__c = 222;
	rr1.pse__Opportunity__c = opp.Id;
	rr1.pse__Status__c = 'Submitted';
	rr1.CurrencyISOCode = 'USD';
	rr1.Estimate_Resource_Id__c = er2.Id;
	insert rr1;
	
	
  }
  
  static CMC_Presales_LOE__c estimate;
  static Opportunity opp1;
  static Presales_Request__c psr1;
  
  static testMethod void testRRrequest() {
    opp1 = [SELECT Name, Description, StageName, CloseDate FROM Opportunity];
    psr1 = [SELECT Opportunity__c, Name, Due_Date__c, Date_Initial_LOE_Anticipated_By__c, Type__c, Focus_Area__c, Description__c FROM Presales_Request__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
    pse__Region__c region = [SELECT Id FROM pse__Region__c];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    pse__Permission_Control__c psC = new pse__Permission_Control__c();
    psC.pse__User__c = sysAdmin.Id;
    psC.pse__Region__c = region.Id;
    psC.pse__Resource_Request_Entry__c = true;
    insert psC;
    System.runAs(sysAdmin){
        Test.startTest();
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp1);
    	E2_SyncResourceRequestsController srrc = new E2_SyncResourceRequestsController(stdOpp);
    	List<SelectOption> psrNames = srrc.getPresalesRequests();
    	System.assertEquals( psrNames.size(), 1);
    	System.assertEquals( psrNames[0].getValue(), psr1.Id);
    	
    	srrc.selectedPSR = psr1.Id;
    	srrc.selectPSR();
    	srrc.syncData();
    	List<pse__Resource_Request__c> pRR = [SELECT Id FROM pse__Resource_Request__c WHERE pse__Opportunity__c =: opp1.Id];
    	system.assertEquals(pRR.size(), 3, '1 new RR has been added');
        Test.stopTest();
    }
  }
  
  	//iterate through a series of isValid failures to test all of them.
	static testMethod void testResourceRequesValid() {
		User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
        System.runAs(sysAdmin){
            Test.startTest();
            //prep some data
    		Opportunity opp = new Opportunity();
    		opp.Name = 'TestingOppTime';
    		opp.Description = 'testing description';
    		opp.StageName = 'Prospecting';
    		opp.CloseDate = Date.today() +300;
    		insert opp;
    		ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        	E2_SyncResourceRequestsController srrc = new E2_SyncResourceRequestsController(stdOpp);
        	srrc.syncData();
        	
        	pse__Resource_Request__c rr = new pse__Resource_Request__c();
        	rr.pse__Resource_Role__c = 'not a valid role';
        	
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Resource_Role__c = 'Project Manager';
        	
        	pse__Region__c region = new pse__Region__c();
        	insert region;
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Region__c = region.Id;
        	
        	pse__Practice__c practice = new pse__Practice__c();
        	insert practice;
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Practice__c = practice.Id;
        	
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Start_Date__c = Date.today();
        	
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__End_Date__c = Date.today();
        	
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__SOW_Hours__c = 100;
        	
        	pse__Skill__c skill = new pse__Skill__c();
        	insert skill;
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Primary_Skill_Certification__c = skill.Id;
        	
        	System.Assert(!srrc.isValidResourceRequest(rr));
        	rr.pse__Requested_Bill_Rate__c = 222;
        	
        	System.Assert(srrc.isValidResourceRequest(rr));
        	rr.pse__Status__c = 'Planning';
        	srrc.checkExistingRR(rr);
        	srrc.cancel();
    	Test.stopTest();
        }
	}
}