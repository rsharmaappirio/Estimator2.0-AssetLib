/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineDataUtil_WS
 * Description: This is the utility class used by E2_TimelineWSManager.cls
 * Created Date: Aug 26, 2016
 * Created By: Arpita Bose(Appirio)
 * 08 Sep 2016: Modified: RJ : Added E2_Estimate_Rate_Card__r.Resource_Role__c, E2_Estimate_Rate_Card__r.Region__c field in the query in getEstimateResourceAndResourceWeekRec method for 
 *                             Capacity Needs and Timeline Hours based on roles
*  =====================================================================*/
public class E2_TimelineDataUtil_WS {
  //method to get E2_Estimate_Rate_Card__c records for an estimateId
  public static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(String estimateId){
    return [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
              Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
              Bill_Rate__c, Discounted_Rate__c, Category__c  
              FROM E2_Estimate_Rate_Card__c 
              WHERE Estimate__c = :estimateId
              ORDER BY Region__c ASC, Resource_Role__c ASC];
  }
  
  //method to get Hours from CMC_Estimate_Resource_Week__c for a week and a resource
  public static List<CMC_Estimate_Resource_Week__c> getHoursforEstimateResourceWeek(string weekId, string resourceId){
    return [SELECT ID, Hours__c   
              FROM CMC_Estimate_Resource_Week__c
              WHERE Estimate_Week__c = :weekId
              AND Estimate_Resource__c = :resourceId];
  }
  
  //method to get CMC_Estimate_Resource_Week__c records for set of week and resource Ids
  public static List<CMC_Estimate_Resource_Week__c> getEstimateResourceWeekRecords(Set<String>weekIds, Set<String>resourceIds){
    return [SELECT ID, Hours__c, Estimate_Resource__c, Estimate_Week__c   
              FROM CMC_Estimate_Resource_Week__c
              WHERE Estimate_Week__c IN :weekIds
              AND Estimate_Resource__c IN :resourceIds];
  }
  
  //method to get currencyISOcode for an estimate
  public static List<CMC_Presales_LOE__c> getCurrencyISOCodeonEstimate(String estimateId){
    return [SELECT CurrencyIsoCode 
              FROM CMC_Presales_LOE__c 
              WHERE Id = :estimateId];
  }
  
  //method to get CMC_Estimate_Week__c records for an estimateId
  public static List<CMC_Estimate_Week__c> getEstimateWeekRecords(String estimateId){
    return [SELECT Id, Date__c, Name, Order__c, Estimate__c, Phase__c, Milestone__c, E2_PhaseColorCode__c, E2_MilestoneColorCode__c
              , E2_Milestone1__c, E2_Milestone1ColorCode__c, E2_Milestone2__c, E2_Milestone2ColorCode__c 
              FROM CMC_Estimate_Week__c                                                    
              WHERE Estimate__c = :estimateId
              ORDER BY Date__c ASC, Order__c ASC];
  }
  
  
  
  //method to get CMC_Estimate_Resource__c and all Estimate_Resource_Week__c records for an estimateId 
  public static List<CMC_Estimate_Resource__c> getEstimateResourceAndResourceWeekRec(String estimateId){
    return [SELECT Id, Name, Cost__c, Estimate__c, Order__c, Rate__c, Role__c, E2_Role__c, Skill__c, E2_Estimate_Rate_Card__r.Resource_Role__c, E2_Estimate_Rate_Card__r.Region__c,
              (SELECT ID, Hours__c, Estimate_Week__c, Estimate_Resource__c
               FROM Estimate_Resource_Weeks__r)  
              FROM CMC_Estimate_Resource__c
              WHERE Estimate__c = :estimateId
              ORDER BY Order__c ASC];
  }
  
  //method to get CMC_Estimate_Resource__c for Skill updation for an estimateId and resourceId
  public static List<CMC_Estimate_Resource__c> getEstimateResourceForSkill(String estimateId, string resourceId){
      return [SELECT Id, Skill__c
              FROM CMC_Estimate_Resource__c
              WHERE Estimate__c = :estimateId
              AND id = : resourceId];
    
  }

}