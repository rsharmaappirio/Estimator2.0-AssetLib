/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateDataUtil_WS
 * Description: S-464465: This is the data utility class used by E2_MilestoneTemplateWSManager.cls
 * Created Date: Feb 5th, 2017
 * Created By: Rohit Sharma
 * 
 * Date Modified       Modified By          Description
 * 
*  =====================================================================*/
public class E2_MilestoneTemplateDataUtil_WS {
    
    public static List<E2_Timeline_Milestone__c> getTemplateMilestones(String templateId){
      //method to get all the Template milestone records for an Template    
      return [SELECT Id
                 FROM E2_Timeline_Milestone__c
                 WHERE E2_Milestone_Library__c = :templateId];    
    }
    
    public static List<E2_Milestone_Week_Template_Junction__c> getTemplateMilestoneWeeks(Set<String> weekIds, Set<String> milestoneIds){
      //method to get milestone week for given set of milestoneIds and weekIds
      return [SELECT ID, Text__c, TextColorCode__c, Timeline_Milestone__c, Week_Milestone_Template__c   
                FROM E2_Milestone_Week_Template_Junction__c
                WHERE Week_Milestone_Template__c IN :weekIds
                AND Timeline_Milestone__c IN :milestoneIds];
    }
    
    public static List<E2_Timeline_Milestone__c> getMilestone(String templateId, String milestoneId){
      //method to get all the Template milestone records for an Template    
      return [SELECT Id, Milestone1__c, Milestone2__c
                 FROM E2_Timeline_Milestone__c
                 WHERE E2_Milestone_Library__c = :templateId 
                 AND Id = : milestoneId];    
    }
    
    public static List<E2_Milestone_Week_Template_Junction__c> getTemplateMilestoneWeeksforWeek(String weekId, String milestoneId){
      //method to get milestone week for given set of milestoneIds and weekIds
      return [SELECT ID, Text__c, TextColorCode__c, Timeline_Milestone__c, Week_Milestone_Template__c   
                FROM E2_Milestone_Week_Template_Junction__c
                WHERE Week_Milestone_Template__c = :weekId
                AND Timeline_Milestone__c = :milestoneId];
    }
    
    public static List<E2_Timeline_Milestone__c> getTemplateMilestoneAndAllWeeks(String templateId){
      //method to get Template milestone and all milestone week records for an Template 
      return  [SELECT Id, Name, Milestone1__c, Milestone2__c, Order__c,  
                 (SELECT ID, Text__c, TextColorCode__c, Week_Milestone_Template__c, Timeline_Milestone__c
                  FROM Milestone_Week_Template_Junction__r)  
                  FROM E2_Timeline_Milestone__c
                  WHERE E2_Milestone_Library__c = :templateId
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
    
    //method to get E2_Week_Milestone_Template__c records for an templateId
    public static List<E2_Week_Milestone_Template__c> getTemplateWeekMilestoneRecords(String templateId){
        return [SELECT Id, Date__c, Name, Order__c, Milestone_Library__c
              FROM E2_Week_Milestone_Template__c                                                    
              WHERE Milestone_Library__c = :templateId
              ORDER BY Date__c ASC, Order__c ASC];
    }
}