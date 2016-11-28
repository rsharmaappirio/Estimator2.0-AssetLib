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
    
    private static final string CLONE_PREFIX = 'Clone of ';
    private static final string SUCCESS_MESSAGE = 'success';
    private static final string FAILED_PREFIX = 'Failed: ';
    private static final string ERROR_MESSAGE = Label.E2_Estimate_Cloning_Error_Message;
    //'Opps something went wrong with the estimate cloning.\nPlease reach out to helpdesk@appirio.com to log this issue.';
    private static final string INVALID_ESTIMATE_ID_MESSAGE = 'Failed: Invalid estimateId';
// Start : Estimate clone functionality
    // clone Estimate 
    public static string cloneEstimate(string estimateId) {
        if(!string.isBlank(estimateId)) {
            List<CMC_Presales_LOE__c> estimatesToClone = E2_Clone_DataUtil_WS.getEstimateFullDetailById(estimateId);
            CMC_Presales_LOE__c estimateToClone = estimatesToClone.get(0);
            CMC_Presales_LOE__c clonedEstimate = estimateToClone.clone(false, true, false, false);
            clonedEstimate.Name = CLONE_PREFIX + estimateToClone.Name;
            try {
                insert clonedEstimate;
                return clonedEstimate.id;
            } catch(Exception ex) {
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
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
                if(!scope.Efforts__r.isEmpty() || !scope.E2_Recommended_Assets__r.isEmpty()
                    || !scope.Questions__r.isEmpty()){
                    hasChildrenScope.put(scope.id, scope);
                }                                                
            }
            if(!scopeList.isEmpty()) {
                try {
                    insert scopeList;   
                    // TODO : RS check with DML governor limit later.
                    // clone scope child efforts, assets, question and answers
                    E2_Estimator_WSManager.cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
                    // reparent new scopes upto five level in hierachy.
                    E2_Estimator_WSManager.reParentClonedScopes(clonedSourceMap);
                } catch (Exception ex) {
                    deleteEstimate(newEstimateId);
                    return FAILED_PREFIX + ERROR_MESSAGE;
                }   
            }
        }
        return SUCCESS_MESSAGE;
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
                    return FAILED_PREFIX + ERROR_MESSAGE;
         }
        return SUCCESS_MESSAGE;
    }
    
    // clone estimate milestones
    public static string cloneEstimateMilestone(string estimateId, string newEstimateId) {
        map<id, E2_Estimate_Week_Milestone__c> clonedMilestoneWeeks = new map<id, E2_Estimate_Week_Milestone__c>();
        map<id, E2_Estimate_Milestone__c> clonedEstimateMilestones = new map<id, E2_Estimate_Milestone__c>();
        list<E2_Clone_Estimate_WSManager.TimelineWrapper> mappingList = new list<E2_Clone_Estimate_WSManager.TimelineWrapper>();
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
             // generate weeks mapping
                for(id oldWeekId : clonedMilestoneWeeks.keySet()) {
                    E2_Clone_Estimate_WSManager.TimelineWrapper mapping = new E2_Clone_Estimate_WSManager.TimelineWrapper();
                    mapping.key = oldWeekId;
                    mapping.value = clonedMilestoneWeeks.get(oldWeekId).id;
                    mapping.isWeek = true;
                    mappingList.add(mapping);
                }
                // generate milestone mapping
                for(id oldResourceId : clonedEstimateMilestones.keySet()) {
                    E2_Clone_Estimate_WSManager.TimelineWrapper mapping = new E2_Clone_Estimate_WSManager.TimelineWrapper();
                    mapping.key = oldResourceId;
                    mapping.value = clonedEstimateMilestones.get(oldResourceId).id;
                    mapping.isWeek = false;
                    mappingList.add(mapping);
                }
                return JSON.serialize(mappingList);
           }
        } catch(Exception ex) {
            deleteEstimate(newEstimateId);
            return FAILED_PREFIX + ERROR_MESSAGE;
        }
        return SUCCESS_MESSAGE;
    }
    
    // clone estimate milestone weeks
    public static string cloneMilestoneWeeks(string milestoneWeekJSON, string newEstimateId) {
        try {
            list<E2_Clone_Estimate_WSManager.TimelineWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.TimelineWrapper>)JSON.deserialize(milestoneWeekJSON, list<E2_Clone_Estimate_WSManager.TimelineWrapper>.class);
            map<string, string> clonedMilestoneWeeks = new map<string, string>();
            map<string, string> clonedEstimateMilestones = new map<string, string>();
            list<E2_Estimate_Milestone_Week__c> clonedEstimateMilestoneWeekMapping = new list<E2_Estimate_Milestone_Week__c>();
            for(E2_Clone_Estimate_WSManager.TimelineWrapper mapping : mappingList) {
                if(mapping.isWeek) {
                    clonedMilestoneWeeks.put(mapping.key, mapping.value);
                } else {
                    clonedEstimateMilestones.put(mapping.key, mapping.value);
                }
            }
            // clone estimate resource weeks
             for(E2_Estimate_Milestone_Week__c milestoneWeek : E2_Clone_DataUtil_WS.getMilestonesWeeks( clonedEstimateMilestones.keySet(), clonedMilestoneWeeks.keySet())) {
                E2_Estimate_Milestone_Week__c clonedmilestoneWeek = milestoneWeek.clone(false, true, false, false);
                clonedmilestoneWeek.Estimate_Milestone__c = clonedEstimateMilestones.get(milestoneWeek.Estimate_Milestone__c);
                clonedmilestoneWeek.Estimate_Week_Milestone__c = clonedMilestoneWeeks.get(milestoneWeek.Estimate_Week_Milestone__c);
                clonedEstimateMilestoneWeekMapping.add(clonedmilestoneWeek);
             }
             insert clonedEstimateMilestoneWeekMapping;
        } catch(Exception ex) {
            deleteEstimate(newEstimateId);
            return FAILED_PREFIX + ERROR_MESSAGE;
        }
        return SUCCESS_MESSAGE;
    }
    
    // clone timeline with rate card
    public static string cloneEstimateTimeline(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            try {
                map<Id, E2_Estimate_Rate_Card__c> clonedRateCards = cloneRateCards( estimateId, newEstimateId);
                if(!clonedRateCards.isEmpty()) {
                    list<E2_Clone_Estimate_WSManager.TimelineWrapper> mappingList = cloneEstimateTimeline( estimateId, newEstimateId, clonedRateCards);
                    if(!mappingList.isEmpty()) return JSON.serialize(mappingList);
                }
            } catch (Exception ex) {
                deleteEstimate(newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
        }
        return SUCCESS_MESSAGE;
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
    private static list<E2_Clone_Estimate_WSManager.TimelineWrapper> cloneEstimateTimeline(string estimateId, string newEstimateId, 
                                                                                map<Id, E2_Estimate_Rate_Card__c> clonedRateCards) {
        map<id, CMC_Estimate_Week__c> clonedEstimateWeeks = new map<id, CMC_Estimate_Week__c>();
        map<id, CMC_Estimate_Resource__c> clonedEstimateResources = new map<id, CMC_Estimate_Resource__c>();
        list<E2_Clone_Estimate_WSManager.TimelineWrapper> mappingList = new list<E2_Clone_Estimate_WSManager.TimelineWrapper>();
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
                // generate estimate weeks mapping
                for(id oldWeekId : clonedEstimateWeeks.keySet()) {
                    E2_Clone_Estimate_WSManager.TimelineWrapper mapping = new E2_Clone_Estimate_WSManager.TimelineWrapper();
                    mapping.key = oldWeekId;
                    mapping.value = clonedEstimateWeeks.get(oldWeekId).id;
                    mapping.isWeek = true;
                    mappingList.add(mapping);
                }
                // generate estimate resource mapping
                for(id oldResourceId : clonedEstimateResources.keySet()) {
                    E2_Clone_Estimate_WSManager.TimelineWrapper mapping = new E2_Clone_Estimate_WSManager.TimelineWrapper();
                    mapping.key = oldResourceId;
                    mapping.value = clonedEstimateResources.get(oldResourceId).id;
                    mapping.isWeek = false;
                    mappingList.add(mapping);
                }
                
            }
        }
        return mappingList;
    }
    
    // clone estimate resource weeks
    public static string cloneResourceWeeks(string resourceWeekJSON, string newEstimateId) {
        try {
            list<E2_Clone_Estimate_WSManager.TimelineWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.TimelineWrapper>)JSON.deserialize(resourceWeekJSON, list<E2_Clone_Estimate_WSManager.TimelineWrapper>.class);
            map<string, string> clonedEstimateWeeks = new map<string, string>();
            map<string, string> clonedEstimateResources = new map<string, string>();
            list<CMC_Estimate_Resource_Week__c> clonedEstimateResourceWeekMapping = new list<CMC_Estimate_Resource_Week__c>();
            for(E2_Clone_Estimate_WSManager.TimelineWrapper mapping : mappingList) {
                if(mapping.isWeek) {
                    clonedEstimateWeeks.put(mapping.key, mapping.value);
                } else {
                    clonedEstimateResources.put(mapping.key, mapping.value);
                }
            }
            // clone estimate resource weeks
            for(CMC_Estimate_Resource_Week__c estimateResourceWeek : E2_Clone_DataUtil_WS.getResourceWeeks( clonedEstimateResources.keySet(), clonedEstimateWeeks.keySet())) {
                CMC_Estimate_Resource_Week__c clonedEstimateResourceWeek = estimateResourceWeek.clone(false, true, false, false);
                clonedEstimateResourceWeek.Estimate_Resource__c = clonedEstimateResources.get(estimateResourceWeek.Estimate_Resource__c);
                clonedEstimateResourceWeek.Estimate_Week__c = clonedEstimateWeeks.get(estimateResourceWeek.Estimate_Week__c);
                clonedEstimateResourceWeekMapping.add(clonedEstimateResourceWeek);
            }
            insert clonedEstimateResourceWeekMapping;
        } catch(Exception ex) {
            deleteEstimate(newEstimateId);
            return FAILED_PREFIX + ERROR_MESSAGE;
        }
        return SUCCESS_MESSAGE;
    }
    
    // delete estimate 
    public static string deleteEstimate(string estimateId) {
        try {
            CMC_Presales_LOE__c estimateDelete = new CMC_Presales_LOE__c(id = estimateId);
            delete estimateDelete;
        } catch(Exception ex) {
            return FAILED_PREFIX + ERROR_MESSAGE;
        }
        return SUCCESS_MESSAGE;
    }
    
    //wrapper class for resource, week, milestone mapping 
    public class TimelineWrapper {
    	public string key;
    	public string value;
    	public boolean isWeek;
    }
    // End : Estimate clone functionality
}