var CustomAlert = {
    notifyContainerCssSelector: '.slds-notify_container',
    notifyCloseCssSelector: '.slds-notify__close',
    notifyMsgCssSelector: '.slds-text-heading--small',
    notifyTypeCssDiv: '#sldsalertdiv',
    show: function(msg) {
        $(CustomAlert.notifyContainerCssSelector).css({
            position: 'absolute !important',
            'opacity': '100',
            'display': 'block'
        });
        $(CustomAlert.notifyTypeCssDiv).removeClass("slds-theme--error");
        $(CustomAlert.notifyTypeCssDiv).addClass("slds-theme--success");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyMsgCssSelector).text(msg);
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).unbind("click");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).bind("click", function() {
            $(CustomAlert.notifyContainerCssSelector).stop(true, true).fadeTo().slideUp();
            return false;
        });
        window.setTimeout(function() {
            if ($(CustomAlert.notifyContainerCssSelector).is(":visible")) {
                $(CustomAlert.notifyContainerCssSelector).fadeTo(500, 0).slideUp(500, function() {
                    $(this).hide();
                });
            }
        }, 2000);
    },
    hide: function() {
        $(CustomAlert.notifyContainerCssSelector).hide();
    },
    showError: function(msg) {
        $(CustomAlert.notifyContainerCssSelector).css({
            position: 'absolute !important',
            'opacity': '100',
            'display': 'block'
        });
        $(CustomAlert.notifyTypeCssDiv).removeClass("slds-theme--success");
        $(CustomAlert.notifyTypeCssDiv).addClass("slds-theme--error");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyMsgCssSelector).text(msg);
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).unbind("click");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).bind("click", function() {
            $(CustomAlert.notifyContainerCssSelector).stop(true, true).fadeTo().slideUp();
            return false;
        });
        window.setTimeout(function() {
            if ($(CustomAlert.notifyContainerCssSelector).is(":visible")) {
                $(CustomAlert.notifyContainerCssSelector).fadeTo(500, 0).slideUp(500, function() {
                    $(this).hide();
                });
            }
        }, 2000);
    }
}



// Group of JS methods specific to this page.
var treeId = '#relationShipTree';
var loadSpinner = '#loadingSpinner';



var jstree_options = {
    "plugins": ["dnd", "contextmenu", "search"],
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
    'checkbox': {
        'three_state': false,
        'cascade': ''
    },
    "contextmenu": {
    	"select_node" : true,
        "items": function($node) {
            var tree = $(treeId).jstree(true);
            
            var selected_nodes_arr = $( treeId + ' li.jstree-node').
                  filter(function() { return $(this).children('a.jstree-anchor.jstree-clicked').length != 0; }).
                  map(function() { return this.id; }).get();
      
            if(selected_nodes_arr.length === 1){
                return AddEditScope.contextmenuForSingleNodeSelects(tree, $node, selected_nodes_arr); 
            }else if(selected_nodes_arr.length > 1){
                return AddEditScope.contextmenuForMultipleNodeSelects(tree, $node, selected_nodes_arr);
            } 
        }
    }
};


$(document).ready(function() {
    $(treeId).jstree(jstree_options);


    //EVENT: JSTREE LOADED FOR THE FIRST TIME
    $(treeId).on("ready.jstree", function(e, data) {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
    });

/**
    var $scrollingDiv = $('#edit_scope_div');
    // Should probably be set in CSS; but here just for emphasis
    $scrollingDiv.css('position', 'relative');
    
		$(window).scroll(function(){			
			$scrollingDiv
				.stop()
				.animate({"marginTop": ($(window).scrollTop()) + "px"}, "slow" );			
		});
**/

    
    var element = $('#edit_scope_div'),
        originalY = element.offset().top;

    // Space between element and top of screen (when scrolling)
    var topMargin = -10;

    // Should probably be set in CSS; but here just for emphasis
    element.css('position', 'relative');

    $(window).on('scroll', function(event) {
        if ($(this).width() > 767) {
            var scrollTop = $(window).scrollTop();
            var Height1 = element.parent().height(); 
            var Height2 = (element.height() + (scrollTop - originalY + topMargin));
            if(Height1 > Height2){
                element.stop(false, false).animate({
                    top: scrollTop < originalY
                            ? 0
                            : (scrollTop - originalY + topMargin)
                }, 300);
            }
        }
    });    
    
    $( window ).resize(function() {
         //alert('window resize');
         if ($(this).width() < 767) {
            var element = $('#edit_scope_div');
            element.css({'position': 'static', 'top' : 0});
            
            // reload all the iframe again to adjust their heights
            var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
            $(containerId).find('iframe').attr("src", function(){ return $(this).attr("src")});
            
         }else{
            var element = $('#edit_scope_div');
            element.css('position', 'relative');
         }     
    });
    
    
});


var bindEvents = function(){
	//EVENT: JSTREE NODE BEING REPARENTED
    $(treeId).on("move_node.jstree", function(e, data) {
        AddEditScope.reparent_scope(data.node.id, data.parent);
    });

    //EVENT: JSTREE NODE BEING SELECTED
    AddEditScope.bindSelect_NodeEvent();
}



