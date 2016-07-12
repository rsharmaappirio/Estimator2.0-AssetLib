/**=====================================================================
 * Appirio, Inc
 * Name: E2_DataUtil_WS
 * Description: Utility class as Data Tier for E2_Estimator_WS (webservice)
 * Created Date: Apr 22th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
public with sharing class E2_DataUtil_WS {
   
   public static List<CMC_Presales_LOE__c> getEstimates(string estimateId) {
   	return [SELECT (SELECT Id, Name, Is_Active__c, Parent_Scope__c, LOE_Hrs__c, Description__c
   	              ,Complexity__c, Scope_Item_Type__c 
   	               FROM E2_Scopes__r 
   	               WHERE Parent_Scope__c = NULL) 
            FROM CMC_Presales_LOE__c 
            WHERE Id = : estimateId];
   }
   
   public static List<E2_Scope__c> getScopesByParentScope(string scopeId) {
   	return [SELECT Id, Name, LOE_Hrs__c ,Complexity__c, Scope_Item_Type__c, Scope_Flag__c  
   	        FROM E2_Scope__c 
   	        WHERE Parent_Scope__c =: scopeId];
   }
  
   public static List<E2_Scope__c> getChildScopesOfEstimate(string estimateId){
       return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c,e.Ultimate_Parent_Id__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c                                  
                                 FROM E2_Scope__c e 
                                 WHERE e.Presales_LOE__c = : estimateId];   
   }
   
    public static List<E2_Scope__c> getChildScopesOfScopeGroup(string scopeGrpId){
    	Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);    	
      return [SELECT Source_Scope__c, Scope_Group__c, Parent_Scope__c, Name,Ultimate_Parent_Id__c, 
                                 Presales_LOE__c, Description__c , LOE_Hrs__c, 
                                 Complexity__c, Scope_Item_Type__c, Is_Active__c, Scope_Flag__c                                   
                                 FROM E2_Scope__c 
                                 WHERE Scope_Group__c = : scopeGrpId AND RecordTypeId = :recTypeId];   
   }
   
   public static List<E2_Scope__c> getScopeDetails(string estimateId) {
     return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
             e.Presales_LOE__c, e.Description__c, e.LOE_Hrs__c,
             e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
             (Select Id FROM Child_Scopes__r limit 1), 
             (Select Id FROM Efforts__r limit 1) 
              FROM E2_Scope__c e 
              WHERE e.Presales_LOE__c = : estimateId and e.Parent_Scope__c = NULL];
   }
   
   public static List<E2_Scope__c> getChildScopeByParentId(string parentId){
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
                                 e.E2_Assumption__c, (Select Id FROM Child_Scopes__r limit 1) 
            FROM E2_Scope__c e 
            WHERE e.Parent_Scope__c = : parentId];
   }
   
   public static List<E2_scope__c> getFullScopeDetails(string scopeId) { 
   	return [Select  
            (Select Id, Source_Scope__c, Scope_Group__c, Parent_Scope__c, Name, Presales_LOE__c, Description__c, LOE_Hrs__c
             ,Complexity__c, Scope_Item_Type__c, E2_Assumption__c , Is_Active__c, Scope_Flag__c  
             FROM Child_Scopes__r),
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c FROM Efforts__r) 
            FROM E2_Scope__c e 
            WHERE e.id = : scopeId];
   }
   
     
   public static List<E2_scope__c> getFullScopeDetailsWithLimit(string scopeId) {
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                   e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, 
                   e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
                   e.E2_Assumption__c, 
            (Select Id FROM Child_Scopes__r limit 1), 
            (Select Id FROM Efforts__r limit 1) 
            FROM E2_Scope__c e 
            WHERE e.id = : scopeId];
   }
   
   public static List<E2_scope__c> getScopeChildList(String scopeId) {
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, 
                                 e.Scope_Flag__c, e.E2_Assumption__c, 
                                 (Select Id FROM Child_Scopes__r limit 1) 
                                 FROM E2_Scope__c e 
                                 WHERE e.id = : scopeId];
   }
   
   public static List<E2_Scope__c> getUltimateScopeLOE(string ultimateScopes) {
  	return [SELECT LOE_Hrs__c,Ultimate_Parent_Id__c FROM E2_Scope__c WHERE
  			Is_Active__c = true AND Ultimate_Parent_Id__c = :ultimateScopes];
  }
   
}