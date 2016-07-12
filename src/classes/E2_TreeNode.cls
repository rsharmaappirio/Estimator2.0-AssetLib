/**=====================================================================
 * Appirio, Inc
 * Name: E2_TreeNode
 * Description: TreeNode wrapper for JsTree show on AddEditScope page
 * Created Date: Apr 22th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
global class E2_TreeNode {
    webservice string title; 
    webservice boolean isFolder;
    webservice boolean isLazy;
    webservice string key;
    webservice string parent;
    webservice string state;
    webservice string id;
    webservice string text;
    webservice boolean hasChildren;
    webservice string sourceId;
    webservice string node_type;
    webservice string complexity;
    webservice decimal loe_hrs;
    webservice string description;
    
    public E2_TreeNode(string title, boolean isFolder, boolean isLazy, string key){
        this.title = title;
        this.isFolder = isFolder;
        this.isLazy = isLazy;
        this.key = key;
    }
    public E2_TreeNode(string title, boolean isFolder, boolean isLazy, string key, string parent){
        this(title, isFolder, isLazy, key);
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';//new E2_State();
        this.id = key;
        this.text = title;
    }
    
    // for clone
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';//new E2_State();
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;
    }
    
    // for scope details
    public E2_TreeNode(string id,string title, string text, string parent, boolean hasChildren, string sourceId, string node_type){
        this(id, text, parent, hasChildren, sourceId, node_type);
        this.title = title;
    }
    
    // for efforts
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId, string node_type){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';//new E2_State();
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;
        this.node_type = node_type;
    }
// for details    
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId,
                       string complexity, decimal loe_hrs, string description){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';//new E2_State();
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;        
        this.complexity = complexity;
        this.loe_hrs = loe_hrs;
        this.description = description;
    }
    
}