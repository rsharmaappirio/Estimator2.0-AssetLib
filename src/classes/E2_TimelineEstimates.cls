/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineEstimates
 * Description: Wrapper class of Estimates used for multiple timeline
 * Created Date: Feb 14th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
global class E2_TimelineEstimates implements Comparable {
    public id estimateId {get;set;}
      //public id parentEstimateId {get;set;}
    public boolean isTimelineSpecific {get;set;}
    public boolean isActive {get;set;}
    public DateTime createdDate {get;set;} 
    public string timelineName{get;set;}

    
    public E2_TimelineEstimates(CMC_Presales_LOE__c estimate){
      this.estimateId = estimate.Id;
      this.isTimelineSpecific = estimate.E2_Is_specific_to_timeline__c;
      this.isActive = estimate.E2_Is_Active__c;
      this.createdDate = estimate.CreatedDate;
      this.timelineName = estimate.E2_Timeline_Name__c;
    }
    
    // method to compare fields based on sort_by/ sort_order 
    global Integer compareTo(Object objToCompare) {
        long dt1 = createdDate.getTime() / 1000;
        long dt2 = ((E2_TimelineEstimates)objToCompare).createdDate.getTime() /1000;
        
        return Integer.valueOf(dt1 - dt2);
    }
    
  }