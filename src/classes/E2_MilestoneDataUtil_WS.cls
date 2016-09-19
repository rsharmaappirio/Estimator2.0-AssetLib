/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneDataUtil_WS
 * Description: This is the utility class used by E2_MilestoneWSManager.cls
 * Created Date: Sept 12th, 2016
 * Created By: Arpita Bose(Appirio)
 * 
 * Date Modified       Modified By          Description
 * 
*  =====================================================================*/
public class E2_MilestoneDataUtil_WS {
    
    public static List<E2_Estimate_Milestone__c> getEstimateMilestones(String estimateId){
      //method to get all the estimate milestone records for an estimate    
      return [SELECT Id
                 FROM E2_Estimate_Milestone__c
                 WHERE Estimate__c = :estimateId];    
    }
    
    public static List<E2_Estimate_Milestone_Week__c> getEstimateMilestoneWeeks(Set<String> weekIds, Set<String> milestoneIds){
      //method to get milestone week for given set of milestoneIds and weekIds
      return [SELECT ID, Text__c, TextColorCode__c, Estimate_Milestone__c, Estimate_Week__c   
                FROM E2_Estimate_Milestone_Week__c
                WHERE Estimate_Week__c IN :weekIds
                AND Estimate_Milestone__c IN :milestoneIds];
    }
    
    public static List<E2_Estimate_Milestone__c> getMilestone(String estimateId, String milestoneId){
      //method to get all the estimate milestone records for an estimate    
      return [SELECT Id, Milestone1__c, Milestone2__c
                 FROM E2_Estimate_Milestone__c
                 WHERE Estimate__c = :estimateId 
                 AND Id = : milestoneId];    
    }
    
    public static List<E2_Estimate_Milestone_Week__c> getEstimateMilestoneWeeksforWeek(String weekId, String milestoneId){
      //method to get milestone week for given set of milestoneIds and weekIds
      return [SELECT ID, Text__c, TextColorCode__c, Estimate_Milestone__c, Estimate_Week__c   
                FROM E2_Estimate_Milestone_Week__c
                WHERE Estimate_Week__c = :weekId
                AND Estimate_Milestone__c = :milestoneId];
    }
    
    public static List<E2_Estimate_Milestone__c> getEstimateMilestoneAndAllWeeks(String estimateId){
      //method to get estimate milestone and all milestone week records for an estimate 
      return  [SELECT Id, Name, Milestone1__c, Milestone2__c, Order__c,  
                 (SELECT ID, Text__c, TextColorCode__c, Estimate_Week__c, Estimate_Milestone__c
                  FROM Estimate_Milestone_Weeks__r)  
                  FROM E2_Estimate_Milestone__c
                  WHERE Estimate__c = :estimateId
                  ORDER BY Order__c ASC];    
    }
    
    public static List<E2_Timeline_Milestone__c> getTimelineMilestones(String selectedLibrary){
      //method to get all active milestones related to selected milestone template library
      return  [SELECT Id, Name, Milestone1__c, Milestone2__c, Order__c  
                  FROM E2_Timeline_Milestone__c
                  WHERE E2_Milestone_Library__c = :selectedLibrary
                  AND Is_Active__c = true
                  ORDER BY Order__c ASC];    
    }
}