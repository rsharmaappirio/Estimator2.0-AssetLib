var CustomAlert = {
    notifyContainerCssSelector: '.slds-notify_container',
    notifyCloseCssSelector: '.slds-notify__close',
    notifyMsgCssSelector: '.slds-text-heading--small',
    show: function(msg) {
        $(CustomAlert.notifyContainerCssSelector).css({
            position: 'absolute !important',
            'opacity': '100',
            'display': 'block'
        });
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
        "multiple": false
    },
    'checkbox': {
        'three_state': false,
        'cascade': ''
    },
    "contextmenu": {
    	"select_node" : false,
        "items": function($node) {
            var tree = $(treeId).jstree(true);
            return {
                "Add_Edit_Child": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Manage child scope(s)",
                    "action": function(obj) {
                        $('#helpModal1').find('#theIframe1').attr('src', '/apex/E2_AddNewScope?is_Edit=true&estimate_id=' + estimateId + '&id=' + $node.id);
                        $('#helpModal1').find('#addupdatescopebutton').html('Update');
                        $('#helpModal1').show();
                        $('#helpModal1').find('#theIframe1').closest('div.slds-modal__content').scrollTop(0);
                        $('#helpBackdrop1').show();

                    }
                },
                "Add_from_Template": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Add scope template(s)",
                    "action": function(obj) {
                        //tree.edit($node);                        
                        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = $node.id;
                        AddEditScope.showAddFromTemplateModal();
                    }
                },
                "Remove": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Remove",
                    "action": function(obj) {

                        var ans = confirm('Are you sure you want to delete selected scope(s)?');
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
                }
            };
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


    
    var element = $('#edit_scope_div'),
        originalY = element.offset().top;

    // Space between element and top of screen (when scrolling)
    var topMargin = -20;

    // Should probably be set in CSS; but here just for emphasis
    element.css('position', 'relative');

    $(window).on('scroll', function(event) {
        if ($(this).width() > 767) {
            var scrollTop = $(window).scrollTop();
    
            element.stop(false, false).animate({
                top: scrollTop < originalY
                        ? 0
                        : scrollTop - originalY + topMargin
            }, 300);
        }
    });    
    
    $( window ).resize(function() {
         //alert('window resize');
         if ($(this).width() < 767) {
            var element = $('#edit_scope_div');
            element.css({'position': 'static', 'top' : 0});
            
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
    $(treeId).bind("select_node.jstree", function (e, data) {
        if(data && data.event && data.event.button != 2) {
        	AddEditScope.edit_node(data.node, data.parent);           
        }
        
    });
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
    edit_node : function(node, parent){
	   var endsWith = AddEditScope.ENDS_WITH;
	   var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
	   var frame_id = '#' + node.id + endsWith;
	   if($(containerId).length){
		   $(containerId).find("iframe[id$='" + endsWith + "']").hide("slow", function() {});
		   
		   if($(frame_id).length){
			   $(frame_id).show("slow", function() {
				   if($(this).height() == 0){
				     $(this).css({height:'400px',width:'100%',margin:'0px'})
				   }
			   });			   
		   }else{
			   $('<iframe>', {
				   src: '/apex/E2_EditScope?estimate_id=' + estimateId + '&id=' + node.id,
				   id:  node.id + endsWith,
				   name: node.id + endsWith,
				   frameborder: 0,
				   scrolling: 'no',
				   style : 'height:600px;width:100%;margin:0px',
				   class : 'slds-card'
				   }).appendTo(containerId);			   
		   }
		   
	   }
	   
	   /**
	   var container = $(containerId),
            scrollTo = $('#' + node.id);
        //alert(scrollTo.offset().top);
        container.css('position', 'relative');
        alert(scrollTo.offset().top - container.offset().top + container.scrollTop());
        // Or you can animate the scrolling:
        container.animate({
            top: scrollTo.offset().top - container.offset().top + container.scrollTop()
        });
	   **/
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
            $(loadSpinner).hide();
            CustomAlert.show('Scope(s) have been removed successfully!!!');
        }
    },
    delete_scope_asyncCallback: {
        onSuccess: function(result) {
            //alert(result);
            if (result.indexOf('Fail') != -1) {
                alert(result);
                $(loadSpinner).hide();
                AddEditScope.delete_scope_arr = [];
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
                return;
            }
            if (AddEditScope.delete_call_register && AddEditScope.delete_call_register[result]) delete AddEditScope.delete_call_register[result];
            if (AddEditScope.delete_call_register && JSON.stringify(AddEditScope.delete_call_register) == '{}') {
                $(loadSpinner).hide();
                CustomAlert.show('Scope(s) have been removed successfully!!!');
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
                return;
            }
            if (AddEditScope.reparent_call_register && AddEditScope.reparent_call_register[result]) delete AddEditScope.reparent_call_register[result];
            if (AddEditScope.reparent_call_register && JSON.stringify(AddEditScope.reparent_call_register) == '{}') {
                $(loadSpinner).hide();
                CustomAlert.show('Scope(s) have been re-parented successfully!!!');
            }
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    tree_init: function() {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        sforce.apex.execute("E2_Estimator_WS", "retrieveAllScopeTreeNodesOnEstimateId", {
            estimateId: estimateId
        }, AddEditScope.tree_init_callback);
    },
    sort_order: function(data) {
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
    },

    tree_init_callback: {
        onSuccess: function(result) {
            // sort the result to move all the parents up in the list which is very required to load
            // all the child records aligned.
            //doesnt work: result.sort(function(a,b) {return (a.parent > b.parent) ? 1 : ((b.parent > a.parent) ? -1 : 0);} ); 
            result = AddEditScope.sort_order(result);
            $.each(result, function(indx, node) {
                AddEditScope.create_node(node, AddEditScope.LAST);
            });
            bindEvents();
            
            if(AddEditScope.SAVED_SCOPE_ID != null){
              $(treeId).jstree(true).select_node(AddEditScope.SAVED_SCOPE_ID);
        	  CustomAlert.show('Scope: ' + AddEditScope.SAVED_SCOPE_NAME  + ' have been saved successfully!!!');
        	  AddEditScope.SAVED_SCOPE_ID = null;
        	  AddEditScope.SAVED_SCOPE_NAME = null;
            }
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
        }
    },
    addScopeTemplate_RecurringCallBack: {
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
                    $(loadSpinner).hide();
                    CustomAlert.show('Scope(s) have been cloned successfully!!!');
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
        sforce.apex.execute("E2_Estimator_WS", "getChildCloneNodes", {
            parentId: parentId,
            sourceId: sourceId,
            estimateId: estimateId
        }, AddEditScope.addScopeTemplate_RecurringCallBack);
    },

    addscopetemplate_call_register: {},

    addScopeTemplate_initCallBack: {
        onSuccess: function(result) {
            var hasChildren = false;
            if (result.length > 0) {
                var scope_id = result[0].scope_id;
                var node = result[0].nodeList;
                AddEditScope.create_node(node, AddEditScope.LAST);
                if (node.hasChildren == true || node.hasChildren == 'true') {
                    hasChildren = true;
                    AddEditScope.addscopetemplate_call_register[node.id] = scope_id;
                    AddEditScope.addScopeTemplate_Recurring(node.id, node.sourceId);
                }

                if (AddEditScope.addscopetemplate_call_register && AddEditScope.addscopetemplate_call_register[scope_id]) delete AddEditScope.addscopetemplate_call_register[scope_id];
                if (AddEditScope.addscopetemplate_call_register && JSON.stringify(AddEditScope.addscopetemplate_call_register) == '{}') {
                    $(loadSpinner).hide();
                    CustomAlert.show('Scope(s) have been cloned successfully!!!');
                }

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
        AddEditScope.addscopetemplate_call_register[scopeId] = '#';
        sforce.apex.execute("E2_Estimator_WS", "getClonedNodes", {
            scopeId: scopeId,
            estimateId: estimateId,
            parentScopeId: '#'
        }, AddEditScope.addScopeTemplate_initCallBack);
    },

    addScopeTemplateWithParent_init: function(scopeId, parentScopeId) {
        AddEditScope.addscopetemplate_call_register[scopeId] = parentScopeId;
        sforce.apex.execute("E2_Estimator_WS", "getClonedNodes", {
            scopeId: scopeId,
            estimateId: estimateId,
            parentScopeId: parentScopeId
        }, AddEditScope.addScopeTemplate_initCallBack);
    },

    addScopeTemplate: function() {
        var selectedIds = document.getElementById(AddEditScope.SELECT_TEMPLATE_IFRAME_ID).contentWindow.getselectedScopeIdsArray();

        if (selectedIds.length == 0) {
            alert('No Scope being selected for Add');
            return;
        }

        var ans = confirm('Are you sure you want to add selected scope(s)/Template(s)?');
        if (ans == false) {
            return;
        }

        var result = selectedIds;
        //var result = ['a5wR00000004EdD', 'a5wR0000000Ce2Q', 'a5wR0000000Cdg0'];
        if (AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID && AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != null) {

            $.each(result, function(indx, node) {
                $(loadSpinner).show().css('height', $(document).outerHeight());
                AddEditScope.addScopeTemplateWithParent_init(node, AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
            });
        } else {

            $.each(result, function(indx, node) {
                $(loadSpinner).show().css('height', $(document).outerHeight());
                AddEditScope.addScopeTemplate_init(node);
            });
        }
        AddEditScope.hideAddFromTemplateModal();
    },

    addNewScope: function() {
        var func = document.getElementById(AddEditScope.SELECT_ADD_NEW_FRAME_ID).contentWindow.addUpdateScopes;
        if (typeof func != 'undefined') {
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
        $(treeId).jstree('destroy');
        $(treeId).jstree(jstree_options);
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
        AddEditScope.hideAddNewModal();
        CustomAlert.show('New Scope(s) have been added successfully!!!');
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
    
    showSaveSuccessMessage: function(scope_id, scope_name){
    	AddEditScope.SAVED_SCOPE_ID = scope_id;
        AddEditScope.SAVED_SCOPE_NAME = scope_name;
    	$(treeId).jstree('destroy');
        $(treeId).jstree(jstree_options);
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
    },

    showAddNewModal: function() {
        $('#helpModal1').show();
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).attr('src', '/apex/E2_AddNewScope?is_New=true&estimate_id=' + estimateId);
        $('#helpModal1').find('#' + AddEditScope.SELECT_ADD_NEW_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpModal1').find('#addupdatescopebutton').html('Add');
        $('#helpBackdrop1').show();
    },

    showAddFromTemplateModal: function() {
        $('#helpModal').show();
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).attr('src', '/apex/E2_SelectScopeTemplate');
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