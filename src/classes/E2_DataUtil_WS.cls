/**=====================================================================
 * Appirio, Inc
 * Name: E2_DataUtil_WS
 * Description: Utility class as Data Tier for E2_Estimator_WS (webservice)
 * Created Date: Apr 22th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Oct 19, 2016       Arpita Bose                  S-448268 : Cloned scope item on right click
 * Oct 27, 2016       Rohit Sharma                 I-241822 : Total effort of scope hierarchy has not displayed over ultimate parent node
 * Dec 8th, 2016      Rohit Sharma                 S-449145 :Ability to find the Scope by type, Complexity ,Q&A and assets assigned.
 * Dec 26, 2016       Rahul Jain                   S-459273 : Added resource level field to all queries to for E2_Effort__c object
 * Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope: Scope/Effort SOQLs updated add Effort_Quantity__c 
 *                                                 custom field.
*  =====================================================================*/
public with sharing class E2_DataUtil_WS {
   
   public static List<CMC_Presales_LOE__c> getEstimates(string estimateId) {
   	return [SELECT (SELECT Id, Name, Is_Active__c, Parent_Scope__c, LOE_Hrs__c, Effort_Quantity__c,  Description__c
   	              ,Complexity__c, Scope_Item_Type__c
   	               FROM E2_Scopes__r 
   	               WHERE Parent_Scope__c = NULL) 
            FROM CMC_Presales_LOE__c 
            WHERE Id = : estimateId];
   }
   
   public static List<E2_Scope__c> getScopesByParentScope(string scopeId) {
   	return [SELECT Id, Name, LOE_Hrs__c, Effort_Quantity__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c  
   	        FROM E2_Scope__c 
   	        WHERE Parent_Scope__c =: scopeId];
   }
  
   public static List<E2_Scope__c> getChildScopesOfEstimate(string estimateId){
       // RS : I-241822 : added Ultimate_Parent_Scope__c parent scope in soql query. 
       return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, e.Effort_Quantity__c, e.Ultimate_Parent_Id__c, e.Ultimate_Parent_Scope__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, e.Display_Order__c, 
                                 (SELECT Id FROM E2_Recommended_Assets__r),
                                 (SELECT Id FROM Questions__r) 
                                 FROM E2_Scope__c e 
                                 WHERE e.Presales_LOE__c = : estimateId ORDER BY e.Ultimate_Parent_Scope__c NULLS FIRST];   
   }
   
    public static List<E2_Scope__c> getChildScopesOfScopeGroup(string scopeGrpId){
        // RS : I-241822 : added Ultimate_Parent_Scope__c parent scope in soql query.
    	Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);    	
      return [SELECT Source_Scope__c, Scope_Group__c, Parent_Scope__c, Name,Ultimate_Parent_Id__c, Ultimate_Parent_Scope__c, 
                                 Presales_LOE__c, Description__c , LOE_Hrs__c, Effort_Quantity__c,  
                                 Complexity__c, Scope_Item_Type__c, Is_Active__c, Scope_Flag__c, Display_Order__c                                   
                                 FROM E2_Scope__c 
                                 WHERE Scope_Group__c = : scopeGrpId AND RecordTypeId = :recTypeId ORDER BY Ultimate_Parent_Scope__c NULLS FIRST];   
   }
   
   public static List<E2_Scope__c> getScopeDetails(string estimateId) {
     return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
             e.Presales_LOE__c, e.Description__c, e.LOE_Hrs__c, e.Effort_Quantity__c,
             e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
             (Select Id FROM Child_Scopes__r limit 1), 
             (Select Id FROM Efforts__r limit 1) 
              FROM E2_Scope__c e 
              WHERE e.Presales_LOE__c = : estimateId and e.Parent_Scope__c = NULL];
   }
   
   public static List<E2_Scope__c> getChildScopeByParentId(string parentId){
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, e.Effort_Quantity__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
                                 e.E2_Assumption__c, (Select Id FROM Child_Scopes__r limit 1) 
            FROM E2_Scope__c e 
            WHERE e.Parent_Scope__c = : parentId];
   }
   
   public static List<E2_scope__c> getFullScopeDetails(string scopeId) { 
    // 12/26: Updated the query to add resource level field in the query
   	return [Select  
            (Select Id, Source_Scope__c, Scope_Group__c, Parent_Scope__c, Name, Presales_LOE__c, Description__c, LOE_Hrs__c, Effort_Quantity__c
             ,Complexity__c, Scope_Item_Type__c, E2_Assumption__c , Is_Active__c, Scope_Flag__c  
             FROM Child_Scopes__r),
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Resource_Level__c FROM Efforts__r),
            (SELECT Id, Scope__c, Asset__c FROM E2_Recommended_Assets__r)  
            FROM E2_Scope__c e 
            WHERE e.id = : scopeId];
   }
      
   public static List<E2_scope__c> getFullScopesDetailsWithLimit(List<string> scopeId) {
    // 12/26: Updated the query to add resource level field in the query
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                   e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, e.Effort_Quantity__c, 
                   e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
                   e.E2_Assumption__c, e.RecordTypeId, e.Display_Order__c, e.Sequence__c,
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Resource_Level__c FROM Efforts__r),
             (SELECT Id, Scope__c, Asset__c FROM E2_Recommended_Assets__r),
             (SELECT Id, Question_Text__c, Scope__c, Source_Question__c, 
  			  Type__c, Is_Active__c, Weighted_Effort_LOE__c FROM Questions__r) 
            FROM E2_Scope__c e 
            WHERE e.id IN : scopeId];
   }
   
   public static List<E2_Answer__c> getAnswersDetails(set<Id> questions) {
   	 return [SELECT Id, Answer_Text__c, Effort_LOE__c, Is_Selected__c, 
  			  Sequence__c, Source_Answer__c, Is_Active__c, Question__c, Action__c,
  			  (SELECT Answer__c, Scope__c FROM Action_Scopes__r) 
  			 FROM E2_Answer__c
   	  		 WHERE Question__c IN: questions];
   }
   
   public static List<E2_scope__c> getParentScopeIds(set<string> scopeId) {
   		return [SELECT Id, Parent_Scope__c, Parent_Scope__r.Parent_Scope__c,  
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__c,
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c, 
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c 
                                 FROM E2_Scope__c 
                                 WHERE ID IN :scopeId];
   }
   
   public static List<E2_scope__c> getScopeChildList(String scopeId) {
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, e.Effort_Quantity__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, 
                                 e.Scope_Flag__c, e.E2_Assumption__c, 
                                 (Select Id FROM Child_Scopes__r limit 1) 
                                 FROM E2_Scope__c e 
                                 WHERE e.id = : scopeId];
   }
   
   public static List<E2_Scope__c> getUltimateScopeLOE(string ultimateScopes) {
  	return [SELECT LOE_Hrs__c, Effort_Quantity__c, Ultimate_Parent_Id__c, Ultimate_Parent_Scope__c FROM E2_Scope__c WHERE
  			Is_Active__c = true AND Ultimate_Parent_Id__c = :ultimateScopes];
  }
   
   public static List<List<SObject>> getRelatedAssets(string searchStr, List<string> exisitingAssetIds){
  		List<List<SObject>> result = new List<List<SObject>>();
  		String searchQueryStr = 'FIND \'' + searchStr + '*\' IN ALL FIELDS RETURNING CMC_Asset__c (Name, Short_Description__c, ' + 
  		                        'Technologies__c, Asset_Type__c, Asset_SubType__c, Appirio_Services_Practice__c, Primary_Contact_UserId__c, '+
	  							'Number_of_Uses__c, Is_Recommended__c, Total_Hours__c, Reuse_LOE__c, Release_Stage__c' +
	  			    			' WHERE Release_Stage__c = \'Active\'';
	  	
	  	if(exisitingAssetIds != null && exisitingAssetIds.size() > 0){
	  		searchQueryStr += ' AND Id NOT IN :exisitingAssetIds';
	  	}
			searchQueryStr += ')';
			result = Search.query(searchQueryStr);
			return result;			
  }
  
  public static List<CMC_Asset_Contributor__c> getAssetContributors(List<CMC_Asset__c> listAssets ){
  	return [SELECT Asset__c, Contact__c, Contact__r.Name 
	  				FROM CMC_Asset_Contributor__c
	  				WHERE Asset__c IN :listAssets AND Primary_Contact__c = true];
  }
  
  public static List<E2_Recommended_Asset__c> getRecommendedAssetsForScope(String scopeId){
      return  [SELECT Asset__c, Scope__c 
               FROM E2_Recommended_Asset__c 
   			   WHERE Scope__c =: scopeId];
  }
  
  public static Map<String, CMC_Asset__c> getAssetsMap(Set<Id> assetsId){
      return new Map<String, CMC_Asset__c>([SELECT Name, Short_Description__c, Technologies__c, Asset_Type__c, 
   		                         Asset_SubType__c, Appirio_Services_Practice__c, Total_Hours__c, Reuse_LOE__c,
   								 Primary_Contact_UserId__c, Number_of_Uses__c, Is_Recommended__c, Release_Stage__c
   								 FROM CMC_Asset__c
   								 WHERE Id IN :assetsId]);
  }
  
  //AB S-448268 : Method to return all scopes details by scopeId
  public static List<E2_Scope__c> getChildScopesById(set<Id> scopesId){
       return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                                 e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, e.Effort_Quantity__c, e.Ultimate_Parent_Id__c, e.Ultimate_Parent_Scope__c, 
                                 e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, e.Display_Order__c,
                                 (SELECT Id FROM E2_Recommended_Assets__r),
                                 (SELECT Id FROM Questions__r) 
                                 FROM E2_Scope__c e 
                                 WHERE e.Id IN: scopesId];   
   }
}