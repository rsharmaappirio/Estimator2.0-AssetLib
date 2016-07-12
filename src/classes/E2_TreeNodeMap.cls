/**=====================================================================
 * Appirio, Inc
 * Name: E2_TreeNodeMap
 * Description: TreeNodeMap wrapper for JsTree show on AddEditScope page
 * Created Date: Apr 22th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
global class E2_TreeNodeMap {
  webservice string scope_id;
  webservice List<E2_TreeNode> nodeList;
  
  public E2_TreeNodeMap(string scopeId, List<E2_TreeNode> nodeList){
    this.scope_id = scopeId;
    this.nodeList = nodeList;       
  }
}