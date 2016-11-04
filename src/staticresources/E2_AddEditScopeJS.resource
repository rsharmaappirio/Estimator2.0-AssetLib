// jstree conditional select node
(function ($, undefined) {
  "use strict";
  $.jstree.defaults.conditionalselect = function () { return true; };

  $.jstree.plugins.conditionalselect = function (options, parent) {
    // own function
    this.select_node = function (obj, supress_event, prevent_open) {
      if(this.settings.conditionalselect.call(this, this.get_node(obj))) {
        parent.select_node.call(this, obj, supress_event, prevent_open);
      }
    };
  };
})(jQuery);


var CustomAlert = {
    notifyContainerCssSelector: '.slds-notify_container',
    notifyCloseCssSelector: '.slds-notify__close',
    notifyMsgCssSelector: '.slds-text-heading--small',
    notifyTypeCssDiv: '#sldsalertdiv',
    notifyEditContainer: '.slds-edit-alert',
    notifyEditContainerbackdrop: '.slds-edit-alert-backdrop',
    showIsDirtyWarning: function() {
        $(CustomAlert.notifyEditContainerbackdrop).show().css('height', $(document).outerHeight());
        $(CustomAlert.notifyEditContainer).show();
    },
    hideIsDirtyWarning: function() {
        $(CustomAlert.notifyEditContainer).hide();
        $(CustomAlert.notifyEditContainerbackdrop).hide();
    },
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
    "plugins": ["dnd", "contextmenu", "search", "conditionalselect" ],//"sort"],
    'conditionalselect' : function (node) {
         // this method is used to validate if the scope detail is dirty than don't progress and show the save warning
         var IFRAME_KEY = global_scopeId + AddEditScope.ENDS_WITH;
         var scope_detail_obj = document.getElementById(IFRAME_KEY);
         if(scope_detail_obj && scope_detail_obj.contentWindow.TrackScopeUpdates.is_Dirty()) {
           AddEditScope.showIsDirtyWarning(global_scopeId);
           return false;
         }        
         return true;
     },
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
                        AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID = $node.id;
                        AddEditScope.showAddFromTemplateModal();
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
                        // traverse all the child li elements (clild nodes to retrieve the sfdc scope ids)
                        // push each id in array to be utilzied later to delete from db
                        $('#' + $node.id).find('li').each(function(e) {
                            AddEditScope.delete_scope_arr.push($(this).attr('id'));
                        });
                        // delete node and child nodes from UI  
                        tree.delete_node($node);
                        // delete scope and child scopes from db
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
    contentToShow : null,
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
                  tabpanel.contentToShow = $('#'+ $(this).find('a').attr('aria-controls'));
                  // slow hide the tabs in order to make hide work for rte
                  setTimeout(function() {
                      tabpanel.contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			          tabpanel.contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
                  }, 80);    
                  
		          $(this).addClass('slds-active');
			      $(this).find('a').attr('aria-selected', true);
			      tabpanel.contentToShow.removeClass('slds-hide');
			      tabpanel.contentToShow.addClass('slds-show');			
			      $(this).siblings().removeClass('slds-active');
			      $(this).siblings().find('a').attr('aria-selected', false);
			      
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
        
        // populate the link url
        $(ck_custom_editor.linkbox_Id).val(ck_custom_editor.getLinkURL(estimateId, node.id));
        
        var obj = $('<div/>').html(node.original.text);
        var linkName = 'Scope Item: ' + obj.find('span span:first-child').text();
        
        // populate the link name
        $(ck_custom_editor.linknamebox_Id).val(linkName);
        // set data to empty in the editor
        CKEDITOR.instances[ck_custom_editor.editor_name].setData('');
        // focus on link box
        $(ck_custom_editor.linknamebox_Id).focus();
        // set focus on editor after 500 ms
        window.setTimeout(ck_custom_editor.focusOnEditor, 500);  
  },
  
  openLinkPostView : function(){
      chatter.getPublisher().openTypeSpecificPanel(Sfdc.get("publisherAttachLinkPost"), "LinkPost");
  },
  
  getLinkURL : function(estimateId, scopeId){
      return window.location.origin + window.location.pathname + '?id=' + estimateId + '&scopeid=' + scopeId;
  }
  
}

var originalY = 0;
var topMargin = 0;

