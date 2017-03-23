/**=====================================================================
 * Appirio, Inc
 * Name: E2_CMC_Presales_Trigger_HandlerTest
 * Description: Test class for E2_CMC_Presales_Trigger_Handler
 * Created Date: Oct 27, 2016
 * Created By:  Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
 * Feb 22, 2017       JITENDRA JANGID              S-404442: Create multiple timelines on an estimate.
*  =====================================================================*/
@isTest(seeAllData=true)
private class E2_CMC_Presales_Trigger_HandlerTest {

	private static testMethod void testTrigger() {
	    Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
	   
        //create sys admin user
       User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
       System.runAs(sysAdmin){
             //start test
            Test.startTest(); 
            Account acc = E2_Test_Utils.insertAccount(true);
            Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
            
            Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
            
            CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
            
            CMC_Presales_LOE__c childEstimate = E2_Test_Utils.insertEstimate(psr.Id, false);
            childEstimate.E2_Parent_Estimate__c=estimate.ID;
            insert childEstimate;
            
            E2_Scope__c source_scope =  E2_Test_Utils.insertScope(false);
            source_scope.recordTypeId = recTypeId1;
            source_scope.Presales_LOE__c = estimate.id;  
            insert source_scope;
            
            E2_Estimate_Milestone__c milestone=E2_Test_Utils.insertEstimateMilestone(estimate.ID,true);
            
            pse__Region__c region = E2_Test_Utils.insertRegion(true);
            pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
        
            pse__Rate_Card__c rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
            E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);

            CMC_Estimate_Resource__c resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
            CMC_Estimate_Week__c week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
            CMC_Estimate_Resource_Week__c resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
            
            
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