/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_Estimate_WS
 * Description: S-454105 :  Web service E2_Clone_Estimate_WS 
 * Created Date: Nov 22, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
global without sharing class E2_Clone_Estimate_WS {
    
    // Start S-454105 : Estimate clone functionality
    // S-454105 :clone Estimate 
    webservice static string cloneEstimate(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneEstimate( estimateWrapperJSON );
    } 
    
    // S-454105 :clone Scopes
    webservice static string cloneEstimateScopes(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneEstimateScopes( estimateWrapperJSON);
    }
    
    // S-454105 : reParentScope
    webservice static string reParentClonedScopes(string estimateWrapperJSON) { 
        return E2_Clone_Estimate_WSManager.reParentClonedScopes(estimateWrapperJSON);
    }
    
    // S-454105 :clone Capacity
    webservice static string cloneEstimateCapacity(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneEstimateCapacity( estimateWrapperJSON);
    }
    
    // S-454105 :clone estimate milestones
    webservice static string cloneEstimateMilestone(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneEstimateMilestone( estimateWrapperJSON);
    }
    
    // clone milestones weeks
    webservice static string cloneMilestoneWeeks(string estimateWrapperJSON ) {
        return E2_Clone_Estimate_WSManager.cloneMilestoneWeeks(  estimateWrapperJSON );
    }
    
    // S-454105 :clone timeline with rate card
    webservice static string cloneEstimateTimeline(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneEstimateTimeline( estimateWrapperJSON);
    }
    
    // clone estimate resource weeks
    webservice static string cloneResourceWeeks(string estimateWrapperJSON) {
        return E2_Clone_Estimate_WSManager.cloneResourceWeeks( estimateWrapperJSON );
    }
    
    // S-454105 :DELETE ESTIMATE
    webservice static string deleteEstimate(string estimateId) {
        return E2_Clone_Estimate_WSManager.deleteEstimate( estimateId );
    }
    
     // clone Estimate - create child Estimate
    webservice static string createNewTimeline(string timelineJSON) {
        return E2_Clone_Estimate_WSManager.createNewTimeline( timelineJSON );
    } 
    
    // clone estimate rate card only
    webservice static string cloneTimelineRateCards(string timelineJSON) {
        return E2_Clone_Estimate_WSManager.cloneTimelineRateCards( timelineJSON );
    }
    
    // clone timeline with rate card : For multiple timeline version
    webservice static string cloneTimelineVersion(string timelineJSON) {
        return E2_Clone_Estimate_WSManager.cloneTimelineVersion( timelineJSON );
    }
    
    // clone estimate resource weeks : For multiple timeline version
    webservice static string cloneResourceWeeksTimelineVersion(string timelineJSON) {
        return E2_Clone_Estimate_WSManager.cloneResourceWeeksTimelineVersion( timelineJSON );
    }
    // End : Estimate clone functionality

}