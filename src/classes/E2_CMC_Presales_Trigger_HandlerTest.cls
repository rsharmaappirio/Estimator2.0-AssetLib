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

}