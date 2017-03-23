/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_Estimate_WSManager
 * Description: S-454105 : Modal class to E2_Clone_Estimate_WS web service 
 * Created Date: Nov 22, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
public without sharing class E2_Clone_Estimate_WSManager {
    
    private static final string CLONE_PREFIX = 'Clone of ';
    private static final string CHILD_PREFIX = 'Only for timeline';
    private static final string SUCCESS_MESSAGE = 'success';
    private static final string FAILED_PREFIX = 'Failed: ';
    private static final string ERROR_MESSAGE = Label.E2_Estimate_Cloning_Error_Message;
    //'Opps something went wrong with the estimate cloning.\nPlease reach out to helpdesk@appirio.com to log this issue.';
    private static final string INVALID_ESTIMATE_ID_MESSAGE = 'Failed: Invalid estimateId';
    private static final string INVALID_TIMELINE_MESSAGE = 'Failed: Invalid timeline data';
// Start : Estimate clone functionality
    // clone Estimate 
    public static string cloneEstimate(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = (E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(estimateWrapperJSON, E2_Clone_Estimate_WSManager.EstimateWrapper.class);
            
            List<CMC_Presales_LOE__c> estimatesToClone = E2_Clone_DataUtil_WS.getEstimateFullDetailById(estimateWrapper.cloneFrom);
            CMC_Presales_LOE__c estimateToClone = estimatesToClone.get(0);
            CMC_Presales_LOE__c clonedEstimate = estimateToClone.clone(false, true, false, false);
            clonedEstimate.Name = CLONE_PREFIX + estimateToClone.Name;
            clonedEstimate.Name = clonedEstimate.Name.length() > 80 ? clonedEstimate.Name.substring(0, 79) : clonedEstimate.Name;
            try {
                insert clonedEstimate;
                estimateWrapper.newEstimateId = clonedEstimate.id;
                estimateWrapper.estimateIsActive = estimateToClone.E2_Is_Active__c;
                return JSON.serialize(estimateWrapper);
            } catch(Exception ex) {
                return FAILED_PREFIX + ex.getMessage();//ERROR_MESSAGE;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    } 
    
    // clone Scopes
    public static string cloneEstimateScopes(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = (E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(estimateWrapperJSON, E2_Clone_Estimate_WSManager.EstimateWrapper.class);
            List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
            Map<string, E2_Scope__c> hasChildrenScope = new Map<string, E2_Scope__c>();
            Map<string, E2_Scope__c> clonedSourceMap = new Map<string, E2_Scope__c>();
            list<E2_Clone_Estimate_WSManager.ScopeMapping> mappingList = new list<E2_Clone_Estimate_WSManager.ScopeMapping>();

            for(E2_Scope__c scope : E2_Clone_DataUtil_WS.getFullScopesDetailsByEstimateId(estimateWrapper.cloneFrom)){
                E2_Scope__c cloneScope = scope.clone(false, true, false, false);
                cloneScope.Source_Scope__c = scope.id;
                cloneScope.Presales_LOE__c = estimateWrapper.newEstimateId;
                cloneScope.Parent_Scope__c = null;
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
                    // clone scope child efforts, assets, question and answers
                    E2_Estimator_WSManager.cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
                    for(id clonedId : clonedSourceMap.KeySet()) {
                        E2_Clone_Estimate_WSManager.ScopeMapping scopeMapping = new E2_Clone_Estimate_WSManager.ScopeMapping();
                        scopeMapping.key = clonedId;
                        scopeMapping.value = clonedSourceMap.get(clonedId).Id;
                        scopeMapping.cloneFrom = estimateWrapper.cloneFrom;
                        scopeMapping.newEstimateId = estimateWrapper.newEstimateId;
                        scopeMapping.estimateIsActive = estimateWrapper.estimateIsActive;
                        scopeMapping.partialClone = estimateWrapper.partialClone;
                        mappingList.add(scopeMapping);
                    }
                    return 'ScopeMapping' + JSON.serialize(mappingList);
                } catch (Exception ex) {
                    deleteEstimate(estimateWrapper.newEstimateId);
                    return FAILED_PREFIX + ERROR_MESSAGE;
                }   
            } else {
                return estimateWrapperJSON;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    public static string reParentClonedScopes(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            list<E2_Clone_Estimate_WSManager.ScopeMapping> mappingList = (list<E2_Clone_Estimate_WSManager.ScopeMapping>)JSON.deserialize(estimateWrapperJSON, list<E2_Clone_Estimate_WSManager.ScopeMapping>.class);
            try {
                // RS : Re-parent all cloned child scopes in new estimate/scope group hierarchy 
                list<E2_Scope__c> scopesToUpdate = new list<E2_Scope__c>();
                map<string, string> clonedSourceMap = new map<string, string>();
                for(E2_Clone_Estimate_WSManager.ScopeMapping scopemap : mappingList) {
                    clonedSourceMap.put(scopemap.key, scopemap.value);
                }
                for(E2_Scope__c scope : E2_dataUtil_WS.getParentScopeIds(clonedSourceMap.KeySet())) {
                 	string clonedScope = clonedSourceMap.get(scope.Id);
                    string parentScope = null;
                    if(scope.Parent_Scope__c != null && clonedSourceMap.containsKey(scope.Parent_Scope__c)) {
                    	parentScope = scope.Parent_Scope__c;
                    }
                    if(parentScope != null && clonedScope != null) {            		
                    	E2_Scope__c scopeToUpdate = new E2_Scope__c(Id = clonedScope, Parent_Scope__c = clonedSourceMap.get(parentScope));
                    	scopesToUpdate.add(scopeToUpdate);
                    }
        		}
                if(!scopesToUpdate.isEmpty()) {
                	update scopesToUpdate;
                }
                E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                estimateWrapper.cloneFrom = mappingList.get(0).cloneFrom;
                estimateWrapper.newEstimateId = mappingList.get(0).newEstimateId;
                estimateWrapper.estimateIsActive = mappingList.get(0).estimateIsActive;
                estimateWrapper.partialClone = mappingList.get(0).partialClone;
                return JSON.serialize(estimateWrapper);
            } catch (Exception ex) {
                deleteEstimate(mappingList.get(0).newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }  
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    // clone Capacity
    public static string cloneEstimateCapacity(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = (E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(estimateWrapperJSON, E2_Clone_Estimate_WSManager.EstimateWrapper.class);
            List<E2_Capacity__c> capacityList = new List<E2_Capacity__c>();
            try{
                for(E2_Capacity__c capacity : E2_Clone_DataUtil_WS.getCapacityListByEstimateId(estimateWrapper.cloneFrom)){
                    E2_Capacity__c clonedCapacity = capacity.clone(false, true, false, false);
                    clonedCapacity.Estimator__c = estimateWrapper.newEstimateId;
                    capacityList.add(clonedCapacity);
                }
                if(!capacityList.isEmpty()) {
                    insert capacityList;
                }
                return estimateWrapperJSON;
            } catch (Exception ex) {
                deleteEstimate(estimateWrapper.newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    // clone estimate milestones
    public static string cloneEstimateMilestone(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = (E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(estimateWrapperJSON, E2_Clone_Estimate_WSManager.EstimateWrapper.class);
            map<E2_Estimate_Week_Milestone__c, E2_Estimate_Week_Milestone__c> clonedMilestoneWeeks = new map<E2_Estimate_Week_Milestone__c, E2_Estimate_Week_Milestone__c>();
            map<E2_Estimate_Milestone__c, E2_Estimate_Milestone__c> clonedEstimateMilestones = new map<E2_Estimate_Milestone__c, E2_Estimate_Milestone__c>();
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = new list<E2_Clone_Estimate_WSManager.EstimateWrapper>();
            try {
                // clone estimate weeks
                for(E2_Estimate_Week_Milestone__c estimateWeek : E2_Clone_DataUtil_WS.getEstimateWeekMilestonesByEstimateId( estimateWrapper.cloneFrom )) {
                    E2_Estimate_Week_Milestone__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
                    clonedEstimateWeek.Estimate__c = estimateWrapper.newEstimateId;
                    clonedMilestoneWeeks.put(estimateWeek, clonedEstimateWeek);
                }
                // clone estimate milestones
                for(E2_Estimate_Milestone__c estimateMilestone : E2_Clone_DataUtil_WS.getEstimateMilestonesByEstimateId( estimateWrapper.cloneFrom )) {
                    E2_Estimate_Milestone__c clonedEstimateMilestone = estimateMilestone.clone(false, true, false, false);
                    clonedEstimateMilestone.Estimate__c = estimateWrapper.newEstimateId;
                    clonedEstimateMilestones.put(estimateMilestone, clonedEstimateMilestone);
                }
            
            
               if(!clonedMilestoneWeeks.isEmpty()) {
                insert clonedMilestoneWeeks.values();
               }
               if(!clonedEstimateMilestones.isEmpty()) {
                insert clonedEstimateMilestones.values();
               }
               if(!clonedMilestoneWeeks.isEmpty() && !clonedEstimateMilestones.isEmpty()) {
                 // generate weeks mapping
                    for(E2_Estimate_Week_Milestone__c oldWeek : clonedMilestoneWeeks.keySet()) {
                        E2_Clone_Estimate_WSManager.EstimateWrapper mapping = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                        mapping.key = oldWeek.Id;
                        mapping.value = clonedMilestoneWeeks.get(oldWeek).id;
                        mapping.isWeek = true;
                        mapping.cloneFrom = oldWeek.Estimate__c;
                	    mapping.newEstimateId = clonedMilestoneWeeks.get(oldWeek).Estimate__c;
                	    mapping.estimateIsActive = estimateWrapper.estimateIsActive;
                        mapping.partialClone = estimateWrapper.partialClone;
                        mappingList.add(mapping);
                    }
                    // generate milestone mapping
                    for(E2_Estimate_Milestone__c oldResource : clonedEstimateMilestones.keySet()) {
                        E2_Clone_Estimate_WSManager.EstimateWrapper mapping = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                        mapping.key = oldResource.Id;
                        mapping.value = clonedEstimateMilestones.get(oldResource).id;
                        mapping.isWeek = false;
                        mapping.cloneFrom = oldResource.Estimate__c;
                	    mapping.newEstimateId = clonedEstimateMilestones.get(oldResource).Estimate__c;
                	    mapping.estimateIsActive = estimateWrapper.estimateIsActive;
                        mapping.partialClone = estimateWrapper.partialClone;
                        mappingList.add(mapping);
                    }
                    return 'milestonemapping' + JSON.serialize(mappingList);
               } else {
                   return estimateWrapperJSON;
               }
            }  catch(Exception ex) {
                deleteEstimate(estimateWrapper.newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    // clone estimate milestone weeks
    public static string cloneMilestoneWeeks(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(estimateWrapperJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            try {
                map<string, string> clonedMilestoneWeeks = new map<string, string>();
                map<string, string> clonedEstimateMilestones = new map<string, string>();
                list<E2_Estimate_Milestone_Week__c> clonedEstimateMilestoneWeekMapping = new list<E2_Estimate_Milestone_Week__c>();
                for(E2_Clone_Estimate_WSManager.EstimateWrapper mapping : mappingList) {
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
                 if(!clonedEstimateMilestoneWeekMapping.isEmpty()){
                   insert clonedEstimateMilestoneWeekMapping;
                 }   
                 E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                 estimateWrapper.cloneFrom = mappingList.get(0).cloneFrom;
                 estimateWrapper.newEstimateId = mappingList.get(0).newEstimateId;
                 estimateWrapper.estimateIsActive = mappingList.get(0).estimateIsActive;
                 estimateWrapper.partialClone = mappingList.get(0).partialClone;
                 return JSON.serialize(estimateWrapper);
            } catch(Exception ex) {
                deleteEstimate(mappingList.get(0).newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    //clone all/active timelines on estimate with rate cards
    public static string cloneEstimateTimeline(string estimateWrapperJSON) {
        if(!string.isBlank(estimateWrapperJSON)) {
            E2_Clone_Estimate_WSManager.EstimateWrapper timelineWrapper = (E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(estimateWrapperJSON, E2_Clone_Estimate_WSManager.EstimateWrapper.class);
            try {
                map<string, CMC_Presales_LOE__c> timelineToClone = new map<string, CMC_Presales_LOE__c>();
                if(timelineWrapper.partialClone) {
                    getActiveEstimatesTimelines( timelineWrapper, timelineToClone);
                } else {
                    getAllEstimatesTimelines( timelineWrapper, timelineToClone);
                }
                if(!timelineToClone.isEmpty()) {
                    upsert timelineToClone.values();
                    // clone all estimates rate cards for cloned timeline versions
                    map<Id, E2_Estimate_Rate_Card__c> clonedRateCards = cloneTimelineRateCards( timelineToClone );
                    if(!clonedRateCards.isEmpty()) {
                        list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = cloneTimelineResourcesAndWeeks( timelineToClone, 
                                                                                                                       clonedRateCards );
                       if(!mappingList.isEmpty()) return JSON.serialize(mappingList);
                    }
                }
                return SUCCESS_MESSAGE;
            }  catch (Exception ex) {
                deleteEstimate(timelineWrapper.newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE + ex;
            }
        }
        return INVALID_ESTIMATE_ID_MESSAGE;
    }
    
    // clone all timeline versions in case of of full clone
    private static void getAllEstimatesTimelines(E2_Clone_Estimate_WSManager.EstimateWrapper timelineWrapper,
                                         map<string, CMC_Presales_LOE__c> timelineToClone) {
        for(CMC_Presales_LOE__c timeline : E2_Clone_DataUtil_WS.getAllTimelineVersions( timelineWrapper.cloneFrom )) {
            CMC_Presales_LOE__c newTimeline;
            if(timeline.Id == timelineWrapper.cloneFrom) {
                newTimeline = new CMC_Presales_LOE__c(Id = timelineWrapper.newEstimateId,
                                                      E2_Timeline_Name__c = timeline.E2_Timeline_Name__c,
                                                      Discount_Percent__c = timeline.Discount_Percent__c,
                                                      Discount__c = timeline.Discount__c,
                                                      Fixed_Fee_Cost_Uplift_Percent__c = timeline.Fixed_Fee_Cost_Uplift_Percent__c,
                                                      Fixed_Fee_Buffer__c = timeline.Fixed_Fee_Buffer__c);
            } else {
                newTimeline = timeline.clone(false, true, false, false);
                newTimeline.E2_Parent_Estimate__c = timelineWrapper.newEstimateId;
            }
            timelineToClone.put(timeline.Id, newTimeline);
        }
    }
    
    // clone active timeline versions in case of of full clone
    private static void getActiveEstimatesTimelines(E2_Clone_Estimate_WSManager.EstimateWrapper timelineWrapper,
                                            map<string, CMC_Presales_LOE__c> timelineToClone) {
        list<CMC_Presales_LOE__c> activeTimelines = E2_Clone_DataUtil_WS.getActiveTimelineVersions( timelineWrapper.cloneFrom );
        if(!activeTimelines.isEmpty()) {
            // Get Ist active timeline from list and map it as primary timeline of 
            // new Estimate
            CMC_Presales_LOE__c istActiveTimeline = activeTimelines.get(0);
            CMC_Presales_LOE__c newTimeline = new CMC_Presales_LOE__c(Id = timelineWrapper.newEstimateId,
                                                                    E2_Timeline_Name__c = istActiveTimeline.E2_Timeline_Name__c,
                                                                    Discount_Percent__c = istActiveTimeline.Discount_Percent__c,
                                                                    Discount__c = istActiveTimeline.Discount__c,
                                                                    Fixed_Fee_Cost_Uplift_Percent__c = istActiveTimeline.Fixed_Fee_Cost_Uplift_Percent__c,
                                                                    Fixed_Fee_Buffer__c = istActiveTimeline.Fixed_Fee_Buffer__c,
                                                                    E2_Is_Active__c = istActiveTimeline.E2_Is_Active__c,
                                                                    E2_SA__c = istActiveTimeline.E2_SA__c);
             timelineToClone.put(istActiveTimeline.Id, newTimeline); 
             for(CMC_Presales_LOE__c timeline : activeTimelines) {
                if(timeline.Id != istActiveTimeline.Id) {
                    CMC_Presales_LOE__c newTimelineVersion = timeline.clone(false, true, false, false);
                    newTimelineVersion.E2_Parent_Estimate__c = timelineWrapper.newEstimateId;
                    timelineToClone.put(timeline.Id, newTimelineVersion);
                }
            }
        }
    }
    
    // clone timlines rate cards
    private static map<id, E2_Estimate_Rate_Card__c> cloneTimelineRateCards(map<string, CMC_Presales_LOE__c> timelineToClone) {
        map<id, E2_Estimate_Rate_Card__c> ratecardsToClone = new map<id, E2_Estimate_Rate_Card__c>();
        for(E2_Estimate_Rate_Card__c estimateRateCards : E2_Clone_DataUtil_WS.getEstimateRateCardsByEstimateId( timelineToClone.keySet() )) {
            E2_Estimate_Rate_Card__c clonedRateCard = estimateRateCards.clone(false, true, false, false);
            clonedRateCard.Estimate__c = timelineToClone.get(estimateRateCards.Estimate__c).Id;
            ratecardsToClone.put(estimateRateCards.Id, clonedRateCard);
        }
        if(!ratecardsToClone.isEmpty()) {
            insert ratecardsToClone.values();
        }
        return ratecardsToClone;
    }
    
    // clone Timeline Resources and Weeks
    private static list<E2_Clone_Estimate_WSManager.EstimateWrapper> cloneTimelineResourcesAndWeeks(map<string, CMC_Presales_LOE__c> timelineToClone, 
                                                                                map<Id, E2_Estimate_Rate_Card__c> clonedRateCards) {
        map<CMC_Estimate_Week__c, CMC_Estimate_Week__c> clonedEstimateWeeks = new map<CMC_Estimate_Week__c, CMC_Estimate_Week__c>();
        map<CMC_Estimate_Resource__c, CMC_Estimate_Resource__c> clonedEstimateResources = new map<CMC_Estimate_Resource__c, CMC_Estimate_Resource__c>();
        list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = new list<E2_Clone_Estimate_WSManager.EstimateWrapper>();
        // clone estimate weeks
        for(CMC_Estimate_Week__c estimateWeek : E2_Clone_DataUtil_WS.getEstimateWeekMByEstimateId( timelineToClone.keySet() )) {
            CMC_Estimate_Week__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
            clonedEstimateWeek.Estimate__c = timelineToClone.get(estimateWeek.Estimate__c).Id;
            clonedEstimateWeeks.put(estimateWeek, clonedEstimateWeek);
        }
        if(!clonedEstimateWeeks.isEmpty()) {
            // clone estimate resources
            for(CMC_Estimate_Resource__c estimateRecource : E2_Clone_DataUtil_WS.getResourceRequestByEstimateId( timelineToClone.keySet() )) {
                CMC_Estimate_Resource__c clonedEstimateRecource = estimateRecource.clone(false, true, false, false);
                clonedEstimateRecource.Estimate__c = timelineToClone.get(estimateRecource.Estimate__c).Id;
                clonedEstimateRecource.E2_Estimate_Rate_Card__c = estimateRecource.E2_Estimate_Rate_Card__c != NULL && 
                                                                    clonedRateCards.containsKey(estimateRecource.E2_Estimate_Rate_Card__c) ? 
                                                                    clonedRateCards.get(estimateRecource.E2_Estimate_Rate_Card__c).id : NULL;
                clonedEstimateResources.put(estimateRecource, clonedEstimateRecource);
            }
            
            // insert Resource timeline 
            insert clonedEstimateWeeks.values();
            if(!clonedEstimateResources.isEmpty()) {
                insert clonedEstimateResources.values();
                // generate estimate weeks mapping
               for(CMC_Estimate_Week__c oldWeek : clonedEstimateWeeks.keySet()) {
                    E2_Clone_Estimate_WSManager.EstimateWrapper mapping = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                    mapping.key = oldWeek.Id;
                    mapping.value = clonedEstimateWeeks.get(oldWeek).id;
                    mapping.isWeek = true;
                    mapping.cloneFrom = oldWeek.Estimate__c;
                	mapping.newTimelineId = clonedEstimateWeeks.get(oldWeek).Estimate__c;
                	mapping.newEstimateId = clonedEstimateWeeks.get(oldWeek).Estimate__c;
                    mappingList.add(mapping); 
                }
                // generate estimate resource mapping
                for(CMC_Estimate_Resource__c oldResource : clonedEstimateResources.keySet()) {
                    E2_Clone_Estimate_WSManager.EstimateWrapper mapping = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                    mapping.key = oldResource.Id;
                    mapping.value = clonedEstimateResources.get(oldResource).id;
                    mapping.isWeek = false;
                    mapping.cloneFrom = oldResource.Estimate__c;
                	mapping.newTimelineId = clonedEstimateResources.get(oldResource).Estimate__c;
                	mapping.newEstimateId = clonedEstimateResources.get(oldResource).Estimate__c;
                    mappingList.add(mapping);
                }
            }
        }
        return mappingList;
    }
    
    // clone estimate resource weeks
    public static string cloneResourceWeeks(string estimateWrapperJSON) {
         if(!string.isBlank(estimateWrapperJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(estimateWrapperJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            try {
                map<string, string> clonedEstimateWeeks = new map<string, string>();
                map<string, string> clonedEstimateResources = new map<string, string>();
                list<CMC_Estimate_Resource_Week__c> clonedEstimateResourceWeekMapping = new list<CMC_Estimate_Resource_Week__c>();
                for(E2_Clone_Estimate_WSManager.EstimateWrapper mapping : mappingList) {
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
                if(!clonedEstimateResourceWeekMapping.isEmpty()){
                  insert clonedEstimateResourceWeekMapping;
                }
                E2_Clone_Estimate_WSManager.EstimateWrapper estimateWrapper = new E2_Clone_Estimate_WSManager.EstimateWrapper();
                estimateWrapper.cloneFrom = mappingList.get(0).cloneFrom;
                estimateWrapper.newEstimateId = mappingList.get(0).newEstimateId;
                estimateWrapper.estimateIsActive = mappingList.get(0).estimateIsActive;
                estimateWrapper.partialClone = mappingList.get(0).partialClone;
                return JSON.serialize(estimateWrapper);
            } catch(Exception ex) {
                deleteEstimate(mappingList.get(0).newEstimateId);
                return FAILED_PREFIX + ERROR_MESSAGE;
            }
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
    
    // clone Estimate - create child Estimate
    public static string createNewTimeline(string timelineJSON) {
        if(!string.isBlank(timelineJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)
                                                                            JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            if(!mappingList.isEmpty() && !string.isBlank(mappingList.get(0).cloneFrom) 
                && !string.isBlank(mappingList.get(0).currencyISOCode)) {
                    CMC_Presales_LOE__c clonedTimeline = NULL;
                    
                    if(mappingList.get(0).isNewTimeline) {
                        clonedTimeline = new CMC_Presales_LOE__c();
                        clonedTimeline.CurrencyISOCode = mappingList.get(0).currencyISOCode;
                        //clonedTimeline.E2_Is_specific_to_timeline__c = true;
                        clonedTimeline.Name = CHILD_PREFIX;
                    } else {
                        for(CMC_Presales_LOE__c timeline : E2_Clone_DataUtil_WS.getTimeline(mappingList.get(0).cloneFrom)) {
                            clonedTimeline = timeline.clone(false, true, false, false);
                        }
                    }
                    
                    if(clonedTimeline <> NULL) {
                        clonedTimeline.E2_Is_specific_to_timeline__c = true;
                        clonedTimeline.E2_Is_Active__c = true;
                    
                        clonedTimeline.E2_Parent_Estimate__c = mappingList.get(0).parentTimelineId <> NULL ? 
                                                                mappingList.get(0).parentTimelineId : mappingList.get(0).cloneFrom;
                        clonedTimeline.E2_Timeline_Name__c = string.isNotBlank(mappingList.get(0).timelineName) ? 
                                                            mappingList.get(0).timelineName : NULL;
                        clonedTimeline.E2_Date_Scoped__c = System.today();
                        clonedTimeline.E2_SA__c = UserInfo.getUserId(); // TO-DO : discuss with Andres 
                        try {
                            insert clonedTimeline;
                            if(mappingList.get(0).isNewTimeline) {
                                E2_Estimator_Manager.getEstimateRateCards(clonedTimeline.id, clonedTimeline.CurrencyISOCode);
                            }
                            mappingList.get(0).newTimelineId = clonedTimeline.id;
                            return JSON.serialize(mappingList);
                        } catch(Exception ex) {
                            return FAILED_PREFIX + ex.getMessage();//ERROR_MESSAGE;
                        }
                    }
                }
        }
        return INVALID_TIMELINE_MESSAGE;
    } 
    
    // clone estimate rate card only
    public static string cloneTimelineRateCards(string timelineJSON) {
        if(!string.isBlank(timelineJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)
                                                                            JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            if(!mappingList.isEmpty() && !string.isBlank(mappingList.get(0).cloneFrom) 
                && !string.isBlank(mappingList.get(0).newTimelineId)) {
                try {
                    map<string, CMC_Presales_LOE__c> timelineToClone = new map<string, CMC_Presales_LOE__c>();
                    timelineToClone.put(mappingList.get(0).cloneFrom , new CMC_Presales_LOE__c(Id = mappingList.get(0).newTimelineId));
                    cloneTimelineRateCards(timelineToClone);
                } catch (Exception ex) {
                    deleteEstimate(mappingList.get(0).newTimelineId);
                    return FAILED_PREFIX + ERROR_MESSAGE;
                }
                return timelineJSON;
            }
        }
        return INVALID_TIMELINE_MESSAGE;
    }
    
    // clone timeline with rate card : For multiple timeline version
    public static string cloneTimelineVersion(string timelineJSON) {
        if(!string.isBlank(timelineJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)
                                                                            JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            if(!mappingList.isEmpty() && !string.isBlank(mappingList.get(0).cloneFrom) 
                && !string.isBlank(mappingList.get(0).newTimelineId)) {
                try {
                    map<string, CMC_Presales_LOE__c> timelineToClone = new map<string, CMC_Presales_LOE__c>();
                    timelineToClone.put(mappingList.get(0).cloneFrom , new CMC_Presales_LOE__c(Id = mappingList.get(0).newTimelineId));
                    
                    map<Id, E2_Estimate_Rate_Card__c> clonedRateCards = cloneTimelineRateCards(timelineToClone);
                    if(!clonedRateCards.isEmpty()) {
                        list<E2_Clone_Estimate_WSManager.EstimateWrapper> resourceWeekMapping = cloneTimelineResourcesAndWeeks( timelineToClone,
                                                                                                                                clonedRateCards);
                        if(!resourceWeekMapping.isEmpty()) return JSON.serialize(resourceWeekMapping);
                    }
                } catch (Exception ex) {
                    deleteEstimate(mappingList.get(0).newTimelineId);
                    return FAILED_PREFIX + ERROR_MESSAGE;
                }
                return SUCCESS_MESSAGE + mappingList.get(0).newTimelineId;
            }
        }
        return INVALID_TIMELINE_MESSAGE;
    }
    
     // clone estimate resource weeks : For multiple timeline version
    public static string cloneResourceWeeksTimelineVersion(string timelineJSON) {
        if(!string.isBlank(timelineJSON)) {
            list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)
                                                                            JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
            if(!mappingList.isEmpty() && !string.isBlank(mappingList.get(0).cloneFrom) 
                && !string.isBlank(mappingList.get(0).newTimelineId)) {
                    try {
                        map<string, string> clonedEstimateWeeks = new map<string, string>();
                        map<string, string> clonedEstimateResources = new map<string, string>();
                        list<CMC_Estimate_Resource_Week__c> clonedEstimateResourceWeekMapping = new list<CMC_Estimate_Resource_Week__c>();
                        for(E2_Clone_Estimate_WSManager.EstimateWrapper mapping : mappingList) {
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
                        if(!clonedEstimateResourceWeekMapping.isEmpty()){
                          insert clonedEstimateResourceWeekMapping;
                        }    
                        return mappingList.get(0).newTimelineId;
                    } catch(Exception ex) {
                        deleteEstimate(mappingList.get(0).newTimelineId);
                        return FAILED_PREFIX + ERROR_MESSAGE;
                    }
            }
        }
        return INVALID_TIMELINE_MESSAGE;
    }
    
    //wrapper class for resource, week, milestone mapping 
    public class EstimateWrapper {
    	public string key;
    	public string value;
    	public boolean isWeek;
    	// RS : variables for multiple timeline feature
    	public string cloneFrom;
    	public string newTimelineId;
    	public string currencyISOCode;
    	public string parentTimelineId;
    	public string newEstimateId;
    	public boolean estimateIsActive;
    	public boolean partialClone;
    	public string timelineName;
    	public boolean isNewTimeline;
    }
    
    // wrapper class for cloned scopes mapping
    public class ScopeMapping {
        public string key;
        public string value;
        public string cloneFrom;
        public string newEstimateId;
    	public boolean estimateIsActive;
    	public boolean partialClone;
    }
    
    // End : Estimate clone functionality
}