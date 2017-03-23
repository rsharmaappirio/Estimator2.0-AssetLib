/**=====================================================================
 * Appirio, Inc
 * Name: E2_PresalesLOEReleatedListControllerTest
 * Description: Test class for E2_PresalesLOEReleatedListController apex class
 * Created Date: 14th March, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/

@isTest(seeAllData=false)
public class E2_PresalesLOEReleatedListControllerTest {


    public static testMethod void testPSRRelatedList(){
        Presales_Request__c psr = [SELECT Id FROM Presales_Request__c];
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
          //start test
          Test.startTest();
          PageReference pageRef = Page.E2_PresalesLOEReleatedList;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController stdController = new ApexPages.StandardController(psr);  
	      E2_PresalesLOEReleatedListController controller = new E2_PresalesLOEReleatedListController(stdController);
	      controller.pageAction();
	      system.assertEquals(controller.estimateSummary.size(), 2,'Does not return 2 estimates associated with psr');
	      id estimateId = controller.estimateSummary.get(0).estimate.Id;
	      controller.estimateIdToDelete = estimateId;
	      controller.deleteEstimate();
	      system.assertEquals(controller.estimateSummary.size(), 1,'Does not return 1 estimate associated with psr');
	      controller.deleteEstimate();
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