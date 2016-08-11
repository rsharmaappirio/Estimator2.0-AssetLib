public class E2_ScopeTriggerHandler{
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
            if(oldMap == null || scope.Parent_Scope__c != oldMap.get(scope.Id).Parent_Scope__c) {
              updatedScopes.add(scope.Id);
          }
        }
        //update ultimate parent on Scopes for the set of scope Ids fetched 
        if(!updatedScopes.isEmpty()) {
            for(E2_scope__c scope : E2_DataUtil.getscopeUltimateParentDetails(updatedScopes)) {
                scope.Ultimate_Parent_Scope__c = scope.Ultimate_Parent_Id__c;
                scopesToUpdate.add(scope);
            }
            update scopesToUpdate;   
        }
  }
   
}