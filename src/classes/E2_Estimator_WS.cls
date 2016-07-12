/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WS
 * Description:  
 * Created Date: 
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
global with sharing class E2_Estimator_WS {
    
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
    
    
    webservice static E2_TreeNodeMap getClonedNodes(string scopeId, string estimateId, string parentScopeId){
        return E2_Estimator_WSManager.getClonedNodes(scopeId, estimateId, parentScopeId);        
    }
    
    webservice static E2_TreeNodeMap getChildCloneNodes(string parentId, string sourceId, string estimateId){
        return E2_Estimator_WSManager.getChildCloneNodes(parentId, sourceId, estimateId);    
    }

    webservice static E2_TreeNodeMap getScopeDetailNodes(string scopeId){
        return E2_Estimator_WSManager.getScopeDetailNodes(scopeId);        
    }

    webservice static E2_TreeNodeMap getChildScopeDetailNodes(string parentId){
        return E2_Estimator_WSManager.getChildScopeDetailNodes(parentId); 
    }
    
    webservice static E2_TreeNodeMap getClonedNodesTemplate(string scopeId, string scopeGrpId, string parentScopeId){
        return E2_Estimator_WSManager.getClonedNodesTemplate(scopeId, scopeGrpId, parentScopeId);        
    }
    
    webservice static E2_TreeNodeMap getChildCloneNodesTemplate(string parentId, string sourceId, string scopeGrpId){
        return E2_Estimator_WSManager.getChildCloneNodesTemplate(parentId, sourceId, scopeGrpId);    
    }
        
        webservice static string updateScopeFlag(string scopeId, string flagValue){
                return E2_Estimator_WSManager.updateScopeFlag(scopeId, flagValue);
        }
}