@isTest
private class E2_EstimateResourceTest {

	private static testMethod void test() {
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
            //start test
            Test.startTest();
            E2_EstimateResource resource = new E2_EstimateResource();
            resource.rate = 70.00;
            resource.cost = 20.00;
            resource.hours = 20;
	    	resource.role = 'Developer';
        	resource.regionName = 'GS - Jaipur Delivery';
        	resource.practiceName = 'SFDC';
        	resource.skill = 'Javascript';
	
        	resource.endDate = Date.today().addDays(30);
        	resource.startDate = Date.today().addDays(-30);
	
        	resource.regionId = NULL;
        	resource.practiceId = NULL;
        	resource.rateCardId = NULL;
        	resource.resourceId = NULL;
        
        	resource.curCode = 'J-Dev';
            Test.stopTest();
        }
	}

}