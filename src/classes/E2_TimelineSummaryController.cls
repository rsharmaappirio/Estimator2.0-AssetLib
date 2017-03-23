/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineSummaryController
 * Description: Controller class for E2_Timeline page
 * Created Date: Feb 28th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
*  =====================================================================*/
public with sharing class E2_TimelineSummaryController {
    public Id estimateId{get;set;}
    public list<CMC_Presales_LOE__c> pricingMatrix;
    public map<Id,CMC_Presales_LOE__c> activeTimelineMap;
    public E2_System_setting__c e2SystemSetting{get;set;}
    public list<decimal> timelineDiscounts{get;set;}
    public map<id, map<string, decimal>> hourSummaryMap;
    public decimal totalHours{get;set;}
    public map<id, set<string>> timelineLevels{get;set;}
    public static final string TOTAL = 'Total';
    
    public E2_TimelineSummaryController() {
        timelineDiscounts = new list<decimal>();
        timelineLevels = new map<id, set<string>>();
        e2SystemSetting = E2_System_setting__c.getInstance();
        if(string.isNotBlank(e2SystemSetting.Timeline_Discounts__c)) {
            for(string discount : e2SystemSetting.Timeline_Discounts__c.split(E2_Constants.COMMA)) {
                timelineDiscounts.add(decimal.valueOf(discount));
            }
        }
        totalHours = 0;
    }
    
    public list<CMC_Presales_LOE__c> getPricingMatrix() {
            pricingMatrix = E2_DataUtil.getEstimateTimelinesSummary( estimateId );
        return pricingMatrix;
    }
    
    public map<Id, CMC_Presales_LOE__c> getActiveTimelineMap() {
            activeTimelineMap = new map<Id,CMC_Presales_LOE__c>();
            for(CMC_Presales_LOE__c timeline : getPricingMatrix()) {
                activeTimelineMap.put(timeline.id, timeline);
            }
        return activeTimelineMap;
    }
    
    public map<id, map<string, decimal>> getHourSummaryMap() {
            getActiveTimelineMap();
            hourSummaryMap = new  map<id, map<string, decimal>>();
            for(CMC_Estimate_Resource__c estimateResource : E2_DataUtil.getEstimateResourceForTimeline(activeTimelineMap.keySet())) {
                if(string.isNotBlank(estimateResource.E2_Estimate_Rate_Card__r.Resource_Level__c)) {
                    if(!hourSummaryMap.containsKey(estimateResource.Estimate__c)) {
                        hourSummaryMap.put(estimateResource.Estimate__c, new map<string, decimal>());
                    }
                    map<string, decimal> hoursMap = hourSummaryMap.get(estimateResource.Estimate__c);
                    if(!hoursMap.containsKey(estimateResource.E2_Estimate_Rate_Card__r.Resource_Level__c)) {
                            hoursMap.put(estimateResource.E2_Estimate_Rate_Card__r.Resource_Level__c, 0);
                    }
                    hoursMap.put(estimateResource.E2_Estimate_Rate_Card__r.Resource_Level__c, 
                                    hoursMap.get(estimateResource.E2_Estimate_Rate_Card__r.Resource_Level__c) + estimateResource.Total_Hours__c);
                    if(!hoursMap.containsKey(TOTAL)) hoursMap.put(TOTAL, 0);
                    hoursMap.put(TOTAL, hoursMap.get(TOTAL) + estimateResource.Total_Hours__c);

                }
            }
            set<string> resourcelevelTemp = new set<string>();
            for(Schema.PicklistEntry picklistValue : E2_Capacity__c.Level__c.getDescribe().getPicklistValues()){
                resourcelevelTemp.add(picklistValue.getLabel());
            }
            for(id timelineId : hourSummaryMap.keySet()) {
                timelineLevels.put(timelineId, new set<string>());
                for(string resourcelevel : resourcelevelTemp) {
                    map<string, decimal> hoursMap = hourSummaryMap.get(timelineId);
                    if(hoursMap.containsKey(resourcelevel))  timelineLevels.get(timelineId).add(resourcelevel);
                }
            }
        return hourSummaryMap;
    }
}