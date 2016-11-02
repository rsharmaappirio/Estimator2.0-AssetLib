/**=====================================================================
 * Appirio, Inc
 * Name: E2_ScopeTriggerHandler
 * Description: Trigger handler for E2_ScopeTrigger
 * Created Date: August 9th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * October 27, 2016   Rohit Sharma                 I-241853 : Wrong total effort has displayed over ultimate parent after cloning scope hierarchy.
*  =====================================================================*/
public class E2_ScopeTriggerHandler {
	
	public static set<id> scopeIds = new set<id>();
    //after insert
    public static void afterInsert(List<E2_Scope__c> newList){
      populateUltimateParent(newList, null);
    }
    //after update
    public static void afterUpdate(List<E2_Scope__c> newList, Map<ID, E2_Scope__c> oldMap){
      populateUltimateParent(newList, oldMap); 
    }
    
    //method to populate ultimate Parent on Scope    
    public static void populateUltimateParent(List<E2_Scope__c> newList, Map<ID, E2_Scope__c> oldMap) {
        set<Id> updatedScopes = new set<Id>();
        list<E2_scope__c> scopesToUpdate = new list<E2_scope__c>();
        //get all the scope Ids where Parent Scope is not null or is changed
        for(E2_Scope__c scope : newList) {
            // RS : I-241853 : Wrong total effort has displayed over ultimate parent after cloning scope hierarchy.
        	if(scope.Parent_Scope__c != NULL  && !scopeIds.contains(scope.Id)) {
        		updatedScopes.add(scope.Id);
        		scopeIds.add(scope.Id);
        	} else if(scope.Parent_Scope__c == NULL && !scopeIds.contains(scope.Id)) {
        	    E2_scope__c scopeEdit = new E2_scope__c(id = scope.Id, Ultimate_Parent_Scope__c = NULL);
        	    scopesToUpdate.add(scopeEdit);
        		scopeIds.add(scope.Id);
        	}             
        }
        //update ultimate parent on Scopes for the set of scope Ids fetched 
        if(!updatedScopes.isEmpty()) {
            for(E2_scope__c scope : E2_DataUtil.getscopeUltimateParentDetails(updatedScopes)) {
                scope.Ultimate_Parent_Scope__c = scope.Ultimate_Parent_Id__c;
                scopesToUpdate.add(scope);
            }   
        }
        if(!scopesToUpdate.isEmpty()) {
            update scopesToUpdate;
        }
  }
   
}