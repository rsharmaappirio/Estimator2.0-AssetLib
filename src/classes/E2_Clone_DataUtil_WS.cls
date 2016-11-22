/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_DataUtil_WS
 * Description: S-454105 : Utility class as Data Tier for E2_Clone_Estimate_WS (webservice)
 * Created Date: Nov 22th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
public with sharing class E2_Clone_DataUtil_WS {
    
    // S-454105 :Get Estimate full details 
   public static List<CMC_Presales_LOE__c> getEstimateFullDetailById(string estimateId) {
       return [SELECT Id, Name, Description__c, Presales_Request__c, Type__c, Account_Name__c, Mode__c, Opportunity_Name__c, 
                Date_Scoped__c, Product__c, Account_Executive__c, Solution_Architect__c, Delivery_Reviewer__c, 
                CurrencyISOCode, Discount_Percent__c, Discount__c, Fixed_Fee_Cost_Uplift_Percent__c, Fixed_Fee_Buffer__c, 
                Fixed_Fee_Blended__c, Topcoder_Challenge_Fees__c, Asset_Fees__c, Discount_PCT__c, Offshore_Blend_PCT__c, 
                Blended_Rate__c, E2_Date_Scoped__c, E2_Version_Notes__c, E2_Reviewer__c, E2_SA__c, E2_AE__c, E2_Is_Primary__c, 
                E2_Total_Hrs__c, E2_Derived_Effort_Template__c, E2_Last_Build_Datetime__c, E2_Risk__c 
                FROM CMC_Presales_LOE__c 
                WHERE Id =: estimateId];
   }
   
   // S-454105 :Get Full Scope Details By Estimate Id
   public static List<E2_scope__c> getFullScopesDetailsByEstimateId(string estimateId) {
   	return [Select e.Source_Scope__c, e.Scope_Group__c, e.Parent_Scope__c, e.Name, 
                   e.Presales_LOE__c, e.Description__c , e.LOE_Hrs__c, 
                   e.Complexity__c, e.Scope_Item_Type__c, e.Is_Active__c, e.Scope_Flag__c, 
                   e.E2_Assumption__c, e.RecordTypeId, e.Display_Order__c,
            (Select Id, Name, Scope__c, Complexity_Factor_High__c, Resource_Role__c, Phase__c, Effort_Hrs__c, Speciality__c, 
             Complexity_Factor_Low__c, Is_Active__c, Source_Effort__c FROM Efforts__r),
             (SELECT Id, Scope__c, Asset__c FROM E2_Recommended_Assets__r),
             (SELECT Id, Question_Text__c, Scope__c, Source_Question__c, 
  			  Type__c, Is_Active__c, Weighted_Effort_LOE__c FROM Questions__r) 
            FROM E2_Scope__c e 
            WHERE e.Presales_LOE__c =: estimateId];
   }
   
   // S-454105 :Get Full Capacity Needs by Estimate Id 
   public static List<E2_Capacity__c> getCapacityListByEstimateId(string estimateId) {
  	return [SELECT Id, Role__c, Phase__c, Speciality__c,  Hours__c, Estimator__c  
  			FROM E2_Capacity__c 
  			WHERE Estimator__c = :estimateId];
  }
  
  // S-454105 :Get Full Estimate Week Milestones details by Estimate Id
  public static list<E2_Estimate_Week_Milestone__c> getEstimateWeekMilestonesByEstimateId(string estimateId) {
      return [SELECT Id, Name, Date__c, Estimate__c, Order__c 
              FROM E2_Estimate_Week_Milestone__c 
              WHERE Estimate__c =: estimateId];
  }
  
  // S-454105 :Get Full Estimate Milestones details by Estimate Id
  public static list<E2_Estimate_Milestone__c> getEstimateMilestonesByEstimateId(string estimateId) {
      return [SELECT Id, Estimate__c, Order__c, Milestone1__c, Milestone2__c  
              FROM E2_Estimate_Milestone__c 
              WHERE Estimate__c =: estimateId];
  }
  
  // S-454105 :Get Milestone Week Junction object by Milestone and week-milestone
  public static list<E2_Estimate_Milestone_Week__c> getMilestonesWeeks(set<id> milestones, set<id> weeks) {
      return [SELECT Estimate_Milestone__c, Estimate_Week_Milestone__c, Text__c, TextColorCode__c 
              FROM E2_Estimate_Milestone_Week__c 
              WHERE Estimate_Milestone__c IN: milestones AND Estimate_Week_Milestone__c IN: weeks];
  }
  
  // S-454105 :Get Estimate rate Cards by EstimateId
  public static list<E2_Estimate_Rate_Card__c> getEstimateRateCardsByEstimateId(string estimateId) {
      return [SELECT Id, Bill_Rate__c, Category__c, Code__c, Discounted_Rate__c, Estimate__c, 
              Practice__c, Rate_Card__c, Region__c, Resource_Cost__c, Resource_Role__c 
              FROM E2_Estimate_Rate_Card__c 
              WHERE Estimate__c =: estimateId];
  }
  
  // S-454105 :Get Full Estimate Week details by Estimate Id
  public static list<CMC_Estimate_Week__c> getEstimateWeekMByEstimateId(string estimateId) {
      return [SELECT Id, Name, Date__c, Estimate__c, Milestone__c, E2_Milestone1__c, E2_Milestone2__c, 
              E2_Milestone1ColorCode__c, E2_Milestone2ColorCode__c, E2_MilestoneColorCode__c, Order__c, 
              Phase__c, E2_PhaseColorCode__c 
              FROM CMC_Estimate_Week__c 
              WHERE Estimate__c =: estimateId];
  }
  
  // S-454105 :Get Full Estimate Resource Request details by Estimate Id
  public static list<CMC_Estimate_Resource__c> getResourceRequestByEstimateId(string estimateId) {
      return [SELECT Id, Name, CurrencyIsoCode, Estimate__c, Cost__c, Order__c, Rate__c, Role__c, 
              Skill__c, Hours_Type__c, Is_Used_For_Calculations__c, Rate_Code__c, Resource_Column__c, 
              E2_Estimate_Rate_Card__c, E2_Role__c 
              FROM CMC_Estimate_Resource__c 
              WHERE Estimate__c =: estimateId];
  }
  
  // S-454105 :Get Resource Week Junction object by Resource request and weeks
  public static list<CMC_Estimate_Resource_Week__c> getResourceWeeks(set<id> resources, set<id> weeks) {
      return [SELECT Hours__c, Estimate_Resource__c, Estimate_Week__c 
              FROM CMC_Estimate_Resource_Week__c 
              WHERE Estimate_Resource__c IN: resources AND Estimate_Week__c IN: weeks];
  }

}