/**=====================================================================
 * Appirio, Inc
 * Name: E2_DataUtil
 * Description: Utility class as Data Tier
 * Created Date: Apr 22th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/

public class E2_DataUtil {

  public static List<Presales_Request__c> getPSRDetailOnPsrId(id psr_id){
     return [SELECT id, Name, Account_Name__c, Opportunity__c, Opportunity_Name__c,
             Reviewer__c, Reviewer_Name__c, Due_Date__c, Created_By_Name__c, Description__c, Opportunity__r.Account.Id  
             FROM Presales_Request__c WHERE id = : psr_id];
  
  }
  
  public static List<CMC_Presales_LOE__c> getEstimateDetailOnId(id estimateId){
     return [SELECT Id, Name, Description__c, Presales_Request__c, Account_Name__c, Discount__c, Discount_PCT__c, 
                         Opportunity_Name__c, E2_Date_Scoped__c, Offshore_Blend_PCT__c, Blended_Rate__c, Total_Price__c,
                         E2_Is_Primary__c, E2_AE__c,
                         E2_Version_Notes__c, Product__c, E2_Reviewer__c, E2_SA__c, Type__c,E2_Last_Build_Datetime__c,
                         E2_Total_Hrs__c, E2_Derived_Effort_Template__c,
                         E2_Total_Strategy_Hrs__c, E2_Total_Plan_Hrs__c, E2_Total_Architect_Hrs__c, E2_Total_Build_Hrs__c, 
                         E2_Total_Test_Hrs__c, E2_Total_Deploy_Thrive_Hrs__c    
                    FROM CMC_Presales_LOE__c
                    WHERE Id = :estimateId];
  
  }
  
  public static String getScopesOnTemplateScopeSearchTemplate(string scopeName, String groupId, Id recordTypeId) {  		
      String query = 'SELECT Id, RecordTypeId, LOE_Hrs__c, Scope_Item_Type__c, Complexity__c, Scope_Group__c,Scope_Group__r.Name, Source_Scope__c, '+
                            'Presales_LOE__c, Parent_Scope__c, OwnerId, Name, Is_Favourite__c, Is_Active__c,LastViewedDate '+                         
                            'FROM E2_Scope__c '+ 
                            'WHERE Is_Active__c = true '+ 
                            'AND Parent_Scope__c = null AND RecordTypeId = \''+recordTypeId+'\''
                            +(!String.isBlank(scopeName) ? ' AND Name like \'%'+String.escapeSingleQuotes(scopeName)+'%\'':'')+
                            +(!String.isBlank(groupId) ? ' AND Scope_Group__c = \''+String.escapeSingleQuotes(groupId)+'\'':'')+
                            ' ORDER By Name, LastViewedDate ASC limit 1000'; 
      return query;                         
  }
  
  public static String getScopesOnTemplateScopeSearchByUser(string scopeName, String userId, Id recordTypeId){
      String query = 'SELECT Id, RecordTypeId, LOE_Hrs__c, Scope_Item_Type__c, Complexity__c, Scope_Group__c,Scope_Group__r.Name, Source_Scope__c, '+
                            'Presales_LOE__c, Parent_Scope__c, OwnerId, Name, Is_Favourite__c, Is_Active__c,LastViewedDate '+                         
                            'FROM E2_Scope__c '+ 
                            'WHERE Is_Active__c = true AND Is_Favourite__c = true  AND RecordTypeId = \''+recordTypeId+'\' '+ 
                            'AND OwnerId = \''+userId+'\''
                            +(!String.isBlank(scopeName) ? ' AND Name like \'%'+String.escapeSingleQuotes(scopeName)+'%\' ':'')+
                            ' ORDER By Name,LastViewedDate ASC limit 1000'; 
      return query;                         
  }
  
  public static string getDerivedEffortGroup(String name){
      return 'SELECT Id, Name, Description__c, CreatedDate FROM E2_Derived_Effort_Group__c'
      		 +(!String.isBlank(name) ? ' WHERE Name like\'%'+String.escapeSingleQuotes(name)+'%\'':'')+' ORDER By Name';  
  }
  
  public static List<E2_Derived_Effort__c> getDerivedEffort(String selectedGroup){
     return [SELECT Id, Name, Allocation__c, Derived_Effort_Group__c, Derived_Hrs__c, Include_When__c, 
              Include_When_Hours__c, Of_Role__c, Role__c, Of_Phase__c, To_Phase__c, Derived_Effort_Group__r.Name,
              UniqueKey__c, Original_Allocation_Hours__c, Allocation_Min__c   
               FROM E2_Derived_Effort__c 
               WHERE Derived_Effort_Group__c=:selectedGroup AND Is_Active__c=true
               ORDER By Name limit 1000];
  }
  
  public static List<E2_Scope__c> getScopeRecordsWithChildRecords(Id scopeId){
    return [Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
    		Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, 
			(Select Id From Child_Scopes__r),
			(Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
			 Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c From Efforts__r) 
               From E2_Scope__c e 
               where e.id = : scopeId];
  }
  
  public static List<E2_Scope__c> getScopeAndChildrenOnScopeIdForEditScope(Id scopeId) {
  	return [Select Id, Source_Scope__c, Scope_Group__c, Scope_Item_Type__c, Parent_Scope__c,Parent_Scope__r.Name, Name,
  			Presales_LOE__c,Presales_LOE__r.Name, Description__c, Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, 
            Is_Active__c, Scope_Flag__c,
            (Select Id From Child_Scopes__r),
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, Speciality__r.Name, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Hrs_Override_Reason__c From Efforts__r) 
            From E2_Scope__c e where e.id = : scopeId];
  }
  
   public static List<E2_Scope__c> getScopeRecordsWithChildForChildScopeIds(Set<Id>  childScopeIds){
    return [Select Id, 	Source_Scope__c, Scope_Group__c, Scope_Item_Type__c, Parent_Scope__c, Name, Presales_LOE__c, 
    		Description__c, Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, 
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Hrs_Override_Reason__c From Efforts__r) 
              From E2_Scope__c e 
              where e.id in : childScopeIds];
  }
  
  public static List<E2_Effort__c> getEffortsListByEstimateId(Id estimateId) {
  	return [Select  e.Scope__r.Complexity__c, e.Scope__r.Name, e.Scope__c, 
    		e.Scope__r.Is_Active__c , e.Resource_Role__c, e.Phase__c, e.Low_Effort_Hrs__c, 
            e.High_Effort_Hrs__c, e.Effort_Hrs__c, e.Speciality__c, e.Speciality__r.Name 
            From E2_Effort__c e
            where e.Scope__r.Presales_LOE__c = :estimateId AND e.Scope__r.Is_Active__c = true];
  }
  
  public static List<E2_Capacity__c> getCapacityListByEstimateId(Id estimateId) {
  	return [SELECT Id, Role__c, Phase__c, Speciality__c, Speciality__r.Name, Hours__c, CreatedDate  
  			FROM E2_Capacity__c WHERE Estimator__c = :estimateId];
  }
  
  public static List<AggregateResult> getEffortsOnEstimateIds(Set<Id> estimateIds){       
       return [Select  SUM(e.Low_Effort_Hrs__c) lowHrs, SUM(e.High_Effort_Hrs__c) highHrs,
                SUM(e.Effort_Hrs__c) midHrs, e.Resource_Role__c Role, e.Phase__c Phase,
                e.Scope__r.Presales_LOE__c Estimate, e.Scope__r.Complexity__c Complexity
                From E2_Effort__c e
                where e.Scope__r.Presales_LOE__c in : estimateIds AND e.Scope__r.Is_Active__c = true 
                group by e.Scope__r.Presales_LOE__c, e.Resource_Role__c, 
                e.Phase__c, e.Scope__r.Complexity__c];      
  }
  
  public static List<CMC_Presales_LOE__c> getEstimateDetailForAccess(id estimateId){
  	return [SELECT ownerId,  Presales_Request__c 
  	        FROM CMC_Presales_LOE__c
  	        WHERE Id = : estimateId];  	
  }
  
  public static List<E2_Derived_Effort_Group__c> getDerivedEffortGroupById(String groupId) {
  	return [SELECT Id,Name,Description__c FROM E2_Derived_Effort_Group__c WHERE Id = :groupId];
  }
  
  public static List<E2_Derived_Effort__c> getAllDerivedEffort(String selectedGroup){
     return [SELECT Id, Name, Allocation__c, Derived_Effort_Group__c, Derived_Hrs__c, Include_When__c, Is_Active__c,  
              Include_When_Hours__c, Of_Role__c, Role__c, Of_Phase__c, To_Phase__c, Derived_Effort_Group__r.Name, 
              UniqueKey__c, Original_Allocation_Hours__c, Allocation_Min__c  
               FROM E2_Derived_Effort__c 
               WHERE Derived_Effort_Group__c=:selectedGroup ORDER By Name];
  }
  
  public static List<E2_Scope_Group__c> getAllScopeGroups() {
  	return [SELECT Id, Name FROM E2_Scope_Group__c ORDER BY Name];
  }
  
  public static List<E2_Scope__c> getActiveChildScopesOfEstimate(String estimateId){
      return [SELECT Name, Complexity__c, Scope_Item_Type__c, Description__c ,
      E2_Assumption__c, LOE_Hrs__c, Parent_Scope__r.Name                                 
                     FROM E2_Scope__c 
                     WHERE Is_Active__c = true AND Presales_LOE__c = : estimateId];   
  }
  
}