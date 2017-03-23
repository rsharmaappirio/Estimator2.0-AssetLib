/**=====================================================================
 * Appirio, Inc
 * Name: E2_PresalesLOESummaryController
 * Description: Controller class for E2_PresalesLOESummary page
 * Created Date: Mar 6th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/
public class E2_PresalesLOESummaryController {
    
    public CMC_Presales_LOE__c estimate{get;set;}
    public E2_PresalesLOESummaryController.SummaryWrapper estimateSummary{get;set;}
    public static final integer ONE = 1;
    public static final integer ZERO = 0;
    
    public E2_PresalesLOESummaryController(ApexPages.StandardController controller) {
        this.estimate = (CMC_Presales_LOE__c) controller.getRecord(); //Get LOE from controller.
        this.estimateSummary = new E2_PresalesLOESummaryController.SummaryWrapper();
    }
    
    public PageReference pageAction() {
        if(this.estimate.Id <> NULL) {
            getDetailedEstimateSummary();
        }
        return null;
    }
    
    public void getDetailedEstimateSummary() {
        list<CMC_Presales_LOE__c> estimates = E2_DataUtil.getEstimateTimelineDetails( this.estimate.Id );
        if(!estimates.isEmpty()) {
            this.estimate = estimates.get(0);
            if(estimate.Presales_Estimates__r.size() > ZERO) {
                for(CMC_Presales_LOE__c timeline : estimate.Presales_Estimates__r) {
                    mapTimelineInSummaryRecord( timeline );
                }
                if(estimate.E2_Is_Active__c) {
                    mapTimelineInSummaryRecord( estimate );
                }
                estimateSummary.asSoldMargin = estimateSummary.totalFee <> ZERO ? 
                                                (ONE - (estimateSummary.calculatedCost/estimateSummary.totalFee)) : ZERO ;
                estimateSummary.blendedRate = estimateSummary.totalResourceHours <> ZERO ? 
                                            (estimateSummary.serviceFee/estimateSummary.totalResourceHours) : ZERO;
                estimateSummary.jaipurHoursPct = estimateSummary.totalResourceHours <> ZERO ? 
                                                 (estimateSummary.jaipurHours/estimateSummary.totalResourceHours) : ZERO;
                estimateSummary.fixedFeeBufferPct = estimateSummary.fixedFeeCalculatedFee <> ZERO && estimateSummary.fixedFeeBufferAmount <> ZERO  ?
                                                    estimateSummary.fixedFeeBufferAmount / estimateSummary.fixedFeeCalculatedFee : ZERO;
                estimateSummary.fixedFeeCostUpliftPct = estimateSummary.fixedFeeServiceCost <> ZERO && estimateSummary.fixedFeeCostUpliftAmount <> ZERO  
                                                        ? estimateSummary.fixedFeeCostUpliftAmount / estimateSummary.fixedFeeServiceCost : ZERO;
                estimateSummary.calculatedMargin = estimateSummary.calculatedFee <> ZERO ? 
                                                    (ONE - (estimateSummary.calculatedCost/estimateSummary.calculatedFee)) : ZERO ;
                estimateSummary.serviceMargin = estimateSummary.serviceFee <> ZERO ? 
                                                (ONE - (estimateSummary.serviceCost/estimateSummary.serviceFee)) : ZERO ;
                estimateSummary.discountPct = estimateSummary.discountAmount <> ZERO && estimateSummary.serviceFee <> ZERO ?
                                             estimateSummary.discountAmount / estimateSummary.serviceFee : ZERO;
            } else {
                updateSummaryForEstimateWithoutTimlines( estimate );
            }
        }
    }
    
    private void mapTimelineInSummaryRecord(CMC_Presales_LOE__c timeline) {
        estimateSummary.totalFee += timeline.Total_Fees__c;
        estimateSummary.totalResourceHours += timeline.Total_Resource_Hours__c;
        estimateSummary.calculatedCost += timeline.Calculated_Costs__c;
        estimateSummary.numberOfWeeks += timeline.E2_Estimate_Total_Weeks__c;
        if(timeline.Mode__c == 'fixed') {
            estimateSummary.fixedFeeBufferAmount += timeline.Fixed_Fee_Buffer_Amount__c;
            estimateSummary.fixedFeeCostUpliftAmount += timeline.Fixed_Fee_Cost_Uplift__c;
            estimateSummary.fixedFeeCalculatedFee += timeline.Calculated_Fees__c;
            estimateSummary.fixedFeeServiceCost += timeline.Service_Costs__c;
        }
        estimateSummary.serviceFee += timeline.Service_Fees__c;
        estimateSummary.serviceCost += timeline.Service_Costs__c;
        estimateSummary.discountAmount += timeline.Discount_Amount__c;
        estimateSummary.passThrough += estimate.Pass_Through__c;
        estimateSummary.jaipurHours += timeline.Hours_Jaipur__c;
        estimateSummary.calculatedFee += timeline.Calculated_Fees__c;
    }
    
    private void updateSummaryForEstimateWithoutTimlines(CMC_Presales_LOE__c estimates ) {
        estimateSummary.totalFee = estimate.Total_Fees__c;
        estimateSummary.totalResourceHours = estimate.Total_Resource_Hours__c;
        estimateSummary.calculatedCost = estimate.Calculated_Costs__c;
        estimateSummary.jaipurHoursPct = estimate.Jaipur_Hours__c;
        estimateSummary.asSoldMargin = estimate.As_Sold_Margin__c;
        estimateSummary.blendedRate = estimate.Blended_Rate_Number__c;
        estimateSummary.numberOfWeeks = estimate.E2_Estimate_Total_Weeks__c;
        estimateSummary.fixedFeeBufferPct = estimate.Fixed_Fee_Buffer__c;
        estimateSummary.fixedFeeBufferAmount = estimate.Fixed_Fee_Buffer_Amount__c;
        estimateSummary.fixedFeeCostUpliftPct = estimate.Fixed_Fee_Cost_Uplift_Percent__c;
        estimateSummary.fixedFeeCostUpliftAmount = estimate.Fixed_Fee_Cost_Uplift__c;
        estimateSummary.serviceFee = estimate.Service_Fees__c;
        estimateSummary.calculatedMargin = estimate.Calculated_Margin__c;
        estimateSummary.serviceCost = estimate.Service_Costs__c;
        estimateSummary.discountPct = estimate.Discount_Percent__c;
        estimateSummary.serviceMargin = estimate.Service_Margin__c;
        estimateSummary.discountAmount = estimate.Discount_Amount__c;
        estimateSummary.passThrough = estimate.Pass_Through__c;
    }
    
    public class SummaryWrapper {
        // summary
        public decimal totalFee{get;set;}
        public decimal totalResourceHours{get;set;}
        public decimal calculatedCost{get;set;}
        public decimal jaipurHoursPct{get;set;}
        public decimal asSoldMargin{get;set;}
        public decimal blendedRate{get;set;}
        public decimal numberOfWeeks{get;set;}
        // fixed fee
        public decimal fixedFeeBufferPct{get;set;}
        public decimal fixedFeeBufferAmount{get;set;}
        public decimal fixedFeeCostUpliftPct{get;set;}
        public decimal fixedFeeCostUpliftAmount{get;set;}
        public decimal fixedFeeCalculatedFee{get;set;}
        public decimal fixedFeeServiceCost{get;set;}
        // T&M details
        public decimal serviceFee{get;set;}
        public decimal calculatedMargin{get;set;}
        public decimal serviceCost{get;set;}
        public decimal discountPct{get;set;}
        public decimal serviceMargin{get;set;}
        public decimal discountAmount{get;set;}
        public decimal passThrough{get;set;}
        public decimal jaipurHours{get;set;}
        public decimal calculatedFee{get;set;}
        
        public SummaryWrapper() {
            this.totalFee = 0;
            this.totalResourceHours = 0;
            this.calculatedCost = 0;
            this.jaipurHoursPct = 0;
            this.asSoldMargin = 0;
            this.blendedRate = 0;
            this.numberOfWeeks = 0;
            // fixed fee
            this.fixedFeeBufferPct = 0;
            this.fixedFeeBufferAmount = 0;
            this.fixedFeeCostUpliftPct = 0;
            this.fixedFeeCostUpliftAmount = 0;
            this.fixedFeeCalculatedFee = 0;
            this.fixedFeeServiceCost = 0;
            // T&M details
            this.serviceFee = 0;
            this.calculatedMargin = 0;
            this.serviceCost = 0;
            this.discountPct = 0;
            this.serviceMargin = 0;
            this.discountAmount = 0;
            this.passThrough = 0;
            this.jaipurHours = 0;
            this.calculatedFee = 0;
        }
        
    } 

}