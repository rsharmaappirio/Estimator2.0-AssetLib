/**=====================================================================
 * Appirio, Inc
 * Name: E2_PresalesLOESummaryControllerTest
 * Description: Test class for E2_PresalesLOESummaryController apex class
 * Created Date: 14th March, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/

@isTest(seeAllData=false)
public class E2_PresalesLOESummaryControllerTest {


    public static testMethod void testEstimateWithTimeline(){
        CMC_Presales_LOE__c estimate = [SELECT Id FROM CMC_Presales_LOE__c WHERE Name = 'With Timelines'];
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
          //start test
          Test.startTest();
          PageReference pageRef = Page.E2_PresalesLOESummary;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);  
	      E2_PresalesLOESummaryController controller = new E2_PresalesLOESummaryController(stdController);
	      controller.pageAction();
	      Test.stopTest();  
        }   
	}
	
	public static testMethod void testEstimateWithoutTimeline(){
        CMC_Presales_LOE__c estimate = [SELECT Id FROM CMC_Presales_LOE__c WHERE Name = 'Without Timelines'];
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
          //start test
          Test.startTest();
          PageReference pageRef = Page.E2_PresalesLOESummary;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);  
	      E2_PresalesLOESummaryController controller = new E2_PresalesLOESummaryController(stdController);
	      controller.pageAction();
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
        insert estimate;
        
        CMC_Presales_LOE__c timeline = E2_Test_Utils.insertEstimate(psr.id, false);
        timeline.Presales_Request__c = NULL;
        timeline.E2_Is_specific_to_timeline__c = true;
        timeline.E2_Is_Active__c = true;
        timeline.E2_Parent_Estimate__c = estimate.Id;
        timeline.E2_Timeline_Name__c = 'Timeline v1';
        insert timeline;
        
        CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
        estimate1.Name = 'Without Timelines';
        estimate1.E2_Is_Active__c = true;
        insert estimate1;
	}

}