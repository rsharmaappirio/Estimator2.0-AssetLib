/**=====================================================================
 * Appirio, Inc
 * Name: E2_DataUtil
 * Description: Utility class as Data Tier
 * Created Date: Apr 22th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
   Aug 29th, 2016     Arpita Bose                  Added CurrencyISOCode in the query
   Oct 17th, 2016     Rohit Sharma                 S-447214 : Added SOQL methods for Scope
                                                   and efforts for capacity needs
   Oct 19th,2016     Rohit Sharma                  I-241595 : Enhance the E2 code where algo has developed 
                                                   around "Scope Template manager" permission set  
   Dec 14, 2016       Rohit Sharma                 S-456645 : Search on child scopes on scope library.
   Dec 26, 2016       Rahul Jain                   S-459273 : Added Resource Level field in all the queries to pse__Rate_Card__c and E2_Estimate_Rate_Card__c objects
                                                   updated getScopeRecordsWithChildRecords, getScopeAndChildrenOnScopeIdForEditScope, getScopeRecordsWithChildForChildScopeIds
                                                   method for resource level field
   Jan 25, 2017       Rohit Sharma                 S-453758 : Added Is_Active__c field to derived effort template soql in methods getDerivedEffortGroup 
                                                   and getDerivedEffortGroupById
   Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope : Scope/Effort SOQL udpated added new custom field Effort_Quantity__c
   Feb 21, 2017       Rohit Sharma                 S-404442 : Added function to get timeline versions, estimate resources and milestones
*  =====================================================================*/

public class E2_DataUtil {

  public static List<Presales_Request__c> getPSRDetailOnPsrId(id psr_id){
     return [SELECT id, Name, Account_Name__c, Opportunity__c, Opportunity_Name__c,
             Reviewer__c, Reviewer_Name__c, Due_Date__c, Created_By_Name__c, Description__c,
             Opportunity__r.Account.Id, (SELECT id FROM Presales_LOEs__r)    
             FROM Presales_Request__c WHERE id = : psr_id];
  
  }
  
  public static List<CMC_Presales_LOE__c> getEstimateDetailOnId(id estimateId){
     return [SELECT Id, Name, Description__c, Presales_Request__c, Account_Name__c, Discount__c, Discount_PCT__c, 
                         Opportunity_Name__c, E2_Date_Scoped__c, Offshore_Blend_PCT__c, Blended_Rate__c, Total_Price__c,
                         E2_AE__c, Default__c,
                         E2_Version_Notes__c, Product__c, E2_Reviewer__c, E2_SA__c, Type__c,E2_Last_Build_Datetime__c,
                         E2_Total_Hrs__c, E2_Derived_Effort_Template__c,
                         E2_Total_Strategy_Hrs__c, E2_Total_Plan_Hrs__c, E2_Total_Architect_Hrs__c, E2_Total_Build_Hrs__c, 
                         E2_Total_Test_Hrs__c, E2_Total_Deploy_Thrive_Hrs__c, E2_Risk__c, CurrencyISOCode, Discount_Percent__c,
                         E2_Parent_Estimate__c, E2_Is_specific_to_timeline__c, E2_Is_Active__c, E2_Timeline_Name__c 
                    FROM CMC_Presales_LOE__c
                    WHERE Id = :estimateId];
  
  }
  
  public static String getScopesOnTemplateScopeSearchTemplate(string scopeName, String groupId, Id recordTypeId) {  		
      String query = 'SELECT Id, RecordTypeId, LOE_Hrs__c, Scope_Item_Type__c, Complexity__c, Scope_Group__c,Scope_Group__r.Name, Source_Scope__c, '+
                            'Presales_LOE__c, Parent_Scope__c, Parent_Scope__r.Name, OwnerId, Name, Is_Favourite__c, Is_Active__c,Effort_Quantity__c '+                         
                            'FROM E2_Scope__c '+ 
                            'WHERE Is_Active__c = true '+ 
                            'AND RecordTypeId = \''+recordTypeId+'\''
                            +(!String.isBlank(scopeName) ? ' AND Name like \'%'+String.escapeSingleQuotes(scopeName)+'%\'':'')+
                            +(!String.isBlank(groupId) ? ' AND Scope_Group__c = \''+String.escapeSingleQuotes(groupId)+'\'':'')+
                            ' ORDER By Name ASC limit 1000'; 
      return query;                         
  }
  
