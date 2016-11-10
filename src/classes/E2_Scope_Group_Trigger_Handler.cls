/**=====================================================================
 * Appirio, Inc
 * Name: E2_Scope_Group_Trigger
 * Description: Handler class for E2_Scope_Group_Trigger Trigger
 * Created Date: Oct 27, 2016
 * Created By:  Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
   
*  =====================================================================*/
public with sharing class E2_Scope_Group_Trigger_Handler {
    
    // called on before delete
    public static void onBeforeDelete(List <E2_Scope_Group__c> oldScopeGroups) {
    	deleteChildScopes(oldScopeGroups);
	}
	
	//Method to delete child scopes on deleting scope library to prevent orphan nodes 
	private static void deleteChildScopes(List <E2_Scope_Group__c> scopeGroups){
	    List<E2_Scope__c> lstScopesToDelete = new List<E2_Scope__c>(E2_DataUtil.getChildScopesOfScopeLibrary(scopeGroups));
        try{
            if(lstScopesToDelete.size() > 0){
                delete lstScopesToDelete;
            }
        }
        catch(DmlException ex){
            scopeGroups[0].addError(ex.getMessage());
        }
	}

}