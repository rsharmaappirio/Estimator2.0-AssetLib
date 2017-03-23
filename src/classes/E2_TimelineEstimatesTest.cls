/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineEstimatesTest
 * Description: Test class for E2_TimelineEstimates apex class
 * Created Date: 14th March, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/

@isTest(seeAllData=false)
public class E2_TimelineEstimatesTest {


    public static testMethod void testTimelineWrapper(){ 
        List<CMC_Presales_LOE__c> estimates = [SELECT Id, E2_Is_specific_to_timeline__c, E2_Is_Active__c,
                                              CreatedDate,E2_Timeline_Name__c FROM CMC_Presales_LOE__c];
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
          //start test
          Test.startTest(); 
          List<E2_TimelineEstimates> timelineEstimates = new List<E2_TimelineEstimates>();
          for(CMC_Presales_LOE__c estimate : estimates) {
              timelineEstimates.add(new E2_TimelineEstimates(estimate));
          }
	      timelineEstimates.sort();
	      Test.stopTest();  
        }   
	}
	
	@testSetup
	public static void testDataSetup(){
	    
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
        insert psr;
        
        CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
        estimate.Name = 'With Timelines';
        estimate.Mode__c = 'fixed';
        estimate.E2_Is_Active__c = true;
        estimate.E2_Timeline_Name__c = 'Timeline v2';
        insert estimate;
        
        CMC_Presales_LOE__c timeline = E2_Test_Utils.insertEstimate(psr.id, false);
        timeline.Presales_Request__c = NULL;
        timeline.E2_Is_specific_to_timeline__c = true;
        timeline.E2_Is_Active__c = true;
        timeline.E2_Parent_Estimate__c = estimate.Id;
        timeline.E2_Timeline_Name__c = 'Timeline v1';
        insert timeline;
        
        CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
        estimate1.Presales_Request__c = NULL;
        estimate1.E2_Is_specific_to_timeline__c = true;
        estimate1.E2_Is_Active__c = true;
        estimate1.E2_Parent_Estimate__c = estimate.Id;
        estimate1.E2_Timeline_Name__c = 'Timeline v3';
        insert estimate1;
	}

}