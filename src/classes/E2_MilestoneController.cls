/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneController
 * Description: Controller class for E2_Milestone page
 * Created Date: Aug 12th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
public with sharing class E2_MilestoneController extends E2_Master {
    
  public CMC_Presales_LOE__c estimate {get;set;}
  public String selectedTemplate {get;set;}
  
  public E2_MilestoneController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    selectedTemplate = '';
  }
  
  
  public PageReference pageAction(){
    // method for page action 
    super.validateAccess(this.estimate);
    return null;
  }
  
  public List<SelectOption> getAvailableMilestoneSchTemplates() {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', '---Select Template---'));
      for(E2_Milestone_Library__c mileStoneLib : E2_DataUtil.getMilestoneScheduleTemplates()){
        options.add(new SelectOption(mileStoneLib.Id, mileStoneLib.Name));
      }
     
      return options;
  }
}