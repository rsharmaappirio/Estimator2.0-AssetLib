/**=====================================================================
 * Appirio, Inc
 * Name: E2_TreeNode
 * Description: TreeNode wrapper for JsTree show on AddEditScope page
 * Created Date: Apr 22th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
   Dec 8th, 2016      Rohit Sharma          S-449145 :Ability to find the Scope by type, 
                                            Complexity ,Q&A and assets assigned.
   Feb 08, 2017       Rohit Sharma        S-447325 : Add multiplier on Scope: New variable to store 
                                          scope multiplier and new constructor to get multiplier value in wrapper.
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
    webservice decimal display_order;
    // new variables to map scope type, questions count, asset count
    webservice string scope_type;
    webservice boolean hasQuestion;
    webservice boolean hasAsset;
    webservice decimal multiplier;
    
    
    public E2_TreeNode(string title, boolean isFolder, boolean isLazy, string key){
        this.title = title;
        this.isFolder = isFolder;
        this.isLazy = isLazy;
        this.key = key;
    }
    
    public E2_TreeNode(string title, boolean isFolder, boolean isLazy, string key, string parent){
        this(title, isFolder, isLazy, key);
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';
        this.id = key;
        this.text = title;
    }
    
    // for clone
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';
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
    
    public E2_TreeNode(string id,string title, string text, string parent, boolean hasChildren, string sourceId, string node_type, decimal displayOrder){
        this(id, text, parent, hasChildren, sourceId, node_type);
        this.title = title;
        this.display_order = displayOrder;
    }
    
    // for full scope details 
    public E2_TreeNode(string id,string title, string text, string parent, boolean hasChildren, string sourceId, string node_type, decimal displayOrder, string complexity, string scope_type, boolean hasQuestion, boolean hasAsset){
        this( id, title, text, parent, hasChildren, sourceId, node_type, displayOrder);
        this.complexity = complexity;
        this.scope_type = scope_type;
        this.hasQuestion = hasQuestion;
        this.hasAsset = hasAsset;
    }
    
    // for efforts
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId, string node_type){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;
        this.node_type = node_type;
    }
    
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId, string node_type, decimal displayOrder){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;
        this.node_type = node_type;
        this.display_order = displayOrder;
    }
    
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId, string node_type, decimal displayOrder, decimal multiplier){
        this( id, text,  parent,  hasChildren,  sourceId,  node_type, displayOrder);
        this.multiplier = multiplier;
    }
    
    // for details    
    public E2_TreeNode(string id, string text, string parent, boolean hasChildren, string sourceId,
                       string complexity, decimal loe_hrs, string description){
        this.parent = parent;
        this.state = '{"disabled":false, "opened":true, "selected":false}';
        this.id = id;
        this.text = text;
        this.hasChildren = hasChildren;
        this.sourceId = sourceId;        
        this.complexity = complexity;
        this.loe_hrs = loe_hrs;
        this.description = description;
    }
    
    // for full scope details 
    public E2_TreeNode(string id,string title, string text, string parent, boolean hasChildren, string sourceId, string node_type,
            decimal displayOrder, string complexity, string scope_type, boolean hasQuestion, boolean hasAsset, decimal multiplier){
        this( id, title,  text,  parent,  hasChildren,  sourceId,  node_type,  displayOrder,  complexity,  scope_type,  hasQuestion,  hasAsset);
        this.multiplier = multiplier;
    }
}