var AddEditScope = {
    CREATE_NODE: 'create_node',
    OPEN_NODE: 'open_node',
    LAST: 'last',
    SELECT_TEMPLATE_IFRAME_ID: 'theIframeTemplate',
    SELECT_ADD_NEW_FRAME_ID: 'theIframe1',
    SELECT_EDIT_SCOPE_FRAME_ID: 'theIframe2',
    ADD_FROM_TEMPLATE_PARENT_ID: null,
    EDIT_SCOPE_INLINE_DIV_ID : 'edit_scope_div',
    ENDS_WITH : 'editframe', 
    SAVED_SCOPE_ID : null,
    SAVED_SCOPE_NAME : null,
    GLOBAL_SCOPEID : null,
    UPDATE_DISPLAY_ORDER : false,
    OPEN_NODES : null,
    
    removeDuplicatesFromArray: function(num){
          var x,  
              len = num.length,  
              out = [],  
              obj = {};  
           
          for(x = 0; x < len; x++) {  
            obj[num[x]]=0;  
          }  
          
          for (x in obj) {  
            out.push(x);  
          }  
          
          return out;
          
    },
    
    contextmenuForSingleNodeSelects: function(tree, $node, selected_nodes_arr){
        return {
            "Remove": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Remove",
                    "action": function(obj) {

                        var ans = confirm('Are you sure you want to delete selected scope?');
                        if (ans == false) {
                            return;
                        }

                        // THIS IS NEEDED TO ALLOW Jquery to read child nodes 
                        AddEditScope.open_node($node);

                        $(loadSpinner).show().css('height', $(document).outerHeight());
                        AddEditScope.delete_scope_arr.push($node.id);
                        $('#' + $node.id).find('li').each(function(e) {
                            AddEditScope.delete_scope_arr.push($(this).attr('id'));
                        });

                        tree.delete_node($node);
                        AddEditScope.delete_scope_async();

                    }
                },
                "Clone_self": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Clone self",
                    "action": function(obj) {
                        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = $node.id;
                        AddEditScope.cloneScopeWithoutChild($node.id);
                    }
                },
                "Clone_with_child": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Clone with children",
                    "action": function(obj) {
                        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = $node.id;
                        AddEditScope.cloneScopeWithChild($node.id);
                    }
                },
                "Add_from_Template": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Add from Library",
                    "action": function(obj) {
                        //tree.edit($node);                        
                        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = $node.id;
                        AddEditScope.showAddFromTemplateModal();
                    }
                },
                "Add_Edit_Child": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Manage Children",
                    "action": function(obj) {
                        $('#helpModal1').find('#theIframe1').attr('src', '/apex/E2_AddNewScopeTemplate?is_Edit=true&scopegroup_id=' + scopeGrpId + '&id=' + $node.id);
                        $('.custom-new-header').html('Manage Children');
                        $('#helpModal1').find('#addupdatescopebutton').html('Update');
                        $('#helpModal1').show();
                        $('#helpModal1').find('#theIframe1').closest('div.slds-modal__content').scrollTop(0);
                        $('#helpBackdrop1').show();

                    }
                },
            "Change_Type": {
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Type</span>",
                "action": false,
                "submenu" : {
                    "Epic": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Epic</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Epic");
                                        }
                            },
                     "Story": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Story</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Story");
                                        }
                            },
                    "Component": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Component</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Component");
                                        }
                            },
                    "Capability": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Capability</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Capability");
                                        }
                            },
                }
                
            },
            "Change_Status":{
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Status</span>",
                "action": false,
                "submenu" : {
                    "Mark_Active": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Activate</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeStatus(selected_nodes_arr, true);
                        }
                    },
                    "Mark_InActive": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>De-Activate</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeStatus(selected_nodes_arr, false);
                        }
                    }
                }
            },
            "Change_Complexity":{
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Complexity</span>",
                "action": false,
                "submenu" : {
                    "Low": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Low</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'Low');
                        }
                    },
                    "Medium": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Medium</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'Medium');
                        }
                    },
                    "High": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>High</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'High');
                        }
                    }
                }
            }
        };
        
    },
    
    contextmenuForMultipleNodeSelects: function(tree, $node, selected_nodes_arr){
         return {
            "Remove": {
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Remove</span>",
                "action": function(obj) {
                    
                    var ans = confirm('Are you sure you want to delete selected scope?');
                    if (ans === false) {
                        return;
                    }
                    
                    $(loadSpinner).show().css('height', $(document).outerHeight());
                    
                    for(var indx = 0; indx < selected_nodes_arr.length; indx++){
                        //console.log(selected_nodes_arr[indx]);
                        
                        //add selected node ids in global array
                        AddEditScope.delete_scope_arr.push(selected_nodes_arr[indx]);
                        
                        var $node = $(treeId).jstree().get_node(selected_nodes_arr[indx]);
                        
                        // THIS IS NEEDED TO ALLOW Jquery to read child nodes 
                        AddEditScope.open_node($node);
                        
                        
                        // traverse all the child li elements (clild nodes to retrieve the sfdc scope ids)
                        // push each id in array to be utilzied later to delete from db
                        $('#' + $node.id).find('li').each(function(e) {
                            AddEditScope.delete_scope_arr.push($(this).attr('id'));
                        });
                        
                         // delete node and child nodes from UI  
                         tree.delete_node($node);
                    }
                    //console.log(AddEditScope.removeDuplicatesFromArray(AddEditScope.delete_scope_arr));
                    //remove duplicates from array
                    AddEditScope.delete_scope_arr = AddEditScope.removeDuplicatesFromArray(AddEditScope.delete_scope_arr);
                    // delete scope and child scopes from db
                    AddEditScope.delete_scope_async();

                }
            },
            "Change_Status":{
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Status</span>",
                "action": false,
                "submenu" : {
                    "Mark_Active": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Activate</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeStatus(selected_nodes_arr, true);
                        }
                    },
                    "Mark_InActive": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>De-Activate</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeStatus(selected_nodes_arr, false);
                        }
                    }
                }
            },
            "Change_Type": {
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Type</span>",
                "action": false,
                "submenu" : {
                    "Epic": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Epic</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Epic");
                                        }
                            },
                     "Story": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Story</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Story");
                                        }
                            },
                    "Component": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Component</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Component");
                                        }
                            },
                    "Capability": {
                                        "separator_before": false,
                                        "separator_after": false,
                                        "label": "<span style='font-weight:bold'>Capability</span>",
                                        "action": function(obj) {
                                            AddEditScope.updateScopeType(selected_nodes_arr, "Capability");
                                        }
                            },
                }
                
            },
            "Change_Complexity":{
                "separator_before": false,
                "separator_after": false,
                "label": "<span style='font-weight:bold'>Change Complexity</span>",
                "action": false,
                "submenu" : {
                    "Low": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Low</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'Low');
                        }
                    },
                    "Medium": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>Medium</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'Medium');
                        }
                    },
                    "High": {
                        "separator_before": false,
                        "separator_after": false,
                        "label": "<span style='font-weight:bold'>High</span>",
                        "action": function(obj) {
                            AddEditScope.updateScopeComplexity(selected_nodes_arr, 'High');
                        }
                    }
                }
            }
        };  
    },
    // RS : S-453054 12/12 : method create JSON 
    updateScopeComplexity : function(selected_nodes_arr, scopeComplexity) {
        $(loadSpinner).show();
        var nodes_order_json = '[';
        for(var indx = 0; indx < selected_nodes_arr.length; indx++){
            nodes_order_json += '{"scopeId":"' + selected_nodes_arr[indx] + '", "scopeComplexity":"' + scopeComplexity + '", "scopeGroupId":"' + scopeGrpId + '"},';
            var $node = $(treeId).jstree().get_node(selected_nodes_arr[indx]);
            if($node.children_d.length > 0 && $node.state.opened == false) {            
                 $.each($node.children_d, function(indx, id) {
        		    nodes_order_json += '{"scopeId":"' + id + '", "scopeComplexity":"' + scopeComplexity + '", "scopeGroupId":"' + scopeGrpId + '"},';
        	    });           
            }
        }
        nodes_order_json = nodes_order_json.slice(0, -1);
        nodes_order_json += ']';
                                            
        sforce.apex.execute("E2_Estimator_WS", "changeScopeComplexityForScopeLibrary", {
            selectedScopesJSON: nodes_order_json
        }, AddEditScope.updateScopeComplexityCallback);
    },
    updateScopeComplexityCallback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            console.log(result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                CustomAlert.showError(result);
                $(loadSpinner).hide();
                return;
            }
            result = JSON.parse(result);
            // load all the parent nodes first
            $.each(result, function(indx, scope) {
                $("#"+ scope.scopeId + "_ATTR").replaceWith( scope.formatedScopeName );
                var $node = $(treeId).jstree().get_node(scope.scopeId);
                $node.text = scope.formatedScopeName;
                //AddEditScope.reload_Scope_frameId(scope.scopeId);
                var frame_id = '#' + scope.scopeId + AddEditScope.ENDS_WITH;
                var frame_id_standard = scope.scopeId + AddEditScope.ENDS_WITH;
                  if($(frame_id).length){
                    var frameWin = document.getElementById(frame_id_standard).contentWindow;   
                    if(typeof frameWin != 'undefined' && typeof frameWin.EditScope != 'undefined' && typeof frameWin.EditScope.changeComplexityOnFly == 'function'){
                        frameWin.EditScope.changeComplexityOnFly(scope.scopeComplexity);
                    }else{
                        $(frame_id).attr("src", function(){ return $(this).attr("src")});
                    }
                  }
            });
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    updateScopeStatus : function(selected_nodes_arr, isActive) {
        $(loadSpinner).show();
        var nodes_order_json = '[';
        for(var indx = 0; indx < selected_nodes_arr.length; indx++){
            nodes_order_json += '{"scopeId":"' + selected_nodes_arr[indx] + '", "activeStatus":' + isActive + ', "scopeGroupId":"' + scopeGrpId + '"},';
            var $node = $(treeId).jstree().get_node(selected_nodes_arr[indx]);
            if($node.children_d.length > 0 && $node.state.opened == false) {            
                 $.each($node.children_d, function(indx, id) {
        		    nodes_order_json += '{"scopeId":"' + id + '", "activeStatus":' + isActive + ', "scopeGroupId":"' + scopeGrpId + '"},';
        	    });           
            }
        }
        nodes_order_json = nodes_order_json.slice(0, -1);
        nodes_order_json += ']';
                                            
        sforce.apex.execute("E2_Estimator_WS", "changeScopeActiveStatusForScopeLibrary", {
            selectedScopesJSON: nodes_order_json
        }, AddEditScope.updateScopeStatusCallback);
    },
     updateScopeStatusCallback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            console.log(result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                CustomAlert.showError(result);
                $(loadSpinner).hide();
                return;
            }
            result = JSON.parse(result);
            // load all the parent nodes first
            $.each(result, function(indx, scope) {
                $("#"+ scope.scopeId + "_ATTR").replaceWith( scope.formatedScopeName );
                var $node = $(treeId).jstree().get_node(scope.scopeId);
                $node.text = scope.formatedScopeName;
                var frame_id = '#' + scope.scopeId + AddEditScope.ENDS_WITH;
                var frame_id_standard = scope.scopeId + AddEditScope.ENDS_WITH;
                  if($(frame_id).length){
                    var frameWin = document.getElementById(frame_id_standard).contentWindow;   
                    if(typeof frameWin != 'undefined' && typeof frameWin.EditScope != 'undefined' && typeof frameWin.EditScope.changeStatusOnFly == 'function'){
                        frameWin.EditScope.changeStatusOnFly(scope.activeStatus);
                    }else{
                        $(frame_id).attr("src", function(){ return $(this).attr("src")});
                    }
                  }
            });
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    updateScopeType : function(selected_nodes_arr, scopeType) {
        $(loadSpinner).show();
        var nodes_order_json = '[';
        for(var indx = 0; indx < selected_nodes_arr.length; indx++){
            nodes_order_json += '{"scopeId":"' + selected_nodes_arr[indx] + '", "scopeType":"' + scopeType + '"},';
        }
        nodes_order_json = nodes_order_json.slice(0, -1);
        nodes_order_json += ']';
                                            
        sforce.apex.execute("E2_Estimator_WS", "changeScopeType", {
            selectedScopesJSON: nodes_order_json
        }, AddEditScope.updateScopeTypeCallback);
    },
    updateScopeTypeCallback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            console.log(result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                CustomAlert.showError(result);
                $(loadSpinner).hide();
                return;
            }
            result = JSON.parse(result);
            // load all the parent nodes first
            $.each(result, function(indx, scope) {
                var frame_id = '#' + scope.scopeId + AddEditScope.ENDS_WITH;
                var frame_id_standard = scope.scopeId + AddEditScope.ENDS_WITH;
                  if($(frame_id).length){
                    var frameWin = document.getElementById(frame_id_standard).contentWindow;   
                    if(typeof frameWin != 'undefined' && typeof frameWin.EditScope != 'undefined' && typeof frameWin.EditScope.changeTypeOnFly == 'function'){
                        frameWin.EditScope.changeTypeOnFly(scope.scopeType);
                    }else{
                        $(frame_id).attr("src", function(){ return $(this).attr("src")});
                    }
                  }
            });
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    addEffortMultiplier : function(scopeId, multiplier) {
        if(multiplier == '') {
             multiplier = 0;
        }
        $(loadSpinner).show();
        var nodes_order_json = '[';
        if(typeof scopeId != 'undefined' && scopeId != '') {
            var $node = $(treeId).jstree().get_node(scopeId);
            console.log($node);
            if(typeof $node != 'undefined' && typeof $node != undefined && $node.children_d.length > 0) {            
                 $.each($node.children_d, function(indx, id) {
        		    nodes_order_json += '{"scopeId":"' + id + '",  "multiplier":"' + multiplier + '", "scopeGroupId":"' + scopeGrpId + '"},';
        	    });           
            }
        }
        if(nodes_order_json != '[') {
            nodes_order_json = nodes_order_json.slice(0, -1);
            nodes_order_json += ']';
            sforce.apex.execute("E2_Estimator_WS", "addEffortMultiplierOnScopeGroup", {
                selectedScopesJSON: nodes_order_json
            }, AddEditScope.addEffortMultiplier_Callback);
        } else {
          $(loadSpinner).hide();  
        }
    },
     addEffortMultiplier_Callback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            //console.log(result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                CustomAlert.showError(result);
                $(loadSpinner).hide();
                return;
            }
            AddEditScope.addEffortMultiplier_Success(result);
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    addEffortMultiplierOnReprent : function(parentScopeId, childScopeId) {
        var $node = $(treeId).jstree().get_node(parentScopeId);
        if(typeof $node != 'undefined' && typeof $node.original != 'undefined') {
            var multiplier = $node.original.multiplier == null || $node.original.multiplier == '' ? 1 :$node.original.multiplier; 
            var nodes_order_json = '[';
            nodes_order_json += '{"scopeId":"' + childScopeId + '", "multiplier":"' + multiplier + '", "scopeGroupId":"' + scopeGrpId + '"},';
            var $childScope = $(treeId).jstree().get_node(childScopeId);
            if($childScope.children_d.length > 0) {            
                $.each($childScope.children_d, function(indx, id) {
                    nodes_order_json += '{"scopeId":"' + id + '",  "multiplier":"' + multiplier + '", "scopeGroupId":"' + scopeGrpId + '"},';
                });           
            }
            if(nodes_order_json != '[') {
                nodes_order_json = nodes_order_json.slice(0, -1);
                nodes_order_json += ']';
                sforce.apex.execute("E2_Estimator_WS", "addEffortMultiplierOnScopeGroup", {
                    selectedScopesJSON: nodes_order_json
                }, AddEditScope.addEffortMultiplierOnReprent_callback);
            }
        }
    },
    addEffortMultiplierOnReprent_callback : {
      onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            //console.log(result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                CustomAlert.showError(result);
                $(loadSpinner).hide();
                return;
            }
            AddEditScope.addEffortMultiplier_Success(result);
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }  
    },
    addEffortMultiplier_Success : function(result) {
        result = JSON.parse(result);
        // load all the parent nodes first
        $.each(result, function(indx, scope) {
            $("#"+ scope.scopeId + "_ATTR").replaceWith( scope.formatedScopeName );
            var $node = $(treeId).jstree().get_node(scope.scopeId);
            $node.text = scope.formatedScopeName;
            if(typeof $node.original != 'undefined' && typeof $node.original.multiplier != 'undefined') {
                $node.original.multiplier = scope.multiplier;
                var frame_id = '#' + scope.scopeId + AddEditScope.ENDS_WITH;
                var frame_id_standard = scope.scopeId + AddEditScope.ENDS_WITH;
                if($(frame_id).length){
                    var frameWin = document.getElementById(frame_id_standard).contentWindow;   
                    if(typeof frameWin != 'undefined' && typeof frameWin.EditScope != 'undefined' && typeof frameWin.EditScope.updateEffortMultiplier == 'function'){
                        frameWin.EditScope.updateEffortMultiplier(scope.multiplier);
                    }else{
                        $(frame_id).attr("src", function(){ return $(this).attr("src")});
                    }
                }
            }
        });
    },
    
    bindSelect_NodeEvent: function(){
        
        //EVENT: JSTREE NODE BEING SELECTED
        $(treeId).bind("select_node.jstree", function (e, data) {
              var selected_nodes_arr = $( treeId + ' li.jstree-node').
                      filter(function() { return $(this).children('a.jstree-anchor.jstree-clicked').length != 0; }).
                      map(function() { return this.id; }).get();
                      
              //RJ: 09/12: Ensure that detail only gets loaded when there is only one
              //           node selected; if multiple nodes are selected
              //           we need not to load all the selected scopes detail screens
              if(selected_nodes_arr.length === 1){
                
                global_scopeId = data.node.id;
                AddEditScope.edit_node(data.node, data.parent);   
              }
        });
        
    },
    reload_Scope_frameId : function(scope) {
            var frame_id = '#' + scope + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
    },
    // RS 11/22: S-452962 : method re-initiate JStree on cloning scope, 
    // add new scope or add from template. This method get all open nodes
    // in jstree in OPEN_NODES as array
    re_init_tree : function() {
        AddEditScope.OPEN_NODES = $(treeId).jstree(true).get_state()['core']['open'];
        $(treeId).jstree('destroy');
        $(treeId).jstree(jstree_options);
        AddEditScope.tree_init();
    },
    reload_Scope_frame : function(result) {
        $.each(result, function(indx, scope) {
            var frame_id = '#' + scope + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
        });
    },
    edit_node : function(node, parent){
	   var endsWith = AddEditScope.ENDS_WITH;
	   var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
	   var frame_id = '#' + node.id + endsWith;
	   var frame_id_standard = node.id + endsWith;
	   if($(containerId).length){
		   $(containerId).find("iframe[id$='" + endsWith + "']").not(frame_id).hide("slow", function() {
		   });
		   if($(frame_id).length){
		       if($(frame_id).is(':visible')){
		           var doc = $(document.getElementById(frame_id_standard).contentWindow.document);
		           $(frame_id).css({ height:'400px',width:'100%',margin:'0px'});
		       }else{
    			   $(frame_id).show("slow", function() {
    				   if($(this).height() == 0){
    				     $(this).css({height:'400px',width:'100%',margin:'0px'})
    				   }
    			   });	
		       }
		   }else{
			   $('<iframe>', {
				   src: '/apex/E2_EditScopeTemplate?scopegroup_id=' + scopeGrpId + '&id=' + node.id,
				   id:  node.id + endsWith,
				   name: node.id + endsWith,
				   frameborder: 0,
				   scrolling: 'no',
				   style : 'height:400px;width:100%;margin:0px',
				   class : 'slds-card'
				   }).appendTo(containerId);			   
		   }
		   
	   }
	   
    },
    create_node: function(node, position) {
        node.state = JSON.parse(node.state);
        // jstree api call to create the tree node.
        $(treeId).jstree(AddEditScope.CREATE_NODE, node.parent, node, position);
    },
    open_node: function(node) {
        // jstree api call to open current node.
        $(treeId).jstree(AddEditScope.OPEN_NODE, node);
    },
    delete_call_register: {},

    delete_scope_arr: [],

    delete_scope_async: function() {
        if (AddEditScope.delete_scope_arr.length > 0) {
            var scopeid_delete = AddEditScope.delete_scope_arr.pop();
            var frame_id = '#' + scopeid_delete + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).remove(); 
            sforce.apex.execute("E2_Estimator_WS", "deleteScope", {
                scopeId: scopeid_delete,
                parentId: '#'
            }, AddEditScope.delete_scope_asyncCallback);
        } else {
            $(loadSpinner).show().css('height', $(document).outerHeight());
            //to refresh scope loe we need to reload jstree
            AddEditScope.GLOBAL_SCOPEID = null;
            AddEditScope.re_init_tree();
            CustomAlert.show('Scope have been removed successfully!!!');
        }
    },
    delete_scope_asyncCallback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result); 
            //if (result[0].indexOf("Failed") != -1) {
            //    CustomAlert.showError(result[0]);
            //    $(loadSpinner).hide();
            //    AddEditScope.delete_scope_arr = [];
            //    return;
            //} 
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Remove Failed: You do not have permission to remove this scope!!! Please contact scope owner for remove!!');    
                }else{
                  alert(result);
                }
                // call the tree_init back to get the deleted node
                AddEditScope.re_init_tree();
                return;
            }
            AddEditScope.delete_scope_async();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }

    },
    delete_scope: function(scopeId, parentId) {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.delete_call_register[scopeId] = parentId;
        sforce.apex.execute("E2_Estimator_WS", "deleteScope", {
            scopeId: scopeId,
            parentId: parentId
        }, AddEditScope.delete_scopeCallback);
    },
    delete_scopeCallback: {
        onSuccess: function(result) {

            if (result.indexOf('Fail') != -1) {
                alert(result);
                $(loadSpinner).hide();
                for (var prop in AddEditScope.delete_call_register) {
                    delete AddEditScope.delete_call_register[prop];
                }
                // call the tree_init back to get the deleted node
                AddEditScope.re_init_tree();
                return;
            }
            if (AddEditScope.delete_call_register && AddEditScope.delete_call_register[result]) delete AddEditScope.delete_call_register[result];
            if (AddEditScope.delete_call_register && JSON.stringify(AddEditScope.delete_call_register) == '{}') {
                $(loadSpinner).hide();
                //CustomAlert.show('Scope(s) have been removed successfully!!!');
                AddEditScope.re_init_tree();
                CustomAlert.show('Scope have been removed successfully!!!');
            }
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }

    },
    reparent_call_register: {},
    reparent_scope: function(scopeId, parentId) {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.reparent_call_register[scopeId] = parentId;
        sforce.apex.execute("E2_Estimator_WS", "reparentScope", {
            scopeId: scopeId,
            parentId: parentId
        }, AddEditScope.reparent_scopeCallback);
    },
    reparent_scopeCallback: {
        onSuccess: function(result) {
            if (result.indexOf('Fail') != -1) {
                alert(result);
                $(loadSpinner).hide();
                // call the tree_init back to get the deleted node
                AddEditScope.re_init_tree();
                return;
            }
            // if there is no failure; delete respective call registers
            if (AddEditScope.reparent_call_register && AddEditScope.reparent_call_register[result]) {
                AddEditScope.addEffortMultiplierOnReprent(AddEditScope.reparent_call_register[result], result); 
                delete AddEditScope.reparent_call_register[result];
            }
            if (AddEditScope.reparent_call_register && JSON.stringify(AddEditScope.reparent_call_register) == '{}') {
                 // WHEN REPARENTING - EDIT SCOPE SCREEN NEED TO BE RELOADED WITH NEW PARENT
                var frame_id = '#' + result + AddEditScope.ENDS_WITH;
                if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
                
                //to refresh scope loe we need to reload jstree
                global_scopeId = result;
                
                AddEditScope.updateScopeDisplayOrder();
            }
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    
    updateScopeDisplayOrder : function(){
        //to handle the re-ordering of scopes (vikash goyal 7/15/2016)
        // create a json of new order of scopes in the tree hierarchy and send this json to the 
        // controller to update the position of all the scopes in the tree.
        var nodes_order_json = '[';
        
        $($(treeId).jstree(true).get_json('#', {flat:true})).each(function(index, value){
            var position = $.inArray(value.id, $(treeId).jstree().get_node(value.parent).children);
            nodes_order_json += '{"scopeId":"' + value.id + '", "displayOrder":"' + position + '", "sequence":"' + index + '"},';
        });
        
        nodes_order_json = nodes_order_json.slice(0, -1);
        nodes_order_json += ']';
        
        // invoke the webservice to update scopes display order 
        sforce.apex.execute("E2_Estimator_WS", "updateScopesDisplayOrder", {
                scopeJsonStr: nodes_order_json
                }, AddEditScope.updateScopeDisplayOrderCallback);
    },
    
    updateScopeDisplayOrderCallback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Re-ordering Failed: You do not have permission to re-order this scope!!! Please contact scope owner!!');    
                }else{
                  alert(result);
                }
                $(loadSpinner).hide();
                    
                // call the tree_init back to get the deleted node
                AddEditScope.re_init_tree();
                return;
            }
            if(AddEditScope.UPDATE_DISPLAY_ORDER == true) {
                AddEditScope.UPDATE_DISPLAY_ORDER = false;
                CustomAlert.show('Scope have been cloned successfully!!!');
            } else {
                CustomAlert.show('Scope have been re-parented successfully!!!');
            }
            
            
            $(loadSpinner).show().css('height', $(document).outerHeight());
            AddEditScope.re_init_tree();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    tree_init: function() {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        sforce.apex.execute("E2_Estimator_WS", "retrieveAllScopeTreeNodesOnScopeGroup", {
            scopeGrpId: scopeGrpId
        }, AddEditScope.tree_init_callback);
    },
    /*sort_order: function(data) {
        var list = {};
        var newlist = [];
        var keys = [];
        for (var i = 0; i < data.length; i++) {
            list[data[i].id] = data[i];
            keys[i] = data[i].id;
        }

        for (var j = keys.length - 1; j >= 0; j--) {
            if (list[keys[j]]) var parent = list[keys[j]].parent;

            if (parent == '#' || typeof list[parent] == 'undefined') {
                console.log(list[keys[j]].id + ':' + list[keys[j]].parent);
                newlist.push(list[keys[j]]);
                delete list[keys[j]];
                keys.splice(j, 1);

                j = keys.length;
            }
        }
        return newlist;
    },*/
    sort_order_new : function(data){
        var newList = [];
        var map = {};
        
        // load all the parent nodes first
        for(var indx = data.length - 1; indx >= 0 ; indx--){
          var node = data[indx];
          if(node.parent == '#') {     
        	 newList.push(node);
        	 map[node.id] = node;
        	 data.splice(indx, 1);
          }	 
        }
        // sort the list to set the sort order of parent nodes
        newList.sort(function(a,b) {return (parseInt(a.display_order) > parseInt(b.display_order)) ? 1 : ((parseInt(b.display_order) > parseInt(a.display_order)) ? -1 : 0);} ); 
        // re-iterate the list for child and sub-child; 
        /// load in the order of hierarchy.
        while(data.length > 0){
          var intermediateList = [];
          // traverse the data 
          for(var i_indx = data.length - 1; i_indx >= 0 ; i_indx--){
             var node = data[i_indx];
        	 if(typeof map[node.parent] != 'undefined'){
        	    intermediateList.push(node);
                data.splice(i_indx, 1);		
        	 }
          }  
          // sort the list to sort the sort order of intermediate list
          intermediateList.sort(function(a,b) {return (parseInt(a.display_order) > parseInt(b.display_order)) ? 1 : ((parseInt(b.display_order) > parseInt(a.display_order)) ? -1 : 0);} ); 
          for(var j_indx = 0; j_indx <= intermediateList.length - 1 ; j_indx++){  
             var node = intermediateList[j_indx];  
             newList.push(node);
        	 map[node.id] = node;
          }
          // clear the array
          intermediateList = [];
        }
        return newList;
    },

    tree_init_callback: {
        onSuccess: function(result) {
            // sort the result to move all the parents up in the list which is very required to load
            // all the child records aligned.
            //doesnt work: result.sort(function(a,b) {return (a.parent > b.parent) ? 1 : ((b.parent > a.parent) ? -1 : 0);} ); 
            result = AddEditScope.sort_order_new(result);
            $.each(result, function(indx, node) {
                console.log('MI::::' + node.title + '-' + node.display_order);
                AddEditScope.create_node(node, parseInt(node.display_order));
                if(AddEditScope.OPEN_NODES && AddEditScope.OPEN_NODES.indexOf(node.id) == -1) {
                    $(treeId).jstree(true).close_node(node);
                }
            });
            bindEvents();
            
            if(AddEditScope.SAVED_SCOPE_ID != null){
              $(treeId).jstree(true).select_node(AddEditScope.SAVED_SCOPE_ID);
        	  CustomAlert.show('Scope: ' + AddEditScope.SAVED_SCOPE_NAME  + ' have been saved successfully!!!');
        	  AddEditScope.SAVED_SCOPE_ID = null;
        	  AddEditScope.SAVED_SCOPE_NAME = null;
            }else if(AddEditScope.SAVED_SCOPE_ID == null && AddEditScope.GLOBAL_SCOPEID != null && AddEditScope.GLOBAL_SCOPEID != ''){
                if($('#' + AddEditScope.GLOBAL_SCOPEID).length){
                  $(treeId).jstree(true).select_node(AddEditScope.GLOBAL_SCOPEID);
                  AddEditScope.edit_node({"id":AddEditScope.GLOBAL_SCOPEID}, {"id":""});
                }
            }
            if(AddEditScope.UPDATE_DISPLAY_ORDER == true) {
                AddEditScope.UPDATE_DISPLAY_ORDER = false;
                // set the display order and sequence back in the database
                AddEditScope.updateScopeDisplayOrderOnClone();
            } else {
                $(loadSpinner).hide();
            }
            AddEditScope.OPEN_NODES = null;
        },
        onFailure: function(error) {
            alert(error);
        }
    },
    /*addScopeTemplate_RecurringCallBack: {
        onSuccess: function(result) {
            var hasChildren = false;
            if (result.length > 0) {
                var scope_id = result[0].scope_id;
                if (result[0].nodeList && result[0].nodeList.length) {
                    $.each(result[0].nodeList, function(indx, node) {
                        AddEditScope.create_node(node, AddEditScope.LAST);
                        if (node.hasChildren == true || node.hasChildren == 'true') {
                            hasChildren = true;
                            AddEditScope.addscopetemplate_call_register[node.id] = scope_id;
                            AddEditScope.addScopeTemplate_Recurring(node.id, node.sourceId);
                        }
                    });
                } else if (result[0].nodeList) {
                    var node = result[0].nodeList;
                    AddEditScope.create_node(node, AddEditScope.LAST);
                    if (node.hasChildren == true || node.hasChildren == 'true') {
                        hasChildren = true;
                        AddEditScope.addscopetemplate_call_register[node.id] = scope_id;
                        AddEditScope.addScopeTemplate_Recurring(node.id, node.sourceId);
                    }
                }
                if (AddEditScope.addscopetemplate_call_register && AddEditScope.addscopetemplate_call_register[scope_id]) delete AddEditScope.addscopetemplate_call_register[scope_id];
                if (AddEditScope.addscopetemplate_call_register && JSON.stringify(AddEditScope.addscopetemplate_call_register) == '{}') {
                    //to refresh scope loe we need to reload jstree
                    $(treeId).jstree('destroy');
                    $(treeId).jstree(jstree_options);
                    AddEditScope.tree_init();
                    // End
                    $(loadSpinner).hide();
                    CustomAlert.show('Scope has been cloned successfully!!!');
                }
            } else {
                $(loadSpinner).hide();
            }
            //if(!hasChildren) $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },

    addScopeTemplate_Recurring: function(parentId, sourceId) {
        //$(loadSpinner).show().css('height', $(document).outerHeight());                   
        sforce.apex.execute("E2_Estimator_WS", "getChildCloneNodesTemplate", {
            parentId: parentId,
            sourceId: sourceId,
            scopeGrpId: scopeGrpId
        }, AddEditScope.addScopeTemplate_RecurringCallBack);
    },

    addscopetemplate_call_register: {},
*/
    addScopeTemplate_initCallBack: {
        onSuccess: function(result) {
            var hasChildren = false;
            if (result.length > 0) {
                var sibling = null;
                if(AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != null && AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != '')
                sibling = $(treeId).jstree(true).get_node(AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
               result = AddEditScope.sort_cloned_scopes(result);
               $.each(result, function(indx, node) {
                
                var display_order = parseInt(node.display_order);
                var parent = node.parent;
                if((sibling == null && node.parent == "#") || (sibling != null  && node.parent == sibling.id)) {
                    node.state = JSON.parse(node.state);
                    var display_order = "after";
                    var parent = AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID;
                    // jstree api call to create the tree node.
                    $(treeId).jstree(AddEditScope.CREATE_NODE, parent, node, display_order);
                }
               });
               $.each(result, function(indx, node) {
                if((sibling == null && node.parent != "#") || (sibling != null  && node.parent != sibling.id)) {
                    node.state = JSON.parse(node.state);
                    var display_order = parseInt(node.display_order);
                    var parent = node.parent;
                    // jstree api call to create the tree node.
                    $(treeId).jstree(AddEditScope.CREATE_NODE, parent, node, display_order);
                }
               });
               AddEditScope.UPDATE_DISPLAY_ORDER = true;
               AddEditScope.updateScopeDisplayOrder();
               AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = '';
               result = null;
            } else {
                $(loadSpinner).hide();
            }

        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },

    addScopeTemplate_init: function(scopeId) {
        //AddEditScope.addscopetemplate_call_register[scopeId] = '#';
        sforce.apex.execute("E2_Estimator_WS", "getClonedNodesTemplate", {
            scopeId: scopeId,
            scopeGrpId: scopeGrpId,
            parentScopeId: '#'
        }, AddEditScope.addScopeTemplate_initCallBack);
    },

    addScopeTemplateWithParent_init: function(scopeId, parentScopeId) {
        //AddEditScope.addscopetemplate_call_register[scopeId] = parentScopeId;
        sforce.apex.execute("E2_Estimator_WS", "getClonedNodesTemplate", {
            scopeId: scopeId,
            scopeGrpId: scopeGrpId,
            parentScopeId: parentScopeId
        }, AddEditScope.addScopeTemplate_initCallBack);
    },

    addScopeTemplate: function() {
        var selectedIds = document.getElementById(AddEditScope.SELECT_TEMPLATE_IFRAME_ID).contentWindow.getselectedScopeIdsArray();

        if (selectedIds.length == 0) {
            alert('No Scope being selected for Add');
            return;
        }

        /*var ans = confirm('Are you sure you want to add selected scope(s)/Template(s)?');
        if (ans == false) {
            return;
        }*/

        var result = selectedIds;
        //var result = ['a5wR00000004EdD', 'a5wR0000000Ce2Q', 'a5wR0000000Cdg0'];
        if (AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID && AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != null) {
            $(loadSpinner).show().css('height', $(document).outerHeight());
            AddEditScope.addScopeTemplateWithParent_init(result.toString(), AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
            /*$.each(result, function(indx, node) {
                $(loadSpinner).show().css('height', $(document).outerHeight());
                AddEditScope.addScopeTemplateWithParent_init(node, AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
            });*/
        } else {
            $(loadSpinner).show().css('height', $(document).outerHeight());
            AddEditScope.addScopeTemplate_init(result.toString());
            /*$.each(result, function(indx, node) {
                $(loadSpinner).show().css('height', $(document).outerHeight());
                AddEditScope.addScopeTemplate_init(node);
            });*/
        }
        AddEditScope.hideAddFromTemplateModal();
    },

    addNewScope: function() {
        var func = document.getElementById(AddEditScope.SELECT_ADD_NEW_FRAME_ID).contentWindow.addUpdateScopes;
        if (typeof func != 'undefined') {
            AddEditScope.UPDATE_DISPLAY_ORDER = true;
            func();
        }
    },

    editScope: function() {
        var func = document.getElementById(AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).contentWindow.addUpdateScopes;
        if (typeof func != 'undefined') {
            func();
        }
    },

    closeAddNewModelPopup: function() {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.re_init_tree();
        AddEditScope.hideAddNewModal();
        CustomAlert.show('Scope have been added successfully!!!');
    },

    closeEditScopeModelPopup: function() {
        /**$(treeId).jstree('destroy');
        $(treeId).jstree(jstree_options);
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
        AddEditScope.hideEditScopeModal();
        CustomAlert.show('Scope(s) have been edited successfully!!!');
        **/
    },
    updateChildScopeOnParentScopeEdit: function(scope_id, scope_name, changeComplexity, scopeToActivate, scopeToDeactivate) {
        AddEditScope.SAVED_SCOPE_ID = scope_id;
        AddEditScope.SAVED_SCOPE_NAME = scope_name;
        var allChildScopes = [];
        var $node = $(treeId).jstree().get_node(scope_id);
		$.each($node.children_d, function(indx, id) {
		    var $childnode = $(treeId).jstree().get_node(id);
		    allChildScopes.push($childnode.original.id);
		 });
		 var scopesString = allChildScopes.toString();
		 if(scopesString != '' && (changeComplexity != '' || scopeToActivate != '' || scopeToDeactivate != '')) {
		     $(loadSpinner).show();
		     sforce.apex.execute("E2_Estimator_WS", "updateScopesStatus", {
                complexity: changeComplexity,
                scopeToActivate: scopeToActivate,
                scopeToDeactivate: scopeToDeactivate,
                allscopesIds : scopesString
            }, AddEditScope.scopesUpdatedCallback);
		 } else {
		     AddEditScope.showSaveSuccessMessage(scope_id, scope_name);
		 }
    },
    scopesUpdatedCallback: {
        onSuccess: function(result) {
            if (result.length > 0) {
                    $(loadSpinner).show().css('height', $(document).outerHeight());
                    AddEditScope.re_init_tree();
                    // End
                    $(loadSpinner).hide();
                    CustomAlert.show('Scopes has been successfully updated!!!');
            } else {
                $(loadSpinner).hide();
            }

        },
        onFailure: function(error) {
            console.log(error);
            $(loadSpinner).hide();
        }
    },
    showSaveSuccessMessage: function(scope_id, scope_name){
    	AddEditScope.SAVED_SCOPE_ID = scope_id;
        AddEditScope.SAVED_SCOPE_NAME = scope_name;
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.re_init_tree();
    },

    showAddNewModal: function() {
        $('#helpModal1').show();
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).attr('src', '/apex/E2_AddNewScopeTemplate?is_New=true&scopegroup_id=' + scopeGrpId);
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('.custom-new-header').html('Add New Scope');
        $('#helpModal1').find('#addupdatescopebutton').html('Save');
        $('#helpBackdrop1').show();
    },

    showAddFromTemplateModal: function() {
        $('#helpModal').show();
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).attr('src', '/apex/E2_SelectScopeTemplateTmpmgr');
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop').show();

    },

    hideAddNewModal: function() {
        $('#helpModal1').hide();
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).attr('src', 'about:blank');
        //$('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).css('height', 200);
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop1').hide();
    },

    hideAddFromTemplateModal: function() {
        $('#helpModal').hide();
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).attr('src', 'about:blank');
        //$('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).css('height', 200);
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop').hide();
    },

    hideEditScopeModal: function() {
        $('#helpModal2').hide();
        $('#helpModal2').find('#' + AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).attr('src', 'about:blank');
        //$('#helpModal2').find('#' + AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).css('height', 200);
        $('#helpModal2').find('#' + AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop2').hide();

    },

    addnew_click: function(obj) {
        AddEditScope.showAddNewModal();
        return false;
    },

    addfromtemplate_click: function(obj) {
        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = null;
        AddEditScope.showAddFromTemplateModal();
        return false;
    },

    setHeightOfAddNewModal: function(height) {

        if ($('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).length) {
            $('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).css('height', height + 'px');
        }
    },
    setHeightOfAddNewTemplateModal: function(height) {

        if ($('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).length) {
            $('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).css('height', height + 'px');
        }
    },

    setHeightOfEditScopeModal: function(height) {
        if ($('#' + AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).length) {
            $('#' + AddEditScope.SELECT_EDIT_SCOPE_FRAME_ID).css('height', height + 'px');
        }
    },
    
    setHeightOfEditScopeFrame : function(height, frameid){
    	
    	if ($('#' + frameid).length) {
            $('#' + frameid).css('height', height + 'px');
        }    	
    },
    
    reload_frame : function(url, frameid){
    	if ($('#' + frameid).length) {
            $('#' + frameid).attr('src', url);
        }
    },
    sort_cloned_scopes : function(data) {
        var sibling = null;
        if(AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != null && AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != '')
        sibling = $(treeId).jstree(true).get_node(AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
        var newList = [];
        var map = {};
         // load all the parent nodes first
         for(var indx = data.length - 1; indx >= 0 ; indx--){
          var node = data[indx];
          if((sibling == null && node.parent == "#") || (sibling != null && (node.parent == sibling.parent || node.id == sibling.id  || node.parent == sibling.id))) {     
            newList.push(node);
            map[node.id] = node;
            data.splice(indx, 1);
          }	 
         }
         // sort the list to set the sort order of parent nodes
         newList.sort(function(a,b) {return (parseInt(a.display_order) > parseInt(b.display_order)) ? 1 : ((parseInt(b.display_order) > parseInt(a.display_order)) ? -1 : 0);} ); 
         // re-iterate the list for child and sub-child; 
         /// load in the order of hierarchy.
         while(data.length > 0){
          var intermediateList = [];
          // traverse the data 
          for(var i_indx = data.length - 1; i_indx >= 0 ; i_indx--){
        	var node = data[i_indx];
            if(typeof map[node.parent] != 'undefined'){
        		intermediateList.push(node);
        		data.splice(i_indx, 1);		
        	}
          }  
          // sort the list to sort the sort order of intermediate list
          intermediateList.sort(function(a,b) {return (parseInt(a.display_order) > parseInt(b.display_order)) ? 1 : ((parseInt(b.display_order) > parseInt(a.display_order)) ? -1 : 0);} ); 
          for(var j_indx = 0; j_indx <= intermediateList.length - 1 ; j_indx++){  
           var node = intermediateList[j_indx];  
           newList.push(node);
           map[node.id] = node;
         }
         // clear the array
         intermediateList = [];
         }  
         return newList;
    },
    cloneScopeWithoutChild : function(nodeId) {
        $(loadSpinner).show();
        var $selectedNode = $(treeId).jstree(true).get_node(nodeId);
        var arr = [];
        arr.push($selectedNode.original.id);
        AddEditScope.cloneScopeWithChild_init(arr.toString());
    },
    cloneScopeWithChild : function(nodeId) {
        $(loadSpinner).show();
        var $selectedNode = $(treeId).jstree(true).get_node(nodeId);
        var arr = [];
        arr.push($selectedNode.original.id);
        $.each($selectedNode.children_d, function(indx, id) {
            var $childnode = $(treeId).jstree(true).get_node(id);
            arr.push($childnode.original.id);
        });
        AddEditScope.cloneScopeWithChild_init(arr.toString());
    },
    cloneScopeWithChild_init: function(scopeIds) {
        sforce.apex.execute("E2_Estimator_WS", "cloneScopeWithChild", {
            scopeIdCSV: scopeIds
        }, AddEditScope.cloneScopeWithChild_initCallBack);
    },
    cloneScopeWithChild_initCallBack: {
        onSuccess: function(result) {
           if (result.length > 0) {    
               var sibling = $(treeId).jstree(true).get_node(AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
               
               result = AddEditScope.sort_cloned_scopes(result);
               $.each(result, function(indx, node) {
                var display_order = parseInt(node.display_order);
                var parent = node.parent;
                if(node.parent == sibling.parent) {
                    node.state = JSON.parse(node.state);
                    var display_order = "after";
                    var parent = AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID;
                    // jstree api call to create the tree node.
                    $(treeId).jstree(AddEditScope.CREATE_NODE, parent, node, display_order);
                }
               });
               $.each(result, function(indx, node) {
                if(node.parent != sibling.parent) {
                    node.state = JSON.parse(node.state);
                    var display_order = parseInt(node.display_order);
                    var parent = node.parent;
                    // jstree api call to create the tree node.
                    $(treeId).jstree(AddEditScope.CREATE_NODE, parent, node, display_order);
                }
               });
               AddEditScope.UPDATE_DISPLAY_ORDER = true;
               AddEditScope.updateScopeDisplayOrder();
               AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = '';
               result = null;
           } else {
                $(loadSpinner).hide();
           }
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    updateScopeDisplayOrderOnClone : function(){
        //to handle the re-ordering of scopes (vikash goyal 7/15/2016)
        // create a json of new order of scopes in the tree hierarchy and send this json to the 
        // controller to update the position of all the scopes in the tree.
        var nodes_order_json = '[';
        
        $($(treeId).jstree(true).get_json('#', {flat:true})).each(function(index, value){
            var position = $.inArray(value.id, $(treeId).jstree().get_node(value.parent).children);
            nodes_order_json += '{"scopeId":"' + value.id + '", "displayOrder":"' + position + '", "sequence":"' + index + '"},';
        });
        
        nodes_order_json = nodes_order_json.slice(0, -1);
        nodes_order_json += ']';
        
        // invoke the webservice to update scopes display order 
        sforce.apex.execute("E2_Estimator_WS", "updateScopesDisplayOrder", {
                scopeJsonStr: nodes_order_json
                }, AddEditScope.updateScopeDisplayOrderOnCloneCallback);
    },
    
    updateScopeDisplayOrderOnCloneCallback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                $(loadSpinner).hide();
                return;
            }
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    }

}




function showHelpModal() {
    $('#helpModal').show();
    $('#helpBackdrop').show();
    $(document).keyup(escapeHandler);
    return false;
}

function showHelpModal1() {
    $('#helpModal1').show();
    $('#helpModal1').find('#theIframe1').attr('src', '/apex/E2_AddNewScope?is_New=true&estimate_id=' + estimateId);
    $('#helpBackdrop1').show();
    $(document).keyup(escapeHandler);
    return false;
}



function escapeHandler(e) {
    if (e.keyCode == 27) closeHelpModal();
    return false;
}

function escapeHandler1(e) {
    if (e.keyCode == 27) closeHelpModal1();
    return false;
}

function closeHelpModal() {
    $('#helpModal').hide();
    $('#helpBackdrop').hide();
    $(document).unbind('keyup', escapeHandler);
    return false;
}

function closeHelpModal1() {
    $('#helpModal1').hide();
    $('#helpBackdrop1').hide();
    $(document).unbind('keyup', escapeHandler1);
    return false;
}

function closeHelpModal2() {
    $('#helpModal2').hide();
    $('#helpBackdrop2').hide();
    return false;
}

function hideSpinner() {
    $('#loadingSpinner').hide();
    return false;
}