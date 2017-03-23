/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineController
 * Description: Controller class for E2_Timeline page
 * Created Date: Aug 12th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
 * Oct 26th, 2016     Rohit Sharma        S-447680 : Round off the hours to nearest figure on capacity tab.
 * Nov 11th, 2016     Rohit Sharma        S-447474 : Fixed fee calculation support
 * Nov 23th, 2016     Rohit Sharma        S-455804 : Default fixed fee uplift cost and buffer
 * Dec 26, 2016       Rahul Jain          S-459273 : Added Resource Level field in getEstimateRateCards method
 * Dec 27, 2016       Rahul Jain          S-459273 : Updated populateCapacityNeeds method to add resource level logic
*  =====================================================================*/
public with sharing class E2_TimelineController extends E2_Master {
    
  public CMC_Presales_LOE__c estimate {get;set;}
  public E2_System_setting__c e2SystemSetting{get;set;}
  public list<E2_TimelineEstimates> timelineEstimates{get;set;}
  public string newTimelineId{get;set;}
  public boolean timelineStatusActive{get;set;}
  public string timelineName{get;set;}
  public string capacityNeeds_JSON{get;set;}

  public E2_TimelineController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    e2SystemSetting = E2_System_setting__c.getInstance();
    timelineEstimates = new list<E2_TimelineEstimates>();
    timelineEstimates.add(new E2_TimelineEstimates(estimate));
    newTimelineId = NULL;
  }
  
  
  public PageReference pageAction() {
    // method for page action 
    PageReference page = super.validateForTimelineEstimate(this.estimate);
    if(page <> NULL) return page;
    super.validateAccess(this.estimate);
    for(CMC_Presales_LOE__c childEstimate : E2_DataUtil.getMultiTimelineEstimates(estimate.Id)) {
        timelineEstimates.add(new E2_TimelineEstimates(childEstimate));
    }
    if(timelineEstimates.size() == 1) timelineEstimates.get(0).isActive = true; 
    timelineEstimates.sort();
    populateCapacityNeeds();
    return null;
  }
  
  public PageReference refreshTimelineEstimates() {
     timelineEstimates.clear();
     timelineEstimates.add(new E2_TimelineEstimates(estimate));
     for(CMC_Presales_LOE__c childEstimate : E2_DataUtil.getMultiTimelineEstimates(estimate.Id)) {
        timelineEstimates.add(new E2_TimelineEstimates(childEstimate));
    }
    timelineEstimates.sort();
    return null;
  }
  
  public void populateCapacityNeeds() {
      // method to populate the capacityNeeds_JSON variable with Phase hours
      // Role hours and total capacity needs from Capicity needs calculated 
      // from Scopes
    this.capacityNeeds_JSON = E2_Estimator_Manager.populateCapacityNeeds(this.estimate.Id);
  }
  
  public PageReference updateTimelineStatus() {
      if(string.isNotBlank(newTimelineId)){
          try {
              update (new CMC_Presales_LOE__c(Id = newTimelineId, E2_Is_Active__c = timelineStatusActive));
              for(E2_TimelineEstimates timelineEstimate : timelineEstimates) {
                  if(timelineEstimate.estimateId == newTimelineId) timelineEstimate.isActive = timelineStatusActive;
              }
          } catch(Exception ex) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error updating timeline status.'+ex.getMessage()));
          }
      }
      return null;
  }
  
  public PageReference updateTimelineName() {
      if(string.isNotBlank(newTimelineId) && string.isNotBlank(timelineName)){
          try {
              update (new CMC_Presales_LOE__c(Id = newTimelineId, E2_Timeline_Name__c = timelineName));
              for(E2_TimelineEstimates timelineEstimate : timelineEstimates) {
                 if(timelineEstimate.estimateId == newTimelineId) timelineEstimate.timelineName = timelineName;
              }
              // update timeline name in base estimate if newTimelineId is equals estimate.Id
              if(newTimelineId == estimate.Id) estimate.E2_Timeline_Name__c = timelineName;
          } catch(Exception ex) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error updating timeline status.'+ex.getMessage()));
          }
      }
      return null;
  }
}