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
        "multiple": false
    },
    'checkbox': {
        'three_state': false,
        'cascade': ''
    },
    "contextmenu": {
    	"select_node" : true,
        "items": function($node) {
            var tree = $(treeId).jstree(true);
            return {
                "Add_Edit_Child": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Manage Children",
                    "action": function(obj) {
                        $('#helpModal1').find('#theIframe1').attr('src', '/apex/E2_AddNewScope?is_Edit=true&estimate_id=' + estimateId + '&id=' + $node.id);
                        $('.custom-new-header').html('Manage Children');
                        $('#helpModal1').find('#addupdatescopebutton').html('Update');
                        $('#helpModal1').show();
                        $('#helpModal1').find('#theIframe1').closest('div.slds-modal__content').scrollTop(0);
                        $('#helpBackdrop1').css({'height' : $(window.document).height()});
                        $('#helpBackdrop1').show();

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
                "Remove": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Remove",
                    "action": function(obj) {
                        var ans = confirm('Are you sure you want to delete selected scope?');
                        if (ans === false) {
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
                "Comment": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Comment",
                    "action": function(obj) {
                        ck_custom_editor.postComment($node);
                    }
                }
            };
        }
    }
};


var tabpanel = {
    containerId : '#tabpanel',
    detail_tabId : '#tab-default-1__item',
    feed_tabId : '#tab-default-2__item',
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
			        $(this).addClass('slds-active');
			        $(this).find('a').attr('aria-selected', true);
			        var $contentToShow = $('#'+$(this).find('a').attr('aria-controls'));
			        $contentToShow.removeClass('slds-hide');
			        $contentToShow.addClass('slds-show');			
			        $(this).siblings().removeClass('slds-active');
			        $(this).siblings().find('a').attr('aria-selected', false);
			        $contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			        $contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
		});
    },
    activateTab: function(that){
                    that.addClass('slds-active');
			        that.find('a').attr('aria-selected', true);
			        var $contentToShow = $('#'+ that.find('a').attr('aria-controls'));
			        $contentToShow.removeClass('slds-hide');
			        $contentToShow.addClass('slds-show');			
			        that.siblings().removeClass('slds-active');
			        that.siblings().find('a').attr('aria-selected', false);
			        $contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			        $contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
        
    },
    
    showDetailTab: function(){
        tabpanel.activateTab($(tabpanel.detail_tabId).parent());
    },
    
    showFeedTab: function(){
        tabpanel.activateTab($(tabpanel.feed_tabId).parent());
    }
    
}

var custom_chatter = {
    
    oncomplete : function(){
        //alert('in me');
    }
    
}

var ck_custom_editor = {
  instance: null,
  linkbox_Id : '#url',
  linknamebox_Id : '#urlName',
  editor_name : 'publisherRichTextEditor',
  load : function(){
   	 //window.setTimeout(ck_custom_editor.logCKEditorInstance, 5000);  
  },
  focusOnEditor : function(){
       
     CKEDITOR.instances[ck_custom_editor.editor_name].focus();
  },
  postComment : function(node){
        tabpanel.showFeedTab();
        ck_custom_editor.openLinkPostView();
        $(ck_custom_editor.linkbox_Id).val(ck_custom_editor.getLinkURL(estimateId, node.id));
        
        var obj = $('<div/>').html(node.original.text);
        var linkName = 'Scope Item: ' + obj.find('span span:first-child').text();
        
        $(ck_custom_editor.linknamebox_Id).val(linkName);
        CKEDITOR.instances[ck_custom_editor.editor_name].setData('');
        $(ck_custom_editor.linknamebox_Id).focus();
        window.setTimeout(ck_custom_editor.focusOnEditor, 500);  
  },
  
  openLinkPostView : function(){
      chatter.getPublisher().openTypeSpecificPanel(Sfdc.get("publisherAttachLinkPost"), "LinkPost");
  },
  
  getLinkURL : function(estimateId, scopeId){
      return window.location.origin + window.location.pathname + '?id=' + estimateId + '&scopeid=' + scopeId;
  }
  
}