  ///
  public static String getFavScopesOnTemplateScopeSearchByUser(string scopeName, String userId, String groupId){
      String query = 'Select Id, Name, User__c, Unique_Scope_User_Id__c, Scope__r.Id, Scope__r.Name, ' +
					 'Scope__r.RecordTypeId, Scope__r.LOE_Hrs__c, Scope__r.Scope_Item_Type__c, Scope__r.Complexity__c, '+ 
					 'Scope__r.Scope_Group__c, Scope__r.Scope_Group__r.Name, Scope__r.Source_Scope__c, '+ 
					 'Scope__r.Presales_LOE__c, Scope__r.Parent_Scope__c, Scope__r.OwnerId, Scope__r.Is_Favourite__c, Scope__r.Is_Active__c '+ 
					 'From E2_Favourite_Scope__c WHERE Scope__r.Is_Active__c = true AND User__c = \''+userId+'\''
                     +(!String.isBlank(scopeName) ? ' AND Scope__r.Name like \'%'+String.escapeSingleQuotes(scopeName)+'%\' ':'')+
                     +(!String.isBlank(groupId) ? ' AND Scope__r.Scope_Group__c = \''+String.escapeSingleQuotes(groupId)+'\'':'')+
                     ' ORDER By Scope__r.Name ASC limit 1000';                      
      return query;                         
  }
  
  public static string getDerivedEffortGroup(String name){
      return 'SELECT Id, Name, Description__c, Is_Active__c, CreatedDate FROM E2_Derived_Effort_Group__c'
      		 +(!String.isBlank(name) ? ' WHERE Name like\'%'+String.escapeSingleQuotes(name)+'%\'':'')+' ORDER By Name';  
  }
  
  public static List<E2_Derived_Effort__c> getDerivedEffort(String selectedGroup){
     // 12/26: Updated query to add level and of level fields in the query 
     return [SELECT Id, Name, Allocation__c, Derived_Effort_Group__c, Derived_Hrs__c, Include_When__c, 
              Include_When_Hours__c, Of_Role__c, Role__c, Of_Phase__c, To_Phase__c, Derived_Effort_Group__r.Name,
              UniqueKey__c, Original_Allocation_Hours__c, Allocation_Min__c, Level__c, of_Level__c    
               FROM E2_Derived_Effort__c 
               WHERE Derived_Effort_Group__c=:selectedGroup AND Is_Active__c=true
               ORDER By Name limit 1000];
  }
  
  public static List<E2_Scope__c> getScopeRecordsWithChildRecords(Id scopeId){
    // 12/26: Updated the query to add resource level field in the query
    return [Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
    		Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c,Effort_Quantity__c, 
			(Select Id From Child_Scopes__r),
			(Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
			 Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Resource_Level__c From Efforts__r) 
               From E2_Scope__c e 
               where e.id = : scopeId];
  }
  
