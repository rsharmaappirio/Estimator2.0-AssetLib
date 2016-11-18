/**=====================================================================
 * Appirio, Inc
 * Name: E2_CMC_Presales_Trigger_HandlerTest
 * Description: Test class for E2_CMC_Presales_Trigger_Handler
 * Created Date: Oct 27, 2016
 * Created By:  Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
   
*  =====================================================================*/
@isTest(seeAllData=true)
private class E2_CMC_Presales_Trigger_HandlerTest {

	private static testMethod void testTrigger() {
	    Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
	    List<PermissionSet> permissionSetDetails = [SELECT Id FROM PermissionSet WHERE Name = 'CMC_Presales_Beta'];
	    
        //create sys admin user
       User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
       if(permissionSetDetails.size() > 0) {
           PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permissionSetDetails.get(0).Id, AssigneeId = sysAdmin.Id);
           insert psa; 
       } 
       System.runAs(sysAdmin){
             //start test
            Test.startTest(); 
            Account acc = E2_Test_Utils.insertAccount(true);
            Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
            
            Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
            
            CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
            
            E2_Scope__c source_scope =  E2_Test_Utils.insertScope(false);
            source_scope.recordTypeId = recTypeId1;
            source_scope.Presales_LOE__c = estimate.id;  
            insert source_scope;
            
            delete estimate;
            //stop test
            Test.stopTest(); 
       }
       
	}
	
	private static testMethod void testUpdateDiscount() {
	     Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
        insert psr;
        
        CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
        estimate.E2_SA__c = UserInfo.getUserId();
        estimate.Discount__c = '3000';
        insert estimate;
        
        pse__Region__c region = E2_Test_Utils.insertRegion(true);
        pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
        
        pse__Rate_Card__c rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
        E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
    
	    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
             //start test
            Test.startTest(); 
            
            CMC_Estimate_Resource__c resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
            CMC_Estimate_Week__c week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
            CMC_Estimate_Resource_Week__c resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
            
            Test.stopTest();
        }
	}
}