/**=====================================================================
 * Appirio, Inc
 * Name: E2_CustomerTimelineController
 * Description: S-456643: Controller class for E2_CustomerTimeline page
 * Created Date: Feb 01st, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/
public with sharing class E2_CustomerTimelineController extends E2_Master {
    
  public CMC_Presales_LOE__c estimate {get;set;}
  public string renderOptions_PhasesJSON{get;set;}
  public string capacityNeeds_JSON{get;set;}
  public static final string SEPARATOR = ' - ';
  private string primaryTimelineId;

  public E2_CustomerTimelineController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    primaryTimelineId = this.estimate.E2_Parent_Estimate__c <> NULL ? this.estimate.E2_Parent_Estimate__c : this.estimate.Id;
    // populate renderOptions_PhasesJSON field
    populateRenderOptions();
  }
  
  
  public void populateRenderOptions(){
     // method to populate the renderOptions_PhasesJSON variable with phases 
     // and color code utilize in the phase column/row of the grid
     
     Schema.DescribeFieldResult fieldResult = E2_Effort__c.Phase__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
     Map<String, String> phaseColorCodeMap = E2_Constants.PHASE_COLORCODE_MAP;
     
     // TODO: For first instance we are not moving these wild characters in constants; as these characters defines the 
     // logic behind what is happening...
     this.renderOptions_PhasesJSON = '{';
     for( Schema.PicklistEntry f : ple){
      string lineitem = '"' + f.getLabel() + '" : "' + (phaseColorCodeMap.containsKey(f.getLabel()) ? phaseColorCodeMap.get(f.getLabel()) : '') + '"';
      this.renderOptions_PhasesJSON += (this.renderOptions_PhasesJSON == '{' ? '' : ',') + lineitem;
     }
     this.renderOptions_PhasesJSON += '}';
  }
  
  public PageReference pageAction(){
    // method for page action 
    super.validateAccess(this.estimate);
    populateCapacityNeeds();
    return null;
  }
  
  public void populateCapacityNeeds() {
      // method to populate the capacityNeeds_JSON variable with Phase hours
      // Role hours and total capacity needs from Capicity needs calculated 
      // from Scopes
      this.capacityNeeds_JSON = E2_Estimator_Manager.populateCapacityNeeds(primaryTimelineId);
  }
}