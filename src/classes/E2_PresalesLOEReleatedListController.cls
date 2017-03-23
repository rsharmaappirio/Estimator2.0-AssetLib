/**=====================================================================
 * Appirio, Inc
 * Name: E2_PresalesLOEReleatedListController
 * Description: Controller class for E2_PresalesLOEReleatedList page
 * Created Date: Mar 6th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/
public class E2_PresalesLOEReleatedListController {
    
    public Presales_Request__c psr{get;set;}
    public string estimateIdToDelete{get;set;}
    public string errorMessage{get;set;}
    public list<EstimateSummary> estimateSummary{get;set;}
    
    public E2_PresalesLOEReleatedListController(ApexPages.StandardController controller) {
        this.psr = (Presales_Request__c) controller.getRecord(); //Get PSR from controller.
        this.estimateSummary = new list<EstimateSummary>();
    }
    
    public PageReference pageAction() {
        this.errorMessage = E2_Constants.BLANK;
        loadEstimates();
        return null;
    }
    
    // method to load Estimate summary in EstimateSummary wrapper.
    public void loadEstimates() {
        this.errorMessage = E2_Constants.BLANK;
        this.estimateSummary.clear();
        for(CMC_Presales_LOE__c estimate : E2_DataUtil.getPSEEstimateDetailsForRelatedList(this.psr.Id)) {
            EstimateSummary estimateSummary = new EstimateSummary( estimate );
            if(estimate.Presales_Estimates__r.size() > 0) {
                decimal totalFee = 0;
                    decimal cost = 0;
                    decimal jaipurHours = 0;
                    decimal totalHours = 0;
                    decimal serviceFee = 0;
                    integer numberOfActiveTimeline = estimate.Presales_Estimates__r.size();
                    estimateSummary.isPrimary = estimate.Default__c;
                    if(estimateSummary.estimate.E2_Is_Active__c) {
                        totalFee = estimateSummary.estimate.Total_Fees__c;
                        cost = estimateSummary.estimate.Calculated_Costs__c;
                        jaipurHours = estimateSummary.estimate.Hours_Jaipur__c;
                        totalHours = estimateSummary.estimate.Total_Resource_Hours__c;
                        serviceFee = estimateSummary.estimate.Service_Fees__c;
                        numberOfActiveTimeline +=  1;
                    }
                    for(CMC_Presales_LOE__c activeTimeline : estimate.Presales_Estimates__r) {
                        totalFee += activeTimeline.Total_Fees__c;
                        cost += activeTimeline.Calculated_Costs__c;
                        jaipurHours += activeTimeline.Hours_Jaipur__c;
                        totalHours += activeTimeline.Total_Resource_Hours__c;
                        serviceFee += activeTimeline.Service_Fees__c;
                    }
                    estimateSummary.totalFee = totalFee;
                    estimateSummary.asSoldMargin = totalFee <> 0 ? (1 - (cost/totalFee)) * 100 : 0 ;
                    estimateSummary.blendedRate = totalHours <> 0 ? (serviceFee/totalHours) : 0;
                    estimateSummary.jaipurHoursPct = totalHours <> 0 ? (jaipurHours/totalHours) * 100 : 0;
                    estimateSummary.numberOfActiveTimeline = numberOfActiveTimeline;
            } else {
                estimateSummary.totalFee = estimate.Total_Fees__c;
                estimateSummary.asSoldMargin = estimate.As_Sold_Margin__c;
                estimateSummary.blendedRate = estimate.Blended_Rate_Number__c;
                estimateSummary.jaipurHoursPct = estimate.Jaipur_Hours__c;
                estimateSummary.numberOfActiveTimeline = 1;
                estimateSummary.isPrimary = estimate.Default__c;
            }
            this.estimateSummary.add(estimateSummary);
        }
    }
    
    public void deleteEstimate() {
        if(string.isNotBlank(estimateIdToDelete)) {
            try {
                delete (new CMC_Presales_LOE__c(Id = estimateIdToDelete));
                loadEstimates();
           } catch(Exception ex) {
                errorMessage = 'Error in deleting estimate. Please try again later or contact system adminstrator';
            }
        }
    }
    
    public Class EstimateSummary {
        public CMC_Presales_LOE__c estimate{get;set;}
        public decimal totalFee{get;set;}
        public decimal asSoldMargin{get;set;}
        public decimal blendedRate{get;set;}
        public decimal jaipurHoursPct{get;set;}
        public boolean isPrimary{get;set;}
        public decimal numberOfActiveTimeline{get;set;}
        
        public EstimateSummary(CMC_Presales_LOE__c estimate) {
            this.estimate = estimate;
        }
    }
}