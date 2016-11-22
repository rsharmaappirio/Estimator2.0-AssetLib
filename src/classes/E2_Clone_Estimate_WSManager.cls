/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_Estimate_WSManager
 * Description: S-454105 : Modal class to E2_Clone_Estimate_WS web service 
 * Created Date: Nov 22, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
public class E2_Clone_Estimate_WSManager {

// Start : Estimate clone functionality
    // clone Estimate 
    public static string cloneEstimate(string estimateId) {
        if(!string.isBlank(estimateId)) {
            List<CMC_Presales_LOE__c> estimatesToClone = E2_Clone_DataUtil_WS.getEstimateFullDetailById(estimateId);
            CMC_Presales_LOE__c estimateToClone = estimatesToClone.get(0);
            CMC_Presales_LOE__c clonedEstimate = estimateToClone.clone(false, true, false, false);
            clonedEstimate.Name = 'Cloned ' + estimateToClone.Name;
            try {
                insert clonedEstimate;
                return clonedEstimate.id;
            } catch(Exception ex) {
                return 'Failed: ' + ex.getMessage();
            }
        }
        return 'Failed: Invalid estimateId';
    } 
    
    // clone Scopes
    public static string cloneEstimateScopes(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
            Map<string, E2_Scope__c> hasChildrenScope = new Map<string, E2_Scope__c>();
            Map<string, E2_Scope__c> clonedSourceMap = new Map<string, E2_Scope__c>();

            for(E2_Scope__c scope : E2_Clone_DataUtil_WS.getFullScopesDetailsByEstimateId(estimateId)){
                E2_Scope__c cloneScope = scope.clone(false, true, false, false);
                cloneScope.Source_Scope__c = scope.id;
                cloneScope.Presales_LOE__c = newEstimateId;
                scopeList.add(cloneScope);
                clonedSourceMap.put(scope.id, cloneScope);
                if(scope.Efforts__r.size() > 0 || scope.E2_Recommended_Assets__r.size() > 0
                    || scope.Questions__r.size() > 0){
                    hasChildrenScope.put(scope.id, scope);
                }                                                
            }
            if(!scopeList.isEmpty()) {
                try {
                    insert scopeList;   
                    E2_Estimator_WSManager.cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
                    E2_Estimator_WSManager.reParentClonedScopes(clonedSourceMap);
                } catch (Exception ex) {
                    deleteEstimate(newEstimateId);
                    return 'Failed: ' + ex.getMessage();
                }   
            }
        }
        return 'success';
    }
    
    // clone Capacity
    public static string cloneEstimateCapacity(string estimateId, string newEstimateId) {
         try {
                if(!string.isBlank(estimateId)) {
                    List<E2_Capacity__c> capacityList = new List<E2_Capacity__c>();
                    for(E2_Capacity__c capacity : E2_Clone_DataUtil_WS.getCapacityListByEstimateId(estimateId)){
                        E2_Capacity__c clonedCapacity = capacity.clone(false, true, false, false);
                        clonedCapacity.Estimator__c = newEstimateId;
                        capacityList.add(clonedCapacity);
                    }
                    if(!capacityList.isEmpty()) {
                            insert capacityList;
                    }
                }
         } catch (Exception ex) {
                    deleteEstimate(newEstimateId);
                    return 'Failed: ' + ex.getMessage();
         }
        return 'success';
    }
    
    // clone estimate milestones
    public static string cloneEstimateMilestone(string estimateId, string newEstimateId) {
        map<id, E2_Estimate_Week_Milestone__c> clonedMilestoneWeeks = new map<id, E2_Estimate_Week_Milestone__c>();
        map<id, E2_Estimate_Milestone__c> clonedEstimateMilestones = new map<id, E2_Estimate_Milestone__c>();
        list<E2_Estimate_Milestone_Week__c> clonedEstimateMilestoneWeekMapping = new list<E2_Estimate_Milestone_Week__c>();
        try {
            // clone estimate weeks
            for(E2_Estimate_Week_Milestone__c estimateWeek : E2_Clone_DataUtil_WS.getEstimateWeekMilestonesByEstimateId( estimateId )) {
                E2_Estimate_Week_Milestone__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
                clonedEstimateWeek.Estimate__c = newEstimateId;
                clonedMilestoneWeeks.put(estimateWeek.Id, clonedEstimateWeek);
            }
            // clone estimate milestones
            for(E2_Estimate_Milestone__c estimateMilestone : E2_Clone_DataUtil_WS.getEstimateMilestonesByEstimateId( estimateId )) {
                E2_Estimate_Milestone__c clonedEstimateMilestone = estimateMilestone.clone(false, true, false, false);
                clonedEstimateMilestone.Estimate__c = newEstimateId;
                clonedEstimateMilestones.put(estimateMilestone.Id, clonedEstimateMilestone);
            }
        
        
           if(!clonedMilestoneWeeks.isEmpty()) {
            insert clonedMilestoneWeeks.values();
           }
           if(!clonedEstimateMilestones.isEmpty()) {
            insert clonedEstimateMilestones.values();
           }
           if(!clonedMilestoneWeeks.isEmpty() && !clonedEstimateMilestones.isEmpty()) {
             // clone estimate resource weeks
             for(E2_Estimate_Milestone_Week__c milestoneWeek : E2_Clone_DataUtil_WS.getMilestonesWeeks( clonedEstimateMilestones.keySet(), clonedMilestoneWeeks.keySet())) {
                E2_Estimate_Milestone_Week__c clonedmilestoneWeek = milestoneWeek.clone(false, true, false, false);
                clonedmilestoneWeek.Estimate_Milestone__c = clonedEstimateMilestones.get(milestoneWeek.Estimate_Milestone__c).id;
                clonedmilestoneWeek.Estimate_Week_Milestone__c = clonedMilestoneWeeks.get(milestoneWeek.Estimate_Week_Milestone__c).id;
                clonedEstimateMilestoneWeekMapping.add(clonedmilestoneWeek);
             }
             insert clonedEstimateMilestoneWeekMapping;
           }
        } catch(Exception ex) {
            deleteEstimate(newEstimateId);
            return 'Failed: ' + ex.getMessage();
        }
        return 'success';
    }
    
    // clone timeline with rate card
    public static string cloneEstimateTimeline(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            try {
                map<Id, E2_Estimate_Rate_Card__c> clonedRateCards = cloneRateCards( estimateId, newEstimateId);
                if(!clonedRateCards.isEmpty()) {
                    cloneEstimateTimeline( estimateId, newEstimateId, clonedRateCards);
                }
            } catch (Exception ex) {
                deleteEstimate(newEstimateId);
                return 'Failed: ' + ex.getMessage();
            }
        }
        return 'success';
    }
    
    // clone etimate rate cards
    private static map<id, E2_Estimate_Rate_Card__c> cloneRateCards(string estimateId, string newEstimateId) {
        map<id, E2_Estimate_Rate_Card__c> ratecardsToClone = new map<id, E2_Estimate_Rate_Card__c>();
        for(E2_Estimate_Rate_Card__c estimateRateCards : E2_Clone_DataUtil_WS.getEstimateRateCardsByEstimateId( estimateId )) {
            E2_Estimate_Rate_Card__c clonedRateCard = estimateRateCards.clone(false, true, false, false);
            clonedRateCard.Estimate__c = newEstimateId;
            ratecardsToClone.put(estimateRateCards.Id, clonedRateCard);
        }
        if(!ratecardsToClone.isEmpty()) {
            insert ratecardsToClone.values();
        }
        return ratecardsToClone;
    }
    
    // clone Timeline
    private static void cloneEstimateTimeline(string estimateId, string newEstimateId, map<Id, E2_Estimate_Rate_Card__c> clonedRateCards) {
        map<id, CMC_Estimate_Week__c> clonedEstimateWeeks = new map<id, CMC_Estimate_Week__c>();
        map<id, CMC_Estimate_Resource__c> clonedEstimateResources = new map<id, CMC_Estimate_Resource__c>();
        list<CMC_Estimate_Resource_Week__c> clonedEstimateResourceWeekMapping = new list<CMC_Estimate_Resource_Week__c>();
        // clone estimate weeks
        for(CMC_Estimate_Week__c estimateWeek : E2_Clone_DataUtil_WS.getEstimateWeekMByEstimateId( estimateId )) {
            CMC_Estimate_Week__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
            clonedEstimateWeek.Estimate__c = newEstimateId;
            clonedEstimateWeeks.put(estimateWeek.Id, clonedEstimateWeek);
        }
        if(!clonedEstimateWeeks.isEmpty()) {
            // clone estimate resources
            for(CMC_Estimate_Resource__c estimateRecource : E2_Clone_DataUtil_WS.getResourceRequestByEstimateId( estimateId )) {
                CMC_Estimate_Resource__c clonedEstimateRecource = estimateRecource.clone(false, true, false, false);
                clonedEstimateRecource.Estimate__c = newEstimateId;
                clonedEstimateRecource.E2_Estimate_Rate_Card__c = estimateRecource.E2_Estimate_Rate_Card__c != NULL && 
                                                                    clonedRateCards.containsKey(estimateRecource.E2_Estimate_Rate_Card__c) ? 
                                                                    clonedRateCards.get(estimateRecource.E2_Estimate_Rate_Card__c).id : NULL;
                clonedEstimateResources.put(estimateRecource.Id, clonedEstimateRecource);
            }
            
            // insert Resource timeline 
            insert clonedEstimateWeeks.values();
            if(!clonedEstimateResources.isEmpty()) {
                insert clonedEstimateResources.values();
                // clone estimate resource weeks
                for(CMC_Estimate_Resource_Week__c estimateResourceWeek : E2_Clone_DataUtil_WS.getResourceWeeks( clonedEstimateResources.keySet(), clonedEstimateWeeks.keySet())) {
                    CMC_Estimate_Resource_Week__c clonedEstimateResourceWeek = estimateResourceWeek.clone(false, true, false, false);
                    clonedEstimateResourceWeek.Estimate_Resource__c = clonedEstimateResources.get(estimateResourceWeek.Estimate_Resource__c).id;
                    clonedEstimateResourceWeek.Estimate_Week__c = clonedEstimateWeeks.get(estimateResourceWeek.Estimate_Week__c).id;
                    clonedEstimateResourceWeekMapping.add(clonedEstimateResourceWeek);
                }
                insert clonedEstimateResourceWeekMapping;
            }
        }
    }
    
    // delete estimate 
    public static string deleteEstimate(string estimateId) {
        try {
            CMC_Presales_LOE__c estimateDelete = new CMC_Presales_LOE__c(id = estimateId);
            delete estimateDelete;
        } catch(Exception ex) {
            return 'Failed: ' + ex.getMessage();
        }
        return 'success';
    }
    // End : Estimate clone functionality
}