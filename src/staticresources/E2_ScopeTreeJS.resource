$( document ).ready(function() {
    AddScopeTree.GenerateTree(scope_sfdc_id);
    window.setTimeout(function() {
            resetIframeHeight();
        }, 1000);
});
function hideSpinner(){
    $('#loadingSpinner').hide();
    return false;
}

function showSpinner(){
    $('#loadingSpinner').show().css('height', $(document).outerHeight());
    return false;
}
var resetIframeHeight = function(){
  if(parent && parent.AddEditQuestionAnswer && parent.AddEditQuestionAnswer.setHeightOfEditScopeModal){
    parent.AddEditQuestionAnswer.setHeightOfEditScopeModal($(document.body).outerHeight());         
  }
}
// JStree Initiate Conffiguration 
var jstree_options = {
    "plugins": ["checkbox"],
	    'core': {
		    'check_callback': true,
			'animation': 200,
			'themes': {
			    'name': 'proton',
				"icons": false,
				'responsive': true
			},
			"multiple": true
		},
		"checkbox" : {
		    "cascade": "",
		    "three_state": false,
		    "keep_selected_style" : false
		}
};
// JS to generate/destroy Scope tree on scope click
var AddScopeTree = {
    CREATE_NODE: 'create_node',
	OPEN_NODE: 'open_node',
	LAST: 'last',
	addscopenode_call_register: {},
	addscopepill_register: {},
	hasChildScope : false,
	GenerateTree : function(scopeId) {
	    $(treeId).jstree(jstree_options);
		AddScopeTree.tree_init(scopeId);
	},
	refreshTree : function() {
	    AddScopeTree.getselectedTreeNode();
	},
	create_node: function(node, position) {
	    node.state = JSON.parse(node.state);
		// jstree api call to create the tree node.
		$(treeId).jstree(AddScopeTree.CREATE_NODE, node.parent, node, position);
	},
	open_node: function(node) {
	     // jstree api call to open current node.
	    $(treeId).jstree(AddScopeTree.OPEN_NODE, node);
	},
	tree_init: function(scopeId) {			    	
	    showSpinner();
		AddScopeTree.addscopenode_call_register[scopeId] = '#';	    	
		sforce.apex.execute("E2_Estimator_WS","getChildScopeDetailNodes", {parentId:scopeId}, AddScopeTree.tree_init_callback);
	},
	tree_init_callback: {
	    onSuccess: function(result) {
		    var haschildren = false; 
			if(result.length > 0){
			    AddScopeTree.hasChildScope = true;
	            var scope_id = result[0].scope_id;
	            if (result[0].nodeList && result[0].nodeList.length) {
		            $.each(result[0].nodeList, function(indx, node) {
		                node.parent = "#";
		                AddScopeTree.create_node(node, AddScopeTree.LAST);
		                if (node.hasChildren == true || node.hasChildren == 'true') {
		                    hasChildren = true;
		                    AddScopeTree.addscopenode_call_register[node.id] = scope_id;
		                    AddScopeTree.getScopeChildDetail_Recurring(node.id);
		                }
		            });
			    } else if (result[0].nodeList) {
			        var node = result[0].nodeList;
			        node.parent = "#";
			        AddScopeTree.create_node(node, AddScopeTree.LAST);
			        if (node.hasChildren == true || node.hasChildren == 'true') {
			            hasChildren = true;
			            AddScopeTree.addscopenode_call_register[node.id] = scope_id;
			            AddScopeTree.getScopeChildDetail_Recurring(node.id);
			        }
			     }	  
		         if (AddScopeTree.addscopenode_call_register && AddScopeTree.addscopenode_call_register[scope_id]) delete AddScopeTree.addscopenode_call_register[scope_id];
		         if (AddScopeTree.addscopenode_call_register && JSON.stringify(AddScopeTree.addscopenode_call_register) == '{}') {
		            hideSpinner();
				 }
	        } else {
	            AddScopeTree.hasChildScope = false;
		        hideSpinner();
	        }
        },
		onFailure: function(error) {
		    alert(error);
		}
	},
	getScopeChildDetail_Recurring : function(parentId){
        showSpinner();
		sforce.apex.execute("E2_Estimator_WS","getChildScopeDetailNodes", {parentId:parentId},AddScopeTree.getScopeChildDetail_callback);
	},
	getScopeChildDetail_callback: {
	    onSuccess: function(result) {
		    var haschildren = false;
			if(result.length > 0){
	            var scope_id = result[0].scope_id;
	            if (result[0].nodeList && result[0].nodeList.length) {
			        $.each(result[0].nodeList, function(indx, node) {
			            AddScopeTree.create_node(node, AddScopeTree.LAST);
			            if (node.hasChildren == true || node.hasChildren == 'true') {
			                hasChildren = true;
			                AddScopeTree.addscopenode_call_register[node.id] = scope_id;
			                AddScopeTree.getScopeChildDetail_Recurring(node.id);
			            }
			        });
    		    } else if (result[0].nodeList) {
    			    var node = result[0].nodeList;
    				AddScopeTree.create_node(node, AddScopeTree.LAST);
    				if (node.hasChildren == true || node.hasChildren == 'true') {
    				    hasChildren = true;
    				    AddScopeTree.addscopenode_call_register[node.id] = scope_id;
    				    AddScopeTree.getScopeChildDetail_Recurring(node.id);
    				}
    			}	  
    			if (AddScopeTree.addscopenode_call_register && AddScopeTree.addscopenode_call_register[scope_id]) delete AddScopeTree.addscopenode_call_register[scope_id];
    			if (AddScopeTree.addscopenode_call_register && JSON.stringify(AddScopeTree.addscopenode_call_register) == '{}') {
    			    hideSpinner();
    			}
    		} else {
			        hideSpinner();
			}
        },
		onFailure: function(error) {
		    alert(error);
		}
	},
	getselectedTreeNode : function() {
	    var selectedscopes = [];
	    var $node = $(treeId).jstree(true).get_node('#');
		$.each($node.children_d, function(indx, id) {
		    var $childnode = $(treeId).jstree(true).get_node(id);
		    if($childnode.state.selected) {
		        selectedscopes.push($childnode.original.id);
		     }
		 });
		 return selectedscopes;
 	},
 	getselectedTreeNodeNames : function() {
	    var selectedscopes = [];
	    var $node = $(treeId).jstree(true).get_node('#');
		$.each($node.children_d, function(indx, id) {
		    var $childnode = $(treeId).jstree(true).get_node(id);
		    if($childnode.state.selected) {
		        selectedscopes.push($childnode.original.title);
		     }
		 });
		 return selectedscopes;
 	},
	updateTreeState : function(nodeIds) {
	    showSpinner();
	    var $node = $(treeId).jstree(true).get_node('#');
		$.each($node.children_d, function(indx, id) {
		    if(nodeIds != '' && nodeIds.includes(id)) {
		        $(treeId).jstree(true).select_node(id);
		    } else {
		        $(treeId).jstree(true).deselect_node(id);
		    }
	    });
	    resetIframeHeight();
	    hideSpinner();
	}
}