/**=====================================================================
 * Appirio, Inc
 * Name: E2_Scope_Group_Trigger_HandlerTest
 * Description: Test class for E2_Scope_Group_Trigger_Handler
 * Created Date: Oct 27, 2016
 * Created By:  Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
   
*  =====================================================================*/
@isTest
private class E2_Scope_Group_Trigger_HandlerTest {

	private static testMethod void testScopeDelete() {
	    Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
        //create sys admin user
       User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
       System.runAs(sysAdmin){
             //start test
            Test.startTest(); 
            E2_Scope_Group__c scopeGroup = E2_Test_Utils.insertScopeGroup(true);
            
            E2_Scope__c childSC = E2_Test_Utils.insertScope(false);
            childSC.Presales_LOE__c = null;
            childSC.Complexity__c = 'Low';
            childSC.LOE_Hrs__c = 30;
            childSC.recordTypeId = recTypeId1;
            childSC.Scope_Group__c = scopeGroup.Id;
            insert childSC;
            
            delete scopeGroup;
            
            //stop test
            Test.stopTest(); 
       }

	}

}