$(document).ready(function() {
    // bind the events and initiate jstree and other libraries 
    // at the time of dom is ready on the page.
    $(treeId).jstree(jstree_options);
    tabpanel.bindEvents();
    ck_custom_editor.load();
    
    //EVENT: JSTREE LOADED FOR THE FIRST TIME
    $(treeId).on("ready.jstree", function(e, data) {
        $(loadSpinner).show().css('height', $(document).outerHeight());
        AddEditScope.tree_init();
    });


    // 08/05: RJ: originalY, topMargin made global variable: cause of js clouser
    var element = $(tabpanel.containerId);
    originalY = element.offset().top;

    // Space between element and top of screen (when scrolling)
    topMargin = -10;

    // Should probably be set in CSS; but here just for emphasis
    element.css('position', 'relative');

    // Bind the window scroll event to allow the scope details to scroll with the scrollbar 
    // on screen for good user experience
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
    
    // Bind the window resize event to adjust the with of all the iframes with the resized 
    // width of the window
    // on screen for good user experience
    $( window ).resize(function() {
         var element = $(tabpanel.containerId);
         if ($(this).width() < 767) {
            element.css({'position': 'static', 'top' : 0});
            // reload all the iframe again to adjust their heights
            // may be this can be done through setting height 
            var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
            $(containerId).find('iframe').height(function(){return $(this.contentWindow.document).height()});
            
         }else{
            element.css('position', 'relative');
         }     
    });
    
    
    // Override the onclick property on some relative links, buttons on the page to check isDirty first and then allow the user to 
    // click; if some form on the page is dirty than show a warning message to the user
    $('div.slds-page-header input.slds-button, a.slds-tabs--path__link, button.slds-path__mark-complete, a#tab-default-2__item').each(function(){
        var handler = $(this).prop('onclick');
        $(this).removeProp('onclick');
        $(this).click(warning_event);
        $(this).click(handler);
    });
    
    
});


var warning_event = function(e){
        // method is used to check is_dirty state and show warning message
        var IFRAME_KEY = global_scopeId + AddEditScope.ENDS_WITH;
        var scope_detail_obj = document.getElementById(IFRAME_KEY);
        if(scope_detail_obj 
                         && scope_detail_obj.contentWindow 
                         && scope_detail_obj.contentWindow.TrackScopeUpdates 
                         && scope_detail_obj.contentWindow.TrackScopeUpdates.is_Dirty()) {
           AddEditScope.showIsDirtyWarning(global_scopeId);
           e.stopImmediatePropagation();
           return false;
        }
}

