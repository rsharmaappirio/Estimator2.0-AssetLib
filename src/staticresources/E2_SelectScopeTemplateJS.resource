			$( document ).ready(function() {				
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
			        AddScopeTree.destroyTree();
			    });		    	
		    	resetIframeHeight();
			});
			// Reset outer iFrame
		  	var resetIframeHeight = function(){  	  
			  if(parent && parent.AddEditScope && parent.AddEditScope.setHeightOfAddNewTemplateModal){	    
			    var height = $(document.body).outerHeight();
			    var popoverHeight = 0;
			    $('.slds-popover').each(function(){
			       var newHeight = $(this).offset().top + $(this).outerHeight();
			       if(popoverHeight < newHeight) popoverHeight = newHeight;
			    });
			    if(popoverHeight > height) height = popoverHeight;	    	    
			    parent.AddEditScope.setHeightOfAddNewTemplateModal(height);         
			  }
			}
    		// search scopes for template and my Fav
	    	var SelectScopeTempate = {
	    		search : function(){        
		          spinner.show();
		          var scopeName = $('input[id$=scopename_ele]').val(); 
		          searchScopeRecords(scopeName);
		       },
		       search_complete : function(){           
		          AddScopeTree.destroyTree();
		          resetIframeHeight();  
		       }
	    	}
	    	// spinner show and hide JS 
		    var spinner = {
		      show: function(){
		         $('#loadingSpinner').show();
		      },
		      hide: function(){
		         $('#loadingSpinner').hide();
		         resetIframeHeight();
		      }
		    }
		    // Add remove scope pills
    		var scopesPills = {
    		    IS_REMOVE_EVENT : false,
    		    IS_ON_SCOPE_CLICK : false,
	        	removePills : function(pillId) {
	            	$( "#pillContainer" ).children( "#"+pillId ).replaceWith("");
					$( "[id='"+pillId+"href']" ).each(function() {
                        $(this).addClass("addup_button");
                        $(this).removeClass("added_button");
                    });
	        	},
	        	addScopeFromVF : function(scopeId,scopeName) {
	        	    if($( "#pillContainer" ).children( "#"+scopeId ).length) {
	        	        scopesPills.IS_REMOVE_EVENT = true;
	        	        scopesPills.IS_ON_SCOPE_CLICK = true;
	        	        scopesPills.removePills(scopeId);
	        	        AddScopeTree.onScopeClick(scopeId);
	        	        resetIframeHeight();
	        	    } else {
	        	        scopesPills.IS_ON_SCOPE_CLICK = true;
	        	        scopesPills.addPillsLink(scopeId,scopeName);
	        	        AddScopeTree.onScopeClick(scopeId);
	        	    }
	        	},
	        	addPillsLink : function(scopeId,scopeName) {
	        		if($( "#pillContainer" ).children( "#"+scopeId ).length) {
						// Do nothing
					} else {
					    $( "[id='"+scopeId+"href']" ).each(function() {
                              $(this).removeClass("addup_button");
                              $(this).addClass("added_button");
                            });
	                	var pillsString ='<span class="slds-pill" id="'+scopeId+'">'+
	                                  	 '<a href="javascript:void(0);" id="pillsDiv" scope-id="'+scopeId+'">'+
	                                  	 '<span class="slds-pill__label">'+scopeName+'</span></a>'+
	                  					 '<button class="slds-button slds-button--icon-bare slds-pill__remove" onclick="scopesPills.removePills(\''+scopeId+'\');AddScopeTree.updateTreeState();resetIframeHeight();return false;">'+
	                    				 '<img src="'+ close_png_url +'" width="12" height="12"/></button>'+
	                					 '</span>';
	                	$( "#pillContainer" ).append(pillsString);
	                	
	                	resetIframeHeight();
	                }
	        	},
	        	markPillsChecked : function() {
	        	    if($( "#pillContainer" ).children().length) {
	        	        console.log($( "#pillContainer" ).children().length);
	        	        for(var index =0;index < $( "#pillContainer" ).children().length;index++) {
	        	            var span = $( "#pillContainer" ).children()[index];
	        	            $( "[id='"+$(span).attr("Id")+"href']" ).each(function() {
                              $(this).removeClass("addup_button");
                              $(this).addClass("added_button");
                            });
	        	        }
	        	    }
	        	}
	    	}
	    	// scope pagination JS
	    	var pagination = {
		        chrrentPage : function(currentCon, index, currentIndex, numberOfLinks) {
		            if(currentIndex != index) {
		                currentIndex = parseInt(index);
		                spinner.show();
		                getpage(currentCon, currentIndex);
		            }
		        },
		        nextPage : function(currentCon, currentIndex, numberOfLinks) {
		            if(currentIndex < numberOfLinks) {
		            currentIndex = currentIndex + 1;
		            spinner.show();
		            getpage(currentCon, currentIndex);
		            }
		        },
		        previousPage : function(currentCon, currentIndex, numberOfLinks) {
		            if(currentIndex > 1) {
		                spinner.show();
		             currentIndex = currentIndex - 1;
		             getpage(currentCon, currentIndex); 
		            }
		        },
		        paginationStyle : function(currentCon, currentIndex, numberOfLinks) {
		            if(currentIndex == numberOfLinks) {
		                $("#nextUp" + currentCon).removeClass("next").addClass("notNext");
		                $("#last" + currentCon).removeClass("next").addClass("notNext");
		            } else {
		                $("#nextUp" + currentCon).removeClass("notNext").addClass("next");
		                $("#last" + currentCon).removeClass("notNext").addClass("next");
		            }
		            if(currentIndex == 1) {
		                $("#previousUp" + currentCon).removeClass("prev").addClass("notPrevious");
		                $("#first" + currentCon).removeClass("prev").addClass("notPrevious");
		            } else {
		                $("#previousUp" + currentCon).removeClass("notPrevious").addClass("prev");
		                $("#first" + currentCon).removeClass("notPrevious").addClass("prev");
		            }
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
			    onScopeClick : function(scopeId) {
			    	$(treeId).jstree("destroy");			    	
				    $(treeId).jstree(jstree_options);
				    AddScopeTree.tree_init(scopeId);
				    bindEvents();
			    },
			    refreshFrame : function() {
			        var $node = $(treeId).jstree(true).get_node('#');
                	    $.each($node.children_d, function(indx, id) {
                		    var $childnode = $(treeId).jstree(true).get_node(id);
                		    $(treeId).jstree("select_node", id); 
                		});
		            AddScopeTree.getselectedTreeNode();
			    },
				create_node: function(node, position) {
	        		node.state = JSON.parse(node.state);
			        // jstree api call to create the tree node.
			        console.log(node.parent + '-'+node.id );
			        if(scopesPills.IS_REMOVE_EVENT == true) {
			        	    scopesPills.removePills(node.id);
			        }else if((node.parent !='#' && $( "#pillContainer" ).children( "#"+node.parent ).length) || 
			        	$( "#pillContainer" ).children( "#"+node.id ).length) {
			        	if(scopesPills.IS_ON_SCOPE_CLICK == true)  {  
    			        	node.state = {opened:true, selected:true};
        			        	if(!$( "#pillContainer" ).children( "#"+node.id ).length) {
        			        	scopesPills.addPillsLink(node.id,node.title);
        			        }
			        	} else if(scopesPills.IS_ON_SCOPE_CLICK == false && $( "#pillContainer" ).children( "#"+node.id ).length) {
			        	    node.state = {opened:true, selected:true};
			        	}
    			        
			        }		        
			        $(treeId).jstree(AddScopeTree.CREATE_NODE, node.parent, node, position);
				},
				open_node: function(node) {
				        // jstree api call to open current node.
				        $(treeId).jstree(AddScopeTree.OPEN_NODE, node);
				    },
				tree_init: function(scopeId) {			    	
				    	spinner.show();	
				    	AddScopeTree.addscopenode_call_register[scopeId] = '#';	    	
				    	sforce.apex.execute("E2_Estimator_WS","getScopeDetailNodes", {scopeId:scopeId}, AddScopeTree.tree_init_callback);
				 },
				tree_init_callback: {
			    	onSuccess: function(result) {
			            if(result.length > 0) {
			                var haschildren = false;
	                    	var scope_id = result[0].scope_id;
	                      	if (result[0].nodeList) {
			              		var node = result[0].nodeList;
			              		node.parent = "#";
			                	AddScopeTree.create_node(node, AddScopeTree.LAST);
			                	if (node.hasChildren == true || node.hasChildren == 'true') {
			                		hasChildren = true;
			                    	AddScopeTree.addscopenode_call_register[node.id] = scope_id;
			                    	AddScopeTree.getScopeChildDetail_Recurring(node.id);
			                 	} else {
			                 	    scopesPills.IS_REMOVE_EVENT = false;
			                 	    scopesPills.IS_ON_SCOPE_CLICK = false;
			                 	    spinner.hide();
			                 	}
			               	}
		                   	if (AddScopeTree.addscopenode_call_register && AddScopeTree.addscopenode_call_register[scope_id]) delete AddScopeTree.addscopenode_call_register[scope_id];
						} else {
						    scopesPills.IS_ON_SCOPE_CLICK = false;
						    scopesPills.IS_REMOVE_EVENT = false;
		                   	spinner.hide();
	                	}
					},
			        onFailure: function(error) {
			            alert(error);
			            scopesPills.IS_ON_SCOPE_CLICK = false;
			        }
			 	},
			 	getScopeChildDetail_Recurring : function(parentId){
			    	spinner.show();
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
			                   	scopesPills.IS_REMOVE_EVENT = false;
			                   	scopesPills.IS_ON_SCOPE_CLICK = false;
			                   	spinner.hide();
			                }
						} else {
						    scopesPills.IS_REMOVE_EVENT = false;
						    scopesPills.IS_ON_SCOPE_CLICK = false;
			                spinner.hide();
			        	}
			        },
			        onFailure: function(error) {
			            alert(error);
			        }
			 	},
			 	destroyTree : function() {
			 	    
			 		$(treeId).jstree("destroy");  
			 		spinner.hide();
			 	},
			 	getselectedTreeNode : function() {
			 		var $node = $(treeId).jstree(true).get_node('#');
		    		$.each($node.children_d, function(indx, id) {
		    			var $childnode = $(treeId).jstree(true).get_node(id);
		    			scopesPills.addPillsLink($childnode.original.id,$childnode.original.title);
		    			if($childnode.state.selected) {
		    			    scopesPills.addPillsLink($childnode.original.id,$childnode.original.title);
		    			}
		    			else {
		    				scopesPills.removePills($childnode.original.id);
		    				resetIframeHeight();
		    			}
		    		});
			 	},
			 	updateTreeState : function() {
			 		var $node = $(treeId).jstree(true).get_node('#');
		    		var parentSelected = false;		    		
		    		$.each($node.children_d, function(indx, id) {
		    			if($( "#pillContainer" ).children( "#"+id ).length) {
		    				$(treeId).jstree(true).select_node(id);
		    				if($(treeId).jstree(true).get_parent(id) == '#')
		    			  		return false;
		    			}else {
		    				$(treeId).jstree(true).deselect_node(id);
		    			}		    			
		    		});
			 	},
			 	deSelectAllNodes : function() {
			 	    var $node = $(treeId).jstree(true).get_node('#');
		    		var parentSelected = false;		    		
		    		$.each($node.children_d, function(indx, id) {
		    		    $(treeId).jstree(true).deselect_node(id);
		    		    scopesPills.removePills(id);
		    		    resetIframeHeight();
		    		});
			 	}
			}
			var bindEvents = function(){
		    	$(treeId).on("select_node.jstree", function(e, data) {
		    		var $node = $(treeId).jstree(true).get_node(data.node.id);
		    		$.each($node.children_d, function(indx, id) {
		    			var $childnode = $(treeId).jstree(true).get_node(id);
		    			$(treeId).jstree("select_node", id); 
		    		});
		    		AddScopeTree.getselectedTreeNode();
		    	});		    
				$(treeId).on("deselect_node.jstree", function (e, data) {
			    	AddScopeTree.getselectedTreeNode();
				});
			}
	    	function getselectedScopeIdsArray() {
	        	var arr = [];
	        	$('a[id="pillsDiv"]').each(function( index ) {
	           	arr.push($(this).attr('scope-id'));  
	        	});
	        	return arr;
	    	}
	    	var showhideFavorite = function(favoriteLink) {
	    	    var  isFav = false;
	    	    spinner.show();
	    	    var scopeId = $(favoriteLink).attr('scope-id');
	    	    if($(favoriteLink).hasClass("nonfavStar")){
	    	        $(favoriteLink).removeClass("nonfavStar").addClass("favStar");
	    	        isFav = true;
	    	    }
	    	    else{
    	    	    $(favoriteLink).addClass("nonfavStar").removeClass("favStar");
    	    	    isFav = false;
	    	    }
	    	    addOrRemoveFavScope(scopeId, isFav);
	    	    return false;
	    	}
	    	var refreshFrame = function(scopeId) {
	    	    if(parent && parent.AddEditScope && parent.AddEditScope.reload_Scope_frameId){	    
    			    parent.AddEditScope.reload_Scope_frameId(scopeId);         
    			}
    			return false;
	    	}
	    	