$(document).ready(function() {
    $(treeId).jstree(jstree_options);
    tabpanel.bindEvents();
    ck_custom_editor.load();
    //EVENT: JSTREE LOADED FOR THE FIRST TIME
    $(treeId).on("ready.jstree", function(e, data) {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
    });


    
    var element = $(tabpanel.containerId),
        originalY = element.offset().top;

    // Space between element and top of screen (when scrolling)
    var topMargin = -10;

    // Should probably be set in CSS; but here just for emphasis
    element.css('position', 'relative');

    $(window).on('scroll', function(event) {
        if ($(this).width() > 767) {
            var element = $(tabpanel.containerId);
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
         var element = $(tabpanel.containerId);
         if ($(this).width() < 767) {
            element.css({'position': 'static', 'top' : 0});
            // reload all the iframe again to adjust their heights
            // may be this can be done through setting height 
            var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
            //$(containerId).find('iframe').attr("src", function(){ return $(this).attr("src")});
            $(containerId).find('iframe').height(function(){return $(this.contentWindow.document).height()});
            
         }else{
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
        //if(data && data.event && data.event.button != 2) {
        global_scopeId = data.node.id;
        AddEditScope.edit_node(data.node, data.parent);   
        tabpanel.showDetailTab();
        //} 
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
	       // hide all frames on the page but not the one selected (if already loaded)
		   $(containerId).find("iframe[id$='" + endsWith + "']").not(frame_id).hide("slow", function() {
		   });
		   
		   if($(frame_id).length){
		       // don't call show if frame is already visible.
		       if($(frame_id).is(':visible')){
		           
		           var doc = $(document.getElementById(frame_id_standard).contentWindow.document);
		           //IE - check the height of content window document with an interval using setTimeout
		           setTimeout(function(){
		             $(frame_id).css({ 'min-height':'400px', 'width':'100%', 'margin':'0px', 'height' : doc.outerHeight()});  
		           }, 500);
		           //$(frame_id).css({ 'min-height':'400px', 'width':'100%', 'margin':'0px', 'height' : doc.outerHeight()});
		           
		       }else{
		           
    			   $(frame_id).show("slow", function() {
    				   // whenever element is shown again; re-set the height with the dom content
    				   $(this).css({ 'min-height':'400px',width:'100%',margin:'0px', height : $(this.contentWindow.document).height()});
    			   });
    			   
		       }
		   }else{
			   $('<iframe>', {
				   src: '/apex/E2_EditScope?estimate_id=' + estimateId + '&id=' + node.id,
				   id:  node.id + endsWith,
				   name: node.id + endsWith,
				   frameborder: 0,
				   scrolling: 'no',
				   style : 'min-height:471px;width:100%;margin:0px',
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
            global_scopeId = null;
            //to refresh scope loe we need to reload jstree
            $(treeId).jstree('destroy');
            $(treeId).jstree(jstree_options);
            AddEditScope.tree_init();
            //$(loadSpinner).hide();
            //CustomAlert.show('Scope(s) have been removed successfully!!!');
            
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
                
                // remove references from js memory
                AddEditScope.delete_scope_arr = [];
               
                // call the tree_init back to get the deleted node
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
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
            result = (result.length > 0 ? result[0] : result); 
            if (result.indexOf('Fail') != -1) {
                //alert(result);
                //$(loadSpinner).hide();
                //for (var prop in AddEditScope.delete_call_register) {
                //    delete AddEditScope.delete_call_register[prop];
                //}
                //return;
                
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Remove Failed: You do not have permission to remove this scope!!! Please contact scope owner for remove!!');    
                }else{
                  alert(result);
                }
                
                // remove references from js memory
                for(var _a in AddEditScope.delete_call_register){
                    delete AddEditScope.delete_call_register[_a];
                }
                // call the tree_init back to get the deleted node
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
                return;
                
            }
            if (AddEditScope.delete_call_register && AddEditScope.delete_call_register[result]) delete AddEditScope.delete_call_register[result];
            if (AddEditScope.delete_call_register && JSON.stringify(AddEditScope.delete_call_register) == '{}') {
                $(loadSpinner).hide();
                //CustomAlert.show('Scope(s) have been removed successfully!!!');
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
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
            result = (result.length > 0 ? result[0] : result); 
            
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                }else{
                  alert(result);
                }
                $(loadSpinner).hide();
                
                // remove references from js memory
                for(var _a in AddEditScope.reparent_call_register){
                    global_scopeId = _a;
                    delete AddEditScope.reparent_call_register[global_scopeId];
                }
                
                // call the tree_init back to get the deleted node
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
                return;
            }
           
            if (AddEditScope.reparent_call_register && AddEditScope.reparent_call_register[result]) delete AddEditScope.reparent_call_register[result];
            if (AddEditScope.reparent_call_register && JSON.stringify(AddEditScope.reparent_call_register) == '{}') {
           
                // WHEN REPARENTING - EDIT SCOPE SCREEN NEED TO BE RELOADED WITH NEW PARENT
                var frame_id = '#' + result + AddEditScope.ENDS_WITH;
                if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
                
                //to refresh scope loe we need to reload jstree
                global_scopeId = result;
                // show success message
                CustomAlert.show('Scope have been re-parented successfully!!!');
                $(loadSpinner).show().css('height', $(document).outerHeight());
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
                //$(loadSpinner).hide();
                
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
              
        	  CustomAlert.show('Scope Item: ' + AddEditScope.SAVED_SCOPE_NAME  + ' has been saved successfully!');
        	  AddEditScope.SAVED_SCOPE_ID = null;
        	  AddEditScope.SAVED_SCOPE_NAME = null;
            }else if(AddEditScope.SAVED_SCOPE_ID == null && global_scopeId != null && global_scopeId != ''){
                
                if($('#' + global_scopeId).length){
                  $(treeId).jstree(true).select_node(global_scopeId);
                  
                  AddEditScope.edit_node({"id":global_scopeId}, {"id":""});
                  
        	      tabpanel.showDetailTab();
                }else{
                  CustomAlert.show('Requested scope does not exist now!!!');    
                }
                global_scopeId = null;
            }
            
            $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
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
        alert(parentId + '#' + sourceId + '#' + global_scopeId);
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

        /*var ans = confirm('Are you sure you want to add selected scope(s)/Template(s)?');
        if (ans == false) {
            return;
        }*/

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
        CustomAlert.show('New Scope have been added successfully!!!');
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
        $('.custom-new-header').html('Add New Scope');
        $('#helpModal1').find('#addupdatescopebutton').html('Save');
        $('#helpBackdrop1').css({'height' : $(window.document).height()});
        $('#helpBackdrop1').show();
    },

    showAddFromTemplateModal: function() {
        $('#helpModal').show();
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).attr('src', '/apex/E2_SelectScopeTemplate');
        $('#helpModal').find('#' + AddEditScope.SELECT_TEMPLATE_IFRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop').css({'height' : $(window.document).height()});
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
    
    selected_flag_element : null,
    
    updateFlag : function(event, element) {
      // Don't propogate the event to the document
      if (event.stopPropagation) {
          event.stopPropagation();   // W3C model
      } else {
          event.cancelBubble = true; // IE model
      }
      AddEditScope.selected_flag_element = element;
      
      var scope_id = $(element).parent().parent().parent().attr('id');
      console.log(scope_id);
      
      if($(element).hasClass("flagRed")){
         AddEditScope.updateFlagValues(scope_id, "flagYellow");
      }
      else if($(element).hasClass("flagYellow")){
         AddEditScope.updateFlagValues(scope_id, "flagGreen");
      }
      else if($(element).hasClass("flagGreen")){
         AddEditScope.updateFlagValues(scope_id, "flagRed");
      }
      else {
         AddEditScope.updateFlagValues(scope_id, "flagGreen");
      }
    },

    updateFlagValues : function(scopeId, flagValue){
        $(loadSpinner).show().css('height', $(document).outerHeight());
        sforce.apex.execute("E2_Estimator_WS", "updateScopeFlag", {
                scopeId: scopeId,
                flagValue: flagValue
            }, AddEditScope.updateFlagValues_callback);
    },
    
    updateFlagValues_callback : {
        onSuccess: function(result) {
              //alert(result);
              
              result = (result.length > 0 ? result[0] : result); 
            
              if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Status change failed: You do not have permission to change the status of this scope!!!');    
                }else{
                  alert(result);
                }
                $(loadSpinner).hide();
                return;
              }         
              
              var ele = $(AddEditScope.selected_flag_element);
              if(ele.hasClass("flagRed")){
                 ele.removeClass("flagRed");
                 ele.addClass("flagYellow");
              }
              else if(ele.hasClass("flagYellow")){
                 ele.removeClass("flagYellow");
                 ele.addClass("flagGreen");
              }
              else if(ele.hasClass("flagGreen")){
                 ele.removeClass("flagGreen");
                 ele.addClass("flagRed");
              }
              else {
                 ele.addClass("flagGreen");
              }
              
              // WHEN FLAGGING - EDIT SCOPE SCREEN NEED TO BE RELOADED WITH NEW PARENT - IF EXISTS
              var frame_id = '#' + result + AddEditScope.ENDS_WITH;
              if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
              
              $(loadSpinner).hide();
        },
        onFailure: function(error) {
            alert(error);
            console.log(error);
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


