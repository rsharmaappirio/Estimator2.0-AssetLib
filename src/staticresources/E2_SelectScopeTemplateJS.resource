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
	        	removePills : function(pillId) {
	            	$( "#pillContainer" ).children( "#"+pillId ).replaceWith("");
	            	$( "#"+pillId+"href" ).addClass("addup_button");
					$( "#"+pillId+"href" ).removeClass("added_button");
	            	resetIframeHeight();
	        	},
	        	addPillsLink : function(scopeId,scopeName) {
	        		if($( "#pillContainer" ).children( "#"+scopeId ).length) {
						// Do nothing
					} else {
					    $( "#"+scopeId+"href" ).removeClass("addup_button");
					    $( "#"+scopeId+"href" ).addClass("added_button");
	                	var pillsString ='<span class="slds-pill" id="'+scopeId+'">'+
	                                  	 '<a href="javascript:void(0);" id="pillsDiv" scope-id="'+scopeId+'">'+
	                                  	 '<span class="slds-pill__label">'+scopeName+'</span></a>'+
	                  					 '<button class="slds-button slds-button--icon-bare slds-pill__remove" onclick="scopesPills.removePills(\''+scopeId+'\');AddScopeTree.updateTreeState();return false;">'+
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
	        	            console.log($(span).attr("Id"));
	        	            $( "#"+$(span).attr("Id")+"href" ).removeClass("addup_button");
					        $( "#"+$(span).attr("Id")+"href" ).addClass("added_button");
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
			    },
				create_node: function(node, position) {
	        		node.state = JSON.parse(node.state);
			        // jstree api call to create the tree node.
			        console.log(node.parent + '-'+node.id );
			        if((node.parent !='#' && $( "#pillContainer" ).children( "#"+node.parent ).length) || 
			        	$( "#pillContainer" ).children( "#"+node.id ).length) {
			        	node.state = {opened:true, selected:true};
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
			        	var haschildren = false; 
			            if(result.length > 0){
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
		                   	bindEvents();
		                   	if (AddScopeTree.addscopenode_call_register && AddScopeTree.addscopenode_call_register[scope_id]) delete AddScopeTree.addscopenode_call_register[scope_id];
		                   	if (AddScopeTree.addscopenode_call_register && JSON.stringify(AddScopeTree.addscopenode_call_register) == '{}') {
		                   		spinner.hide();
							}
						} else {
	                		spinner.hide();
	                	}
					},
			        onFailure: function(error) {
			            alert(error);
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
			                   	spinner.hide();
			                }
						} else {        
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
		    		AddScopeTree.addscopepill_register = {};
		    		$.each($node.children_d, function(indx, id) {
		    			var $childnode = $(treeId).jstree(true).get_node(id);
		    			var pillsId = $(treeId).jstree(true).get_parent($childnode.original.id);
		    			if($childnode.state.selected && !(AddScopeTree.addscopepill_register[pillsId] || AddScopeTree.addscopepill_register['#'])) {
		    			    AddScopeTree.addscopepill_register[$childnode.original.id] = pillsId;
		    			    scopesPills.addPillsLink($childnode.original.id,$childnode.original.title);
		    			    if(pillsId == '#') {
		    			        AddScopeTree.addscopepill_register[pillsId] = '#';    
		    			    }
		    			}
		    			else {
		    			    if (AddScopeTree.addscopepill_register[pillsId])
		    			        AddScopeTree.addscopepill_register[$childnode.original.id] = pillsId;
		    				scopesPills.removePills($childnode.original.id);
		    			}
		    			console.log(AddScopeTree.addscopepill_register);
		    		});
			 	},
			 	/*getselectedTreeNode : function() {
			 		var $node = $(treeId).jstree(true).get_node('#');
		    		var parentSelected = false;
		    		$.each($node.children_d, function(indx, id) {
		    			var $childnode = $(treeId).jstree(true).get_node(id);
		    			if($childnode.state.selected && !parentSelected) {
		    			    var pillsId = $(treeId).jstree(true).get_parent($childnode.original.id);
		    			    if(pillsId == '#' || !$( "#pillContainer" ).children( "#"+pillsId ).length) {
		    			        scopesPills.addPillsLink($childnode.original.id,$childnode.original.title);
		    			  		parentSelected = true;
		    			    }
		    			}
		    			else
		    				scopesPills.removePills($childnode.original.id);
		    		});
			 	},*/
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
			 	}
			}
			var bindEvents = function(){
		    	$(treeId).on("select_node.jstree", function(e, data) {
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