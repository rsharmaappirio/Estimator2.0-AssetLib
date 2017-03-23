/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateController
 * Description: S-464465: Controller class for E2_MilestoneTemplate page
 * Created Date: Feb 02th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
public with sharing class E2_MilestoneTemplateController {
    
  public E2_Milestone_Library__c template {get;set;}
  //public String selectedTemplate {get;set;}
  
  public E2_MilestoneTemplateController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.template = (E2_Milestone_Library__c)std.getRecord();
    //selectedTemplate = '';
  }
  
  
  public PageReference pageAction(){
    // method for page action 
    return null;
  }
  
  /*public List<SelectOption> getAvailableMilestoneSchTemplates() {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', '---Select Template---'));
      for(E2_Milestone_Library__c mileStoneLib : E2_DataUtil.getMilestoneScheduleTemplates()){
        options.add(new SelectOption(mileStoneLib.Id, mileStoneLib.Name));
      }
     
      return options;
  }*/
}