var bindEvents = function(){
	//EVENT: JSTREE NODE BEING REPARENTED
    $(treeId).on("move_node.jstree", function(e, data) {
        AddEditScope.reparent_scope(data.node.id, data.parent);
    });
    
    //EVENT: JSTREE NODE BEING SELECTED
    $(treeId).bind("select_node.jstree", function (e, data) {
          global_scopeId = data.node.id;
          AddEditScope.edit_node(data.node, data.parent);   
          tabpanel.showDetailTab();
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
    SELECTED_NODE : '',
    UPDATE_DISPLAY_ORDER : false,
    reload_Scope_frame : function(result) {
        $.each(result, function(indx, scope) {
            var frame_id = '#' + scope + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
        });
    },
    reload_Scope_frameId : function(scope) {
            var frame_id = '#' + scope + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
    },
    showIsDirtyWarning : function(id) {
            AddEditScope.SELECTED_NODE = id + AddEditScope.ENDS_WITH;
            CustomAlert.showIsDirtyWarning();
    },
    save_edit_scope : function() {
        $('#' + AddEditScope.SELECTED_NODE).focus();
        document.getElementById(AddEditScope.SELECTED_NODE).contentWindow.TrackScopeUpdates.save_scope();
        CustomAlert.hideIsDirtyWarning();
        $(treeId).jstree(true).select_node(global_scopeId);
    },
    cancel_scope_save : function() {
        $('#' + AddEditScope.SELECTED_NODE).focus();
        document.getElementById(AddEditScope.SELECTED_NODE).contentWindow.TrackScopeUpdates.markchecked();
        CustomAlert.hideIsDirtyWarning();
        $(treeId).jstree(true).select_node(global_scopeId);
    },
    edit_node : function(node, parent){
	   var endsWith = AddEditScope.ENDS_WITH;
	   var containerId = '#' + AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;   
	   var frame_id = '#' + node.id + endsWith;
	   var frame_id_standard = node.id + endsWith;
	   
	   // check that if the container for all the iframes (for edit scope) is on the page
	   if($(containerId).length){
	       // hide all frames on the page but not the one selected (if already loaded)
		   $(containerId).find("iframe[id$='" + endsWith + "']").not(frame_id).hide("slow", function() {});
		   // check if selected node's iframe exists or not
		   if($(frame_id).length){
		       // don't call show if frame is already visible.
		       if($(frame_id).is(':visible')){
		           var doc = $(document.getElementById(frame_id_standard).contentWindow.document);
		           //IE - check the height of content window document with an interval using setTimeout
		           setTimeout(function(){
		             $(frame_id).css({ 'min-height':'400px', 'width':'100%', 'margin':'0px', 'height' : doc.outerHeight()});
		             $(frame_id).focus();
		           }, 500);
		       }else{
    			   $(frame_id).show("slow", function() {
    				   // whenever element is shown again; re-set the height with the dom content
    				   $(this).css({ 'min-height':'400px',width:'100%',margin:'0px', height : $(this.contentWindow.document).height()});
    				   $(frame_id).focus();
    			   });
		       }
		   }else{
		       // if iframe doesn't exist than create a new iframe for that scope
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
        // check if deleted scopes id array is populated
        if (AddEditScope.delete_scope_arr.length > 0) {
            // remove/pop last element 
            var scopeid_delete = AddEditScope.delete_scope_arr.pop();
            // remove the respective iframe from the page too.
            var frame_id = '#' + scopeid_delete + AddEditScope.ENDS_WITH;
            if($(frame_id).length) $(frame_id).remove(); 
            // call the webservice method to remove from db
            sforce.apex.execute("E2_Estimator_WS", "deleteScope", {
                scopeId: scopeid_delete,
                parentId: '#'
            }, AddEditScope.delete_scope_asyncCallback);
        } else {
            // if nothing in the list anymore; reload the jstree with the new data
            $(loadSpinner).show().css('height', $(document).outerHeight());
            global_scopeId = null;
            //to refresh scope loe we need to reload jstree
            $(treeId).jstree('destroy');
            $(treeId).jstree(jstree_options);
            AddEditScope.tree_init();
        }
    },
    delete_scope_asyncCallback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result); 
            // check if the result contains a failure message from the webservice
            if (result.indexOf('Fail') != -1) {
                // if failed show the failure warning custom alert
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
            // call the delete function again for other items in the array
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
            // check for failure message, show alert and stop
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
            // if there is no failure; delete respective call registers
            if (AddEditScope.reparent_call_register && AddEditScope.reparent_call_register[result]) delete AddEditScope.reparent_call_register[result];
            if (AddEditScope.reparent_call_register && JSON.stringify(AddEditScope.reparent_call_register) == '{}') {
           
                // WHEN REPARENTING - EDIT SCOPE SCREEN NEED TO BE RELOADED WITH NEW PARENT
                var frame_id = '#' + result + AddEditScope.ENDS_WITH;
                if($(frame_id).length) $(frame_id).attr("src", function(){ return $(this).attr("src")});
                
                //to refresh scope loe we need to reload jstree
                global_scopeId = result;
                
                // set the display order and sequence back in the database
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
            // check for failure message
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                
                if(result.toLowerCase().indexOf(exception.toLowerCase()) != -1){
                  CustomAlert.showError('Re-ordering Failed: You do not have permission to re-order this scope!!! Please contact scope owner!!');    
                }else{
                  alert(result);
                }
                $(loadSpinner).hide();
                    
                // call the tree_init back to get the deleted node
                $(treeId).jstree('destroy');
                $(treeId).jstree(jstree_options);
                AddEditScope.tree_init();
                
                return;
            }
            if(AddEditScope.UPDATE_DISPLAY_ORDER == true) {
                CustomAlert.show('Scope have been cloned successfully!!!');
                AddEditScope.UPDATE_DISPLAY_ORDER = false;
            } else {
                CustomAlert.show('Scope have been re-parented successfully!!!');
            }
            
            $(loadSpinner).show().css('height', $(document).outerHeight());
            // load the tree again with updated data with reparenting
            $(treeId).jstree('destroy');
            $(treeId).jstree(jstree_options);
            AddEditScope.tree_init();
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
            // sort the result order based on the display order
            // this is necessary as create nodes only in the same order they were
            // stored in database
            result = AddEditScope.sort_order_new(result);
            $.each(result, function(indx, node) {
                //console.log('MI::::' + node.title + '-' + node.display_order);
                AddEditScope.create_node(node, parseInt(node.display_order));
            });
            // clear the result
            result = [];
            
            // since tree is reloaded/refreshed; bind the tree events back
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
            if(AddEditScope.UPDATE_DISPLAY_ORDER == true) {
                AddEditScope.UPDATE_DISPLAY_ORDER = false;
                // set the display order and sequence back in the database
                AddEditScope.updateScopeDisplayOrderOnClone();
            } else {
                $(loadSpinner).hide();
            }
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    },
    addScopeTemplate_initCallBack: {
        onSuccess: function(result) {
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
        sforce.apex.execute("E2_Estimator_WS", "getSelectedScopeNodes", {
            scopeIdCSV: scopeId,
            estimateId: estimateId,
            parentScopeId: '#'
        }, AddEditScope.addScopeTemplate_initCallBack);
    },

    addScopeTemplateWithParent_init: function(scopeId, parentScopeId) {
        sforce.apex.execute("E2_Estimator_WS", "getSelectedScopeNodes", {
            scopeIdCSV: scopeId,
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

        var result = selectedIds;
        //var result = ['a5wR00000004EdD', 'a5wR0000000Ce2Q', 'a5wR0000000Cdg0'];
        if (AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID && AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID != null) {
            $(loadSpinner).show().css('height', $(document).outerHeight());
            AddEditScope.addScopeTemplateWithParent_init(result.toString(), AddEditScope.ADD_FROM_TEMPLATE_PARENT_ID);
        } else {
            $(loadSpinner).show().css('height', $(document).outerHeight());
            AddEditScope.addScopeTemplate_init(result.toString());
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
		 //AddEditScope.reload_frame('/apex/E2_EditScope?id='+scope_id, scope_id + AddEditScope.ENDS_WITH);
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
                    $(treeId).jstree('destroy');
                    $(treeId).jstree(jstree_options);
                    AddEditScope.tree_init();
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


