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
    webservice static string cloneEstimate(string estimateId) {
        return E2_Clone_Estimate_WSManager.cloneEstimate( estimateId );
    } 
    
    // S-454105 :clone Scopes
    webservice static string cloneEstimateScopes(string estimateId, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneEstimateScopes( estimateId, newEstimateId);
    }
    
    // S-454105 :clone Capacity
    webservice static string cloneEstimateCapacity(string estimateId, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneEstimateCapacity( estimateId, newEstimateId);
    }
    
    // S-454105 :clone estimate milestones
    webservice static string cloneEstimateMilestone(string estimateId, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneEstimateMilestone( estimateId, newEstimateId);
    }
    
    // clone milestones weeks
    webservice static string cloneMilestoneWeeks(string milestoneWeekJSON, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneMilestoneWeeks( milestoneWeekJSON, newEstimateId);
    }
    
    // S-454105 :clone timeline with rate card
    webservice static string cloneEstimateTimeline(string estimateId, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneEstimateTimeline( estimateId, newEstimateId);
    }
    
    // clone estimate resource weeks
    webservice static string cloneResourceWeeks(string resourceWeekJSON, string newEstimateId) {
        return E2_Clone_Estimate_WSManager.cloneResourceWeeks( resourceWeekJSON, newEstimateId);
    }
    
    // S-454105 :DELETE ESTIMATE
    webservice static string deleteEstimate(string estimateId) {
        return E2_Clone_Estimate_WSManager.deleteEstimate( estimateId );
    }
    // End : Estimate clone functionality

}