  public static List<E2_Scope__c> getScopeAndChildrenOnScopeIdForEditScope(Id scopeId) {
    // 12/26: Updated the query to add resource level field in the query
  	return [Select Id, Source_Scope__c, Scope_Group__c, Scope_Item_Type__c, Parent_Scope__c,Parent_Scope__r.Name, Name,
  			Presales_LOE__c,Presales_LOE__r.Name, Description__c, Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, 
            Is_Active__c, Scope_Flag__c, OwnerId, CreatedById ,Effort_Quantity__c,
            (Select Id, CreatedById  From Child_Scopes__r),
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, Speciality__r.Name, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Hrs_Override_Reason__c, Resource_Level__c From Efforts__r) 
            From E2_Scope__c e where e.id = : scopeId];
  }
  
   public static List<E2_Scope__c> getScopeRecordsWithChildForChildScopeIds(Set<Id>  childScopeIds){
    // 12/26: Updated the query to add resource level field in the query
    return [Select Id, 	Source_Scope__c, Scope_Group__c, Scope_Item_Type__c, Parent_Scope__c, Name, Presales_LOE__c, 
    		Description__c, Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c,Effort_Quantity__c, 
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c, Hrs_Override_Reason__c, Resource_Level__c From Efforts__r) 
              From E2_Scope__c e 
              where e.id in : childScopeIds];
  }
  
  public static List<E2_Effort__c> getEffortsListByEstimateId(Id estimateId) {
      // 12/26 Added resource level field in the query
  	return [Select  e.Scope__r.Complexity__c, e.Scope__r.Name, e.Scope__c, 
    		e.Scope__r.Is_Active__c , e.Resource_Role__c, e.Phase__c, e.Low_Effort_Hrs__c, 
            e.High_Effort_Hrs__c, e.Effort_Hrs__c, e.Speciality__c, e.Speciality__r.Name 
            , Resource_Level__c, e.Scope__r.Effort_Quantity__c
            From E2_Effort__c e
            where e.Scope__r.Presales_LOE__c = :estimateId AND e.Scope__r.Is_Active__c = true];
  }
  
  public static List<E2_Capacity__c> getCapacityListByEstimateId(Id estimateId) {
    // 12/26 Added resource level field in the query
  	return [SELECT Id, Role__c, Phase__c, Speciality__c, Speciality__r.Name, Hours__c, Level__c, CreatedDate  
  			FROM E2_Capacity__c WHERE Estimator__c = :estimateId];
  }
  
  /*public static List<AggregateResult> getEffortsOnEstimateIds(Set<Id> estimateIds){  
      // 12/26: Updated the query to add resource level field in the query and agreegate them
       return [Select  SUM(e.Low_Effort_Hrs__c) lowHrs, SUM(e.High_Effort_Hrs__c) highHrs,
                SUM(e.Effort_Hrs__c) midHrs, e.Resource_Role__c Role, e.Phase__c Phase,
                e.Scope__r.Presales_LOE__c Estimate, e.Scope__r.Complexity__c Complexity
                ,e.Resource_Level__c Level, e.Scope__r.Effort_Quantity__c multiplier
                From E2_Effort__c e
                where e.Scope__r.Presales_LOE__c in : estimateIds AND e.Scope__r.Is_Active__c = true 
                group by e.Scope__r.Presales_LOE__c, e.Resource_Role__c, e.Resource_Level__c, 
                e.Phase__c, e.Scope__r.Complexity__c, e.Scope__r.Effort_Quantity__c];      
  }*/
  
  public static List<CMC_Presales_LOE__c> getEstimateDetailForAccess(id estimateId){
  	return [SELECT ownerId,  Presales_Request__c, E2_Risk__c, CurrencyISOCode, Discount_Percent__c
  	        FROM CMC_Presales_LOE__c
  	        WHERE Id = : estimateId];  	
  }
  
  public static List<E2_Derived_Effort_Group__c> getDerivedEffortGroupById(String groupId) {
  	return [SELECT Id,Name,Description__c,Is_Active__c FROM E2_Derived_Effort_Group__c WHERE Id = :groupId];
  }
  
  public static List<E2_Derived_Effort__c> getAllDerivedEffort(String selectedGroup){
      // 12/27: Updated query to add level and of level fields in the query 
     return [SELECT Id, Name, Allocation__c, Derived_Effort_Group__c, Derived_Hrs__c, Include_When__c, Is_Active__c,  
              Include_When_Hours__c, Of_Role__c, Role__c, Of_Phase__c, To_Phase__c, Derived_Effort_Group__r.Name, 
              UniqueKey__c, Original_Allocation_Hours__c, Allocation_Min__c, Level__c, of_Level__c  
               FROM E2_Derived_Effort__c 
               WHERE Derived_Effort_Group__c=:selectedGroup ORDER By Name];
  }
  
  public static List<E2_Scope_Group__c> getAllScopeGroups() {
  	return [SELECT Id, Name FROM E2_Scope_Group__c ORDER BY Name];
  }
  
  public static List<E2_Scope__c> getActiveChildScopesOfEstimate(String estimateId){
      return [SELECT Name, Complexity__c, Scope_Item_Type__c, Description__c ,
      E2_Assumption__c, LOE_Hrs__c, Parent_Scope__r.Name, Effort_Quantity__c                                 
                     FROM E2_Scope__c 
                     WHERE Is_Active__c = true AND Presales_LOE__c = : estimateId
                     order by Sequence__c asc];   
  }
  
  public static List<E2_Scope__c> getScopesOnTemplate(string scopeId) {
    return [SELECT Id, Name, LOE_Hrs__c ,Complexity__c, Scope_Item_Type__c, Scope_Flag__c,
              Is_Active__c, Is_Favourite__c, Effort_Quantity__c 
            FROM E2_Scope__c 
            WHERE Id =: scopeId];
  }
  
  public static List<E2_Recommended_Asset__c> getRecommendedAssetsForScope(Id scopeId){
      return  [SELECT Asset__c, Scope__c 
               FROM E2_Recommended_Asset__c 
   			   WHERE Scope__c =: scopeId];
  }
  
  public static Map<Id, CMC_Asset__c> getAssetsMap(Set<Id> assetsId){
      return new Map<Id, CMC_Asset__c>([SELECT Name, Short_Description__c, Technologies__c, Asset_Type__c, 
   		                         Asset_SubType__c, Appirio_Services_Practice__c, Total_Hours__c, Reuse_LOE__c,
   								 Primary_Contact_UserId__c, Number_of_Uses__c, Is_Recommended__c, Release_Stage__c
   								 FROM CMC_Asset__c
   								 WHERE Id IN :assetsId]);
  } 
  
  public static List<E2_Question__c> getScopeQuestions(Id scopeId) {
  	return [SELECT Id, Question_Text__c, Scope__c, Source_Question__c, 
  			Type__c, Is_Active__c, Weighted_Effort_LOE__c,
  			(SELECT Id, Answer_Text__c, Effort_LOE__c, Is_Selected__c, 
  			  Sequence__c, Source_Answer__c, Is_Active__c, Question__c, Action__c 
  			 FROM Answers__r ORDER BY Sequence__c)
  			 FROM E2_Question__c
  			 WHERE Scope__c =: scopeId];
  }
  
  public static List<E2_Action_Scope__c> getRelatedScopes(set<Id> answers) {
  	return [SELECT Id, Answer__c, Scope__c, Scope__r.Id, Scope__r.Name, Unique_Key__c 
  			FROM E2_Action_Scope__c
  			WHERE Answer__c IN: answers];
  }
  
  public static List<E2_scope__c> getParentScopeIds(set<Id> scopeId) {
      return [SELECT Id, Parent_Scope__c, Parent_Scope__r.Parent_Scope__c,  
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__c,
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c, 
                                 Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c 
                                 FROM E2_Scope__c 
                                 WHERE ID IN :scopeId];
   }
   
  public static List<E2_scope__c> getscopeUltimateParentDetails(set<Id> scopeIds) {
      return [SELECT Id, Ultimate_Parent_Id__c, Ultimate_Parent_Scope__c
                                     FROM E2_Scope__c
                                     WHERE Id IN: scopeIds];
  }
  
   public static List<E2_Favourite_Scope__c> getFavScopeForCurrentUser(){
      return [SELECT Id,Unique_Scope_User_Id__c 
                FROM E2_Favourite_Scope__c 
                WHERE User__c =: UserInfo.getUserId()];
  }
  
  public static List<E2_Favourite_Scope__c> getFavScopeForCurrentUserAndScopeId(String scopeId){
      return [SELECT Id,Scope__r.RecordTypeId 
                FROM E2_Favourite_Scope__c 
		        WHERE Scope__c =: scopeId AND User__c =: UserInfo.getUserId()];
  }
  
  
  public static List<E2_Estimate_Rate_Card__c> getEstimateRateCardRecs(id estimateId){
      // 12/26 Added resource level field in the query
     return [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
    				Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
    				Bill_Rate__c, Discounted_Rate__c, Category__c,
    				Rate_Card__r.pse__Region__c, Rate_Card__r.pse__Practice__c, 
    				Rate_Card__r.pse__Average_Cost_Rate__c, Rate_Card__r.pse__Suggested_Bill_Rate__c,
    				Rate_Card__r.pse__Region__r.Name, Rate_Card__r.pse__Role__c,
    				Rate_Card__r.pse__Practice__r.Name,
    				// need to get resource level queried
    				Rate_Card__r.E2_Resource_Level__c, Resource_Level__c,
    				Practice_Id__c, Region_Id__c
    				FROM E2_Estimate_Rate_Card__c 
    				WHERE Estimate__c =: estimateId
    				ORDER BY Practice__c ASC, Region__c ASC, Resource_Role__c ASC];
  }
  
  public static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(id estimateId){
      // 12/26 Added resource level field in the query
     return [SELECT Id, Resource_Role__c, Estimate__c, Region__c, CurrencyIsoCode,
    				Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
    				Bill_Rate__c, Discounted_Rate__c, Category__c,
    				Rate_Card__r.pse__Region__c, Rate_Card__r.pse__Practice__c 
    				, Rate_Card__r.Description__c, Rate_Card__r.pse__Practice__r.Name,
    				Rate_Card__r.pse__Region__r.Name, Rate_Card__r.pse__Role__c,
    				// need to get resource level queried
    				Rate_Card__r.E2_Resource_Level__c, Resource_Level__c,
    				Practice_Id__c, Region_Id__c
    				FROM E2_Estimate_Rate_Card__c 
    				WHERE Estimate__c =: estimateId
    				ORDER BY Practice__c ASC, Region__c ASC, Resource_Role__c ASC];
  }
  
  public static List<pse__Rate_Card__c> getpseRateCardRecs(Set<Id>rateCardIds, String currencyCode){
      // we have special condition setup to retrieve the pse rate card for selected currency code in an estimate record. 
      // user should be able to fetch rate card in following conditions:
      // 1. No Start/End defined - When start date and end date both are NULL
      // 2. No End date defined but start date - When there is no end date defined and start date is less than equals today
      // 3. No Start date defined but end date - When there is no start date defined and end date is greater than today
      // 4. Both start date and end date defined - start date is less than equals today and end date is greater than equals to today
      
      // 12/26 Added resource level field in the query
     return [SELECT Id, pse__Average_Cost_Rate__c, pse__Practice__c, pse__Region__c,
					pse__Practice__r.Name, Code__c, 
		            pse__Region__r.Name, pse__Role__c, pse__Suggested_Bill_Rate__c,
		            // need to get resource level queried
		            E2_Resource_Level__c
		            FROM pse__Rate_Card__c 
		            WHERE CurrencyISOCode =: currencyCode AND ID NOT IN : rateCardIds AND 
				    ((pse__Start_Date__c = NULL AND pse__End_Date__c = NULL) OR 
				    (pse__Start_Date__c <= TODAY AND pse__End_Date__c = NULL) OR 
				    (pse__End_Date__c >= TODAY AND pse__Start_Date__c = NULL) OR
				    (pse__Start_Date__c <= TODAY AND pse__End_Date__c >= TODAY))];
  }
  
  public static List<pse__Rate_Card__c> getPSERateCardRecords(string currencyCode) {
      // 12/26 Added resource level field in the query
  	return [SELECT Id, pse__Average_Cost_Rate__c,pse__Practice__r.Name, Code__c, Description__c,
		    pse__Region__r.Name, pse__Role__c, pse__Suggested_Bill_Rate__c, pse__Practice__c, pse__Region__c,
		    // need to get resource level queried
		    E2_Resource_Level__c
		    FROM pse__Rate_Card__c 
		    WHERE CurrencyISOCode =: currencyCode AND 
		    ((pse__Start_Date__c = NULL AND pse__End_Date__c = NULL) OR 
		    (pse__Start_Date__c <= TODAY AND pse__End_Date__c = NULL) OR 
		    (pse__End_Date__c >= TODAY AND pse__Start_Date__c = NULL) OR
		    (pse__Start_Date__c <= TODAY AND pse__End_Date__c >= TODAY))];
  }
  
  //To get the templates for milestone scheduling - (Added by - Vikash Goyal - 9/13/2016)
  public static List<E2_Milestone_Library__c> getMilestoneScheduleTemplates(){
      return [SELECT Id, Name
                    FROM E2_Milestone_Library__c 
                    WHERE Is_Active__c = true
                    ORDER BY Name];
  }
  
  public static E2_Question__c getE2Questions(Id questionId){
    return [SELECT Id, Question_Text__c, Scope__c, Source_Question__c, 
  			Type__c, Is_Active__c, Weighted_Effort_LOE__c,
  			(SELECT Id, Answer_Text__c, Effort_LOE__c, Is_Selected__c, 
  			  Sequence__c, Source_Answer__c, Is_Active__c, Question__c, Action__c 
  			 FROM Answers__r ORDER BY Sequence__c)
  			 FROM E2_Question__c
  			 WHERE Id =: questionId];  
  }
  
  public static List<E2_Scope__c> getEstimateScopeParentMapping(Id estimateId) {
      return [SELECT Id, Name, Parent_Scope__c, Scope_Item_Type__c FROM 
              E2_Scope__c WHERE Presales_LOE__c =:estimateId ORDER BY Sequence__c NULLS LAST];
  }
  
  public static List<E2_Effort__c> getAllActiveScopeEffortsByEstimateId(Id estimateId) {
      // 12/26 Added resource level field in the query
      return [SELECT Phase__c, Resource_Role__c, Low_Effort_Hrs__c, High_Effort_Hrs__c, Scope__r.Complexity__c, 
              Effort_Hrs__c, Scope__c, Resource_Level__c, Scope__r.Effort_Quantity__c FROM E2_Effort__c WHERE 
              Scope__r.Presales_LOE__c =:estimateId AND Scope__r.Is_Active__c = true ORDER BY Scope__r.Sequence__c NULLS LAST];
  }
  
  public static List<E2_Scope__c> getChildScopesOfEstimate(List<CMC_Presales_LOE__c> presalesList){
       return [SELECT Id                               
               FROM E2_Scope__c 
               WHERE Presales_LOE__c IN : presalesList];   
   }
   
   public static List<E2_Scope__c> getChildScopesOfScopeLibrary(List <E2_Scope_Group__c> scopeGroups){
       return [SELECT Id                               
               FROM E2_Scope__c 
               WHERE Scope_Group__c IN : scopeGroups];   
  }
  
  public static list<CMC_Presales_LOE__c> getMultiTimelineEstimates(Id estimateId) {
      return [SELECT Id, E2_Is_specific_to_timeline__c, E2_Is_Active__c, E2_Timeline_Name__c, CreatedDate 
              FROM CMC_Presales_LOE__c
              WHERE E2_Parent_Estimate__c =:estimateId 
              ORDER BY CreatedDate ASC];
  }
  
  public static List<CMC_Presales_LOE__c> getTimelinesOfEstimate(List<CMC_Presales_LOE__c> presalesList){
       return [SELECT Id                               
               FROM CMC_Presales_LOE__c 
               WHERE E2_Parent_Estimate__c IN : presalesList];   
   }
   
   public static List<CMC_Estimate_Resource__c> getEstimateResources(List<CMC_Presales_LOE__c> presalesList){
       return [SELECT Id
               FROM CMC_Estimate_Resource__c 
               WHERE Estimate__c IN :presalesList OR ESTIMATE__r.E2_Parent_Estimate__c IN :presalesList];
   }
   
   public static List<E2_Estimate_Milestone__c> getEstimateMilestones(List<CMC_Presales_LOE__c> presalesList){
       return [SELECT Id
               FROM E2_Estimate_Milestone__c 
               where Estimate__c IN :presalesList OR ESTIMATE__r.E2_Parent_Estimate__c IN :presalesList];   
   }
   
   public static list<CMC_Presales_LOE__c> getPSEEstimateDetailsForRelatedList(id psrId) {
       return [SELECT Id, Name, As_Sold_Margin__c, Total_Fees__c, Calculated_Costs__c, 
                Jaipur_Hours__c, Hours_Jaipur__c, Total_Resource_Hours__c, 
                Service_Fees__c, Mode__c, Blended_Rate_Number__c, E2_Is_Active__c,
                CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate,
                Default__c, (SELECT  Total_Fees__c, Calculated_Costs__c, 
                Hours_Jaipur__c, Total_Resource_Hours__c, Service_Fees__c, 
                E2_Is_Active__c, E2_Parent_Estimate__c
                FROM Presales_Estimates__r 
                WHERE E2_Is_Active__c = true)
                FROM CMC_Presales_LOE__c 
                WHERE Presales_Request__c = :psrId 
                ORDER BY LastModifiedDate DESC];
   }
   
   public static list<CMC_Presales_LOE__c> getEstimateTimelinesSummary(Id estimateId) {
       return [SELECT id, Name, Mode__c, E2_Timeline_Name__c, CurrencyISOCode,
               Service_Fees__c, Service_Costs__c, Service_Margin__c, Services_Uplifted_Costs__c,              
               Calculated_Fees__c, Calculated_Costs__c, Calculated_Margin__c,
               Discount_Percent__c, Discount_Amount__c, Discount__c,
               Total_Fees__c, Final_Total__c, As_Sold_Margin__c,
               Blended_Rate_Number__c, Offshore_Blend__c,
               Fixed_Fee_Cost_Uplift__c, Fixed_Fee_Cost_Uplift_Percent__c, Fixed_Fee_Buffer__c,
               Fixed_Fee_Blended__c, Fixed_Fee_Buffer_Amount__c,
               Total_Resource_Hours__c, E2_Estimate_Total_Weeks__c,
               Hours_Jaipur__c, Jaipur_Hours__c
               FROM CMC_Presales_LOE__c 
               WHERE (Id = :estimateId OR E2_Parent_Estimate__c = :estimateId) AND E2_Is_Active__c = true
               ORDER BY CreatedDate];
   }
   
   public static list<CMC_Estimate_Resource__c> getEstimateResourceForTimeline(set<Id> activeTimelines) {
       return [SELECT Total_Hours__c, Estimate__c, E2_Estimate_Rate_Card__r.Resource_Level__c 
               FROM CMC_Estimate_Resource__c 
               WHERE Estimate__c IN :activeTimelines];
   }
   
   public static list<CMC_Presales_LOE__c> getEstimateTimelineDetails(id estimateId) {
       return [SELECT Mode__c, Service_Fees__c, Service_Costs__c, Service_Margin__c,                
                      Calculated_Fees__c, Calculated_Costs__c, Calculated_Margin__c,
                      Discount_Percent__c, Discount_Amount__c, Discount__c,
                      Total_Fees__c, As_Sold_Margin__c, Blended_Rate_Number__c,
                      Offshore_Blend__c, Services_Uplifted_Costs__c,
                      Fixed_Fee_Cost_Uplift__c, Fixed_Fee_Cost_Uplift_Percent__c,
                      Fixed_Fee_Buffer__c, Fixed_Fee_Blended__c, Fixed_Fee_Buffer_Amount__c,
                      Total_Resource_Hours__c, E2_Estimate_Total_Weeks__c,Hours_Jaipur__c, 
                      Jaipur_Hours__c, Pass_Through__c, E2_Is_Active__c, 
                      (SELECT Mode__c, Service_Fees__c, Service_Costs__c, Service_Margin__c,                
                              Calculated_Fees__c, Calculated_Costs__c, Calculated_Margin__c,
                              Discount_Percent__c, Discount_Amount__c, Discount__c,
                              Total_Fees__c, As_Sold_Margin__c, Blended_Rate_Number__c,
                              Offshore_Blend__c, Services_Uplifted_Costs__c,
                              Fixed_Fee_Cost_Uplift__c, Fixed_Fee_Cost_Uplift_Percent__c,
                              Fixed_Fee_Buffer__c, Fixed_Fee_Blended__c, Fixed_Fee_Buffer_Amount__c,
                              Total_Resource_Hours__c, E2_Estimate_Total_Weeks__c,
                              Hours_Jaipur__c, Jaipur_Hours__c, Pass_Through__c 
                        FROM Presales_Estimates__r 
                        WHERE E2_Is_Active__c = true) 
                FROM CMC_Presales_LOE__c 
                WHERE Id = :estimateId];
   }
   
   public static list<CMC_Presales_LOE__c> getEstimateDerivedEffortId(Id estimateId) {
       return [SELECT E2_Derived_Effort_Template__c 
               FROM CMC_Presales_LOE__c 
               WHERE Id = :estimateId];
   }
}