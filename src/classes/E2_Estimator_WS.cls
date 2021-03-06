/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WS
 * Description:  
 * Created Date: 
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 *  Jul 15, 2016	  Vikash Goyal					Added method for updating display orders of scope updateScopesDisplayOrder()
 * Oct 19, 2016       Arpita Bose                  S-448268 : Cloned scope item on right click
 * Dec 12, 2016       Rohit Sharma                 S-453054 : Set scope type for multiple scope items on scope tree.
 * Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope: New web service added update scope
 *                                                 effort multiplier
*  =====================================================================*/
global without sharing class E2_Estimator_WS {
    
    webservice static List<E2_TreeNode> retrieveAllScopeTreeNodesOnEstimateId(string estimateId){
       return E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnEstimateId(estimateId);
    }
    
    webservice static List<E2_TreeNode> retrieveAllScopeTreeNodesOnScopeGroup(string scopeGrpId){
       return E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnScopeGroup(scopeGrpId);
    }
    
    webservice static string reparentScope(string scopeId, string parentId){
       return E2_Estimator_WSManager.reparentScope(scopeId, parentId);
    }
    
    webservice static string deleteScope(string scopeId, string parentId){          
       return E2_Estimator_WSManager.deleteScope(scopeId, parentId);
    }
    
    webservice static List<E2_TreeNode> getParentNodesWithEffortsOnEstimateId(string estimateId){
      return E2_Estimator_WSManager.getParentNodesWithEffortsOnEstimateId(estimateId);
    }
    
    webservice static List<E2_TreeNode> getImmediateChildNodesWithEffortsOnScopeId(string scopeId){
        return E2_Estimator_WSManager.getImmediateChildNodesWithEffortsOnScopeId(scopeId);    
    }
    
    
    /*webservice static E2_TreeNodeMap getClonedNodes(string scopeId, string estimateId, string parentScopeId){
        return E2_Estimator_WSManager.getClonedNodes(scopeId, estimateId, parentScopeId);        
    }*/
    
    /*webservice static E2_TreeNodeMap getChildCloneNodes(string parentId, string sourceId, string estimateId){
        return E2_Estimator_WSManager.getChildCloneNodes(parentId, sourceId, estimateId);    
    }*/

    webservice static E2_TreeNodeMap getScopeDetailNodes(string scopeId){
        return E2_Estimator_WSManager.getScopeDetailNodes(scopeId);        
    }

    webservice static E2_TreeNodeMap getChildScopeDetailNodes(string parentId){
        return E2_Estimator_WSManager.getChildScopeDetailNodes(parentId); 
    }
    
    webservice static List<E2_TreeNode> getClonedNodesTemplate(string scopeId, string scopeGrpId, string parentScopeId){
        return E2_Estimator_WSManager.getClonedNodesTemplate(scopeId, scopeGrpId, parentScopeId);        
    }
    
    /*webservice static E2_TreeNodeMap getChildCloneNodesTemplate(string parentId, string sourceId, string scopeGrpId){
        return E2_Estimator_WSManager.getChildCloneNodesTemplate(parentId, sourceId, scopeGrpId);    
    }*/
        
    webservice static string updateScopeFlag(string scopeId, string flagValue){
        return E2_Estimator_WSManager.updateScopeFlag(scopeId, flagValue);
    }
    
    //Method to update display order of scopes when re-parented
    webservice static string updateScopesDisplayOrder(string scopeJsonStr){
        return E2_Estimator_WSManager.updateScopesDisplayOrder(scopeJsonStr);
    }
    
    //Method to get asset records
    webservice static E2_AssetWrapperMap searchAssets(string searchStr, List<string> exisitingAssetIds){
        return E2_Estimator_WSManager.searchAssets(searchStr, exisitingAssetIds);
    }
    
    //Method to get existing asset records for scope
    webservice static String getExistingAssetsForScope(string scopeId){
        return E2_Estimator_WSManager.getExistingAssetsForScope(scopeId);
    }
    
    // Method to clonned scopes 
    webservice static List<E2_TreeNode> getSelectedScopeNodes(string scopeIdCSV, string estimateId, string parentScopeId) {
    	return E2_Estimator_WSManager.getSelectedScopeNodes(scopeIdCSV, estimateId, parentScopeId);
    } 
    
    // Method to update child scope complexity and Active state
    webservice static string updateScopesStatus(string complexity, string scopeToActivate, string scopeToDeactivate,
    										string allscopesIds) {
    	return E2_Estimator_WSManager.updateScopesStatus(complexity, scopeToActivate, scopeToDeactivate,
    										allscopesIds);						
    }
    
    // AB : S-448268 : Cloned scope item on right click 
    webservice static List<E2_TreeNode> cloneScopeWithChild(string scopeIdCSV) {
      return E2_Estimator_WSManager.cloneScopeWithChild(scopeIdCSV);
    } 
    
    // RS S-453054 : 12/12 : change Scope Type webservice
    webservice static string changeScopeType(string selectedScopesJSON) {
        return E2_Estimator_WSManager.changeScopeType( selectedScopesJSON );
    }
    
    webservice static string retrieveTreeContentOnScopeDetailSave(string estimateId) {
        return E2_Estimator_WSManager.retrieveTreeContentOnScopeDetailSave( estimateId );
    }
    
    // RS S-453054: 12/12 : change Scope Active status webservice
    webservice static string changeScopeActiveStatus(string selectedScopesJSON) {
        return E2_Estimator_WSManager.changeScopeActiveStatus( selectedScopesJSON );
    }
    
    // RS S-453054: 12/12 : change Scope Complexity webservice
    webservice static string changeScopeComplexity(string selectedScopesJSON) {
        return E2_Estimator_WSManager.changeScopeComplexity( selectedScopesJSON );
    }
    
     // RS S-453054: 12/12 : change Scope Complexity for Scope Library  webservice
    webservice static string changeScopeComplexityForScopeLibrary(string selectedScopesJSON) {
        return E2_Estimator_WSManager.changeScopeComplexityForScopeLibrary( selectedScopesJSON );
    }
    
    // RS S-453054: 12/12 : change Scope Active status webservice
    webservice static string changeScopeActiveStatusForScopeLibrary(string selectedScopesJSON) {
        return E2_Estimator_WSManager.changeScopeActiveStatusForScopeLibrary( selectedScopesJSON );
    }
    
    // RS S-447325 : 2/02 : add effort multiplier to scope
    webservice static string addEffortMultiplier(string selectedScopesJSON) {
        return E2_Estimator_WSManager.addEffortMultiplier( selectedScopesJSON );
    }
    
    // RS S-447325 : 2/02 : add effort multiplier to scope on scopegroup
    webservice static string addEffortMultiplierOnScopeGroup(string selectedScopesJSON) {
        return E2_Estimator_WSManager.addEffortMultiplierOnScopeGroup( selectedScopesJSON );
    }
}