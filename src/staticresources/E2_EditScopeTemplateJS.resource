var validations = {

	load : function(){
	    validations.applyNumericValidation();
	    validations.applyTraverse();	    
	},
	
	
	
	applyNumericValidation : function(){
	   $('.mandate-numeric').keyup(function(evt) {		    
		    $('body div.slds-error--tooltip').remove();
		    var inputVal = $(this).val();
		    //var numericReg = /^\d*[0-9](|.\d*[0-9]|,\d*[0-9])?$/;
		     var numericReg = /^[0-9]+\.?[0-9]*$/;
		    if(!numericReg.test(inputVal)) {
                $(this).val(inputVal.substring(0, inputVal.length - 1)); 
		        $(document.body).append('<div class="slds slds-error--tooltip"><div class="slds slds-popover slds-popover--tooltip slds-nubbin--bottom" role="tooltip"><div class="slds-popover__body">Numeric only.</div></div></div>');
		        var top = $(this).offset().top - $(this).height() + 'px';
		        var left = $(this).offset().left + 'px';
		        $('body div.slds-error--tooltip').css({position : 'absolute', top : top , left : left});
		    }
		    
		});
		
		$('.mandate-numeric').blur(function(evt) {
		   $('body div.slds-error--tooltip').remove(); 
		});
	},
	
	applyTraverse: function(){
	
	   
	
	   // BELOW CODE IS WORKING BUT COMMENTED FOR NOW - BACK TRAVERSING
	   /**$('select.scope-complexity').keydown(function(e){	   
           var keyCode = e.keyCode; 
	       var shiftKey = e.shiftKey;	       
	       if(shiftKey && keyCode === 9){
	         var id = $(this).attr('id');
	         var outputtextid = id.replace('scope-complexity', 'assumptiontext');
		     var richtextid = id.replace('scope-complexity', 'assumptionRtext');
		     ck_custom_editor.editorShow(richtextid);	
		     CKEDITOR.instances[richtextid].focus();   
		     $(document.getElementById(outputtextid)).hide();
		     return false;
	       }
	   });**/
	   
	   
	   $('select.scope-itemtype').keydown(function(e){	   
           var keyCode = e.keyCode; 
	       var shiftKey = e.shiftKey;		             
	       if(!shiftKey && keyCode === 9){
	         var id = $(this).attr('id');
	         var outputtextid = id.replace('scope-itemtype', 'outputtext');
		     var richtextid = id.replace('scope-itemtype', 'richtext');
		     ck_custom_editor.editorShow(richtextid);	
		     CKEDITOR.instances[richtextid].focus();   
		     $(document.getElementById(outputtextid)).hide();
		     return false;
	       }
	   });
	   
	   if(typeof CKEDITOR != 'undefined'){     
	     for(var _a in CKEDITOR.instances){
	        CKEDITOR.instances[_a].on( 'key', function( evt ) {
			    if ( evt.data.keyCode === 9 ) {
			        if(evt.editor.name.indexOf('richtext') != -1){
			            var id = evt.editor.name;
				        var outputtextid = id.replace('richtext', 'assumptiontext');
					    var richtextid = id.replace('richtext', 'assumptionRtext');
					    ck_custom_editor.editorShow(richtextid);	
					    CKEDITOR.instances[richtextid].focus();   
					    $(document.getElementById(outputtextid)).hide();
					    evt.cancel();
			        }
			        
			        if(evt.editor.name.indexOf('assumptionRtext') != -1){
			           
			        }
			        // the keydown's default behavior will be prevented.
			        //evt.cancel();
			    }
			} );
		 }
       }
        
	}


}



var ck_custom_editor = {
  editor_load : function(name){
            ck_custom_editor.editorHideWithoutEffect(name);
		    if(name.indexOf('assumptionRtext') != -1) {
		    	$(document.getElementById(name.replace('assumptionRtext', 'assumptiontext'))).show();
		    	$(document.getElementById(name.replace('assumptionRtext', 'assumptiontext'))).css({'white-space' : 'normal', 'display' : 'block', 'width' : '100%', 'min-height' : '58px'});
		    } else {
		    	$(document.getElementById(name.replace('richtext', 'outputtext'))).show();
		    	$(document.getElementById(name.replace('richtext', 'outputtext'))).css({'white-space' : 'normal', 'display' : 'block', 'width' : '100%', 'min-height' : '58px'});
		    }  
  },

  load : function(){
    
    if(typeof CKEDITOR != 'undefined'){
     for(var _a in CKEDITOR.instances){   
         //alert('me in');
        
        
        ck_custom_editor.editor_load(_a);
         
        // Hide all ck editors on dom reload
        CKEDITOR.instances[_a].on( 'contentDom', function(e) {		    
		    ck_custom_editor.editor_load(e.editor.name);
		});
       
        
      
        CKEDITOR.instances[_a].on( 'blur', function( e ) {
	      ck_custom_editor.editorHide(e.editor.name);
	      if(e.editor.name.indexOf('assumptionRtext')!=-1) {
		    	$(document.getElementById(e.editor.name.replace('assumptionRtext', 'assumptiontext'))).html(CKEDITOR.instances[e.editor.name].getData(false));
	            $(document.getElementById(e.editor.name.replace('assumptionRtext', 'assumptiontext'))).show('slow', function(e){resetIframeHeight();});
		  } else {
		    	$(document.getElementById(e.editor.name.replace('richtext', 'outputtext'))).html(CKEDITOR.instances[e.editor.name].getData(false));
	            $(document.getElementById(e.editor.name.replace('richtext', 'outputtext'))).show('slow', function(e){resetIframeHeight();});
		  }
		  
	    } );
	   if(_a.indexOf('assumptionRtext')!=-1) {
	   		$(document.getElementById(_a.replace('assumptionRtext', 'assumptiontext'))).on('dblclick', function(e){	   
		      var id = $(this).attr('id');
		      id = id.replace('assumptiontext', 'assumptionRtext');
		      ck_custom_editor.editorShow(id);	
		      CKEDITOR.instances[id].focus();   
		      $(this).hide();
		    });
	   } else {
		   $(document.getElementById(_a.replace('richtext', 'outputtext'))).on('dblclick', function(e){	   
		      var id = $(this).attr('id');
		      id = id.replace('outputtext', 'richtext');
		      ck_custom_editor.editorShow(id);	
		      CKEDITOR.instances[id].focus();   
		      $(this).hide();
		    }); 
	    }
	 }
   }	   
  },
  
  editorShow : function(id){
    var editor_id = 'cke_' + id;
    $(document.getElementById(editor_id)).show('slow', function(e){resetIframeHeight();});
    resetIframeHeight();
  },

  editorHide : function(id){
    var editor_id = 'cke_' + id;
    //debugger;
    $(document.getElementById(editor_id)).hide('slow', function(e){resetIframeHeight();});
  },
  
  editorHideWithoutEffect : function(id){
    var editor_id = 'cke_' + id;
    //debugger;
    $(document.getElementById(editor_id)).hide();
    resetIframeHeight();
  } 


}

var Typeahead_input = {
    searchKey : '',
    resourceUrl : '',
    searchinput_jQclientid : '#searchStr_ele',
    typeaheadmenu_selector: 'div.Typeahead-menu',
    typeaheadhint_selector: '.Typeahead-hint',
    selectedAssetsMap : {},
    rowCount : 0,
    resetFrameHeightWithTypeAheadEvents:function(isMenuOpen){
        var height = $(document.body).height();
        var height_addr = 15;
        var offsetHeight = $(Typeahead_input.searchinput_jQclientid).offset().top 
                                  + $(Typeahead_input.searchinput_jQclientid).height(); 
                                  //+ $(Typeahead_input.typeaheadmenu_selector).height();
        if(isMenuOpen){
            offsetHeight += $(Typeahead_input.typeaheadmenu_selector).height();
        }
        if(offsetHeight > height){
            height = offsetHeight;
        }
        parent.AddEditScope.setHeightOfEditScopeFrame(height  + height_addr, window.name);
    },
    load : function(){
        $('.Typeahead-input').typeahead({
            hint: $(Typeahead_input.typeaheadhint_selector),
            menu: $(Typeahead_input.typeaheadmenu_selector),
            highlight: true,    
            minLength: 3,
            classNames: {
              open: 'is-open',
              empty: 'is-empty',
              cursor: 'is-active',
              suggestion: 'Typeahead-suggestion',
              selectable: 'Typeahead-selectable'
            }
        },
        {
            name: 'assets',
            displayKey: 'name',
            limit: 10,
            source: function(query, syncResults, asyncResults){
                Typeahead_input.searchKey = query;
                var selectedAssets = Typeahead_input.getAlreadyAddedAssetsIds();
                //console.log(selectedAssets);
                sforce.apex.execute("E2_Estimator_WS", "searchAssets", {
                    searchStr: query, exisitingAssetIds : selectedAssets}, function(result){
                        if(result.length > 0) {
                          if(Typeahead_input.searchKey == result[0].searchKey){
                            var assetList = [];
                            if(typeof result[0].assetList != 'undefined'){
                                if((result[0].assetList).constructor === Array){
                                    assetList = result[0].assetList;
                                }else{
                                    assetList.push(result[0].assetList);
                                }
                            }
                            asyncResults(assetList);
                          }
                        }
                        else{
                            $('.Typeahead-spinner').hide();
                        }
                });
            },
            templates: {
                suggestion: function(data){
                    return Typeahead_input.prepareSuggestionTemplate(data);
                },
                notFound : function(){
                    return '<div class="EmptyMessage">Your search turned up 0 results.</div>';
                }
                
            }
        })
        .on('typeahead:select', function(ev, suggestion) {
            Typeahead_input.addRowToTable(suggestion);
            if(typeof Typeahead_input.selectedAssetsMap[suggestion.id] == 'undefined'){
                Typeahead_input.selectedAssetsMap[suggestion.id] = suggestion;
            }
            else{
                Typeahead_input.selectedAssetsMap[suggestion.id].isDeleted = 'false';    
            }
            $("input[Id$='existingAssetRecs']").val(JSON.stringify(Typeahead_input.selectedAssetsMap));
        })
        .on('typeahead:render', function(ev, suggestion, flag, dataset) {
            Typeahead_input.resetFrameHeightWithTypeAheadEvents(true);
        })
        .on('typeahead:open', function(ev, suggestion, flag, dataset) {
            Typeahead_input.resetFrameHeightWithTypeAheadEvents(true);
        })
        .on('typeahead:close', function(ev, suggestion, flag, dataset) {
            Typeahead_input.resetFrameHeightWithTypeAheadEvents(false);
        })
        .on('typeahead:asyncrequest', function() {
            $('.Typeahead-spinner').show();
        })
        .on('typeahead:asynccancel typeahead:asyncreceive', function() {        		
            $('.Typeahead-spinner').hide();
        });
    },
    
    prepareSuggestionTemplate : function(data){
        var returnHtmlStr = '<div class = "ProfileCard u-cf"><img class="ProfileCard-avatar" src="{resource_url}/images/{image_name}"/>';
        returnHtmlStr += '<div class="ProfileCard-details"><div class="ProfileCard-realName"><a onclick="Typeahead_input.goToAssetDetailPage(event, this);" href="/{id}" target="_blank">{asset_name}</a>';
        returnHtmlStr += '<img src="{resource_url}/images/{assettype_image_name}.png" title="{assettype_image_name} Asset" style="padding-left:10px;"/>'
        if(data.isRecommended == 'true'){
            returnHtmlStr += '<span style="margin-left: 5px; background-color:#FA9500;" class="slds-badge">Recommended</span>';
        }
        returnHtmlStr += '</div>';
        returnHtmlStr += '<div><div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Number of Reuses : </span>{asset_usage}</div>';
        returnHtmlStr += '<div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Release Stage : </span>{release_stage}</div></div>';
        returnHtmlStr += '<div class="ProfileCard-description">{description}</div></div>';
        returnHtmlStr += '<div class="ProfileCard-stats"><div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Primary Contributor : </span>{primarycontributors}</div>';
        returnHtmlStr += '<div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Technologies : </span>{technologies}</div></div></div>';
        
        returnHtmlStr = returnHtmlStr.replace(/{resource_url}/gi, Typeahead_input.resourceUrl)
                                     .replace(/{image_name}/gi, data.imageName)
                                     .replace(/{id}/gi, data.id)
                                     .replace(/{asset_name}/gi, data.assetName)
                                     .replace(/{assettype_image_name}/gi, data.assetTypeImage)
                                     .replace(/{asset_usage}/gi, data.assetUsage)
                                     .replace(/{release_stage}/gi, data.releaseStage)
                                     .replace(/{description}/gi, data.description)
                                     .replace(/{primarycontributors}/gi, data.primaryContributors)
                                     .replace(/{technologies}/gi, data.technologies);
        
        return returnHtmlStr;
    },
    
    addRowToTable : function(suggestion){
        var tableRowStr = '<tr id="{asset_id}"><td class="slds-truncate whitespace_normal"><a href="/{asset_id}" target="_blank">{asset_name}</a></td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">{description}</td>';
        //tableRowStr += '<td class="slds-truncate whitespace_normal">{technologies}</td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">{reuse_loe}</td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">{release_stage}</td>';
        tableRowStr += '<td class="slds-cell-shrink" data-label="Actions"><a onclick="Typeahead_input.removeAssetRow(\'{asset_id}\');return false" class="delete_button slds-button--right--float"/></td></tr>';
        
        tableRowStr = tableRowStr.replace(/{asset_id}/gi, suggestion.id)
                                 .replace(/{asset_name}/gi, suggestion.assetName)
                                 .replace(/{description}/gi, suggestion.description)
                                 //.replace(/{technologies}/gi, suggestion.technologies)
                                 .replace(/{reuse_loe}/gi, (suggestion.totalHours - suggestion.reuseLoe))
                                 .replace(/{release_stage}/gi, suggestion.releaseStage);
        
        if($('#noAssetRow') != null && $('#noAssetRow').length){
            Typeahead_input.removeNoAssetsRow();
        }
        
        $("#RecommendedAssetsTable tbody").append(tableRowStr);
        
        Typeahead_input.rowCount += 1;
        
        Typeahead_input.resetFrameHeightWithTypeAheadEvents(false);
    },
    
    goToAssetDetailPage : function(event, element){
    	// Don't propogate the event to the document
	    if (event.stopPropagation) {
	        event.stopPropagation();   // W3C model
	    } else {
	        event.cancelBubble = true; // IE model
	    } 
    },
    
    removeAssetRow : function(rowId){
        $('#'+rowId).remove();
        if(typeof Typeahead_input.selectedAssetsMap[rowId] != 'undefined'){
            Typeahead_input.selectedAssetsMap[rowId].isDeleted = 'true';
        }
        $("input[Id$='existingAssetRecs']").val(JSON.stringify(Typeahead_input.selectedAssetsMap));
        Typeahead_input.rowCount -= 1;
        
        if(Typeahead_input.rowCount === 0){
            Typeahead_input.addNoAssetsRow();
        }
        Typeahead_input.resetFrameHeightWithTypeAheadEvents(false);
    },
    
    getAlreadyAddedAssetsIds : function(){
        var existingAssetIds = [];
        $.each(Typeahead_input.selectedAssetsMap, function(index, element) {
            if(element.isDeleted == 'false'){
                existingAssetIds.push(element.id);
            }
        });
        return existingAssetIds;
    },
    
    retrieveExistingAssets : function(){
        //var existingAssets = $("input[Id$='existingAssetRecs']").val();
        //if(existingAssets.length == 0){
            sforce.apex.execute("E2_Estimator_WS", "getExistingAssetsForScope", {
                    scopeId: scope_sfdc_id}, function(result){
                        if(result.length > 0) {
                          var assetsRecsJson = result[0];
                          if (assetsRecsJson != null && assetsRecsJson != '' && assetsRecsJson.length > 0) {
                              Typeahead_input.prepareExistingAssetRows(assetsRecsJson);
                          }
                          else{
                              Typeahead_input.addNoAssetsRow();
                          }
                        }
                        else{
                            Typeahead_input.addNoAssetsRow();
                        }
                });
      // }
      // else{
      //     Typeahead_input.prepareExistingAssetRows(existingAssets);
      // }
    },
    
    prepareExistingAssetRows : function(assetsRecsJson){
        Typeahead_input.selectedAssetsMap = JSON.parse(assetsRecsJson);
        var hasValidAsset = false; 
        $.each(Typeahead_input.selectedAssetsMap, function(index, element) {
            if(element.isDeleted == 'false'){
                Typeahead_input.addRowToTable(element);
                hasValidAsset = true;
            }
        });
        
        var existingAssets = $("input[Id$='existingAssetRecs']").val();
        
        if(existingAssets.length !== 0){
            $.each(JSON.parse(existingAssets), function(index, element) {
                if(element.isDeleted == 'false' && typeof Typeahead_input.selectedAssetsMap[element.id] == 'undefined'){
                    Typeahead_input.addRowToTable(element);
                    hasValidAsset = true;
                }
            });
        }
        if(hasValidAsset){
            Typeahead_input.removeNoAssetsRow();
        }
        $("input[Id$='existingAssetRecs']").val(JSON.stringify(Typeahead_input.selectedAssetsMap));
    },
    
    addNoAssetsRow : function(){
        var rowStr = '<tr id="noAssetRow"><td colspan="5">No recommended assets!!!</td></tr>';
        $("#RecommendedAssetsTable tbody").append(rowStr);
    },
    
    removeNoAssetsRow : function(){
        $('#noAssetRow').remove();
    }
}

$( document ).ready(function() {
    showSpinner();
    validations.load();
    ck_custom_editor.load();
    bindSliders();
    Typeahead_input.load();
    Typeahead_input.retrieveExistingAssets();
    AddScopeTree.GenerateTree(scope_sfdc_id);
    hideSpinner();
    
    if(msg.toLowerCase() == 'success'){
       parent&&parent.AddEditScope&&parent.AddEditScope.closeEditScopeModelPopup&&parent.AddEditScope.closeEditScopeModelPopup();
       if($("input[id$='dmlMessage']").length) $("input[id$='dmlMessage']").val('Fail');
       parent&&parent.AddEditScope&&parent.AddEditScope.showSaveSuccessMessage&&parent.AddEditScope.showSaveSuccessMessage(scope_sfdc_id, scope_sfdc_name);
       resetIframeHeight();
    }else{     
      resetIframeHeight();
    }
    $("input:text, textarea").first().focus();
    
    $( window ).resize(function() {
         if ($(this).width() < 767) { 
           //resetIframeHeight();
           //console.log('in am in');
         }
    });
	
	$("[id$=allocationHrs]").change(function(){
        if($(this).val() != $(this).closest(".effortsColumn").find('input.oldhrs').val()) {
			$(this).closest(".effortsColumn").find("div.override-reason").show();
        }else {
        	$(this).closest(".effortsColumn").find("div.override-reason").hide();
        }
        resetIframeHeight();
	});    
});

var resetIframeHeight = function(){
  if(parent && parent.AddEditScope && parent.AddEditScope.setHeightOfEditScopeModal){
    parent.AddEditScope.setHeightOfEditScopeModal($(document.body).outerHeight());         
  }
  
  if(parent && parent.AddEditScope && parent.AddEditScope.setHeightOfEditScopeFrame){
	    parent.AddEditScope.setHeightOfEditScopeFrame($(document.body).outerHeight(), window.name);         
  }
}

function hideSpinner(){
    $('#loadingSpinner').hide();
    return false;
}

function showSpinner(){
    $('#loadingSpinner').show().css('height', $(document).outerHeight());
    return false;
}


var addUpdateScopes = function(){
  var validate1 = validateScopes();
  var validate2 = validateData();
  if(validate1 == false || validate2 == false){
    return false;
  }
  
  try{    
    showSpinner();
    AddOrUpdate();
  }catch(ex){
    alert(ex);
  }
  return false;
}


var bindSliders = function(){
 
  //$('a.effort_slide').bind('click', slideToggleEffort);
  //$('a.assumption_slide').bind('click', slideToggleAssumption);

}

var closeAllSlides = function(obj){
  var animation = 'slow';
  
  $('div.effortsdiv').not(obj).slideUp( animation , function() {   
    $(this).closest('tr').prev('tr').removeClass('slds-selection-background');
    $(this).closest('tr').prev('tr').first('td').find('[id$=slider_state]').val('');
    $(this).closest('tr').prev('tr').find('a').removeClass('slide_background-selection');
  });
  
  /*$('div.assumptionsdiv').not(obj).slideUp( animation , function() {    
    $(this).closest('tr').prev('tr').removeClass('slds-selection-background');
    $(this).closest('tr').prev('tr').first('td').find('[id$=slider_state]').val('');
    $(this).closest('tr').prev('tr').find('a').removeClass('slide_background-selection');
  });*/

}

var returnVal = true;
var returnVal_Scopes = true;
var validationTraverse = function(){
   
   if($(this).is(':visible') == true){
       
        $(this).first('table').find('tbody tr').each(function(){
			            $(this).find('td').each(function(){
										          if($(this).find('div.is-required').length > 0){             
										             $(this).find('div.is-required').removeClass('slds-has-error');
										             $(this).find('div.is-required').find('div.slds-form-element__help').hide();
										             if($(this).find('div.is-required input.slds-input').length > 0 && $(this).find('div.is-required input.slds-input').val() == ''){
										               $(this).find('div.is-required').addClass('slds-has-error');
										               $(this).find('div.is-required').find('div.slds-form-element__help').show();
										               returnVal = false;   
										             }   
										             if($(this).find('div.is-required select').length > 0 && $(this).find('div.is-required select').val() == ''){
										               $(this).find('div.is-required').addClass('slds-has-error');
										               $(this).find('div.is-required').find('div.slds-form-element__help').show();
										               returnVal = false;   
										             }
										             
										             if($(this).find('div.is-required textarea.slds-textarea').length > 0 && $(this).find('div.is-required textarea.slds-textarea').val() == ''){
										               $(this).find('div.is-required').addClass('slds-has-error');
										               $(this).find('div.is-required').find('div.slds-form-element__help').show();
										               returnVal = false;   
										             }           
										             
										          }   
				        });
			            var override_reason_div = $(this).find('div.override-reason');
			            
			            override_reason_div.find('div.slds-form-element__help').hide();
			            override_reason_div.removeClass('slds-has-error');
			            var  txt_area = $(this).find('div.override-reason input.slds-textarea.override-reason'); 
			            //alert(txt_area.length);
			            //alert($(this).find('div.is-required input.slds-input').val());
			            //alert($(this).find('input.oldhrs').val());
			            if(txt_area.length 
			                      && txt_area.val() == '' 
			                      && $(this).find('div.is-required input.slds-input').val() != $(this).find('input.oldhrs').val()){
			                      //oldhrs
			               override_reason_div.addClass('slds-has-error');
			               override_reason_div.find('div.slds-form-element__help').show();
			               returnVal = false;   
			            } 
			            
	  });
																	        
   } 
}

var validateData = function(){
  returnVal = true;
  
  $(document.body).find('div.effortsdiv').each(validationTraverse);
  //$(document.body).find('div.assumptionsdiv').each(validationTraverse);
  
  return returnVal;
}

var validateDataQuestion = function(){
  returnVal = true;
  
  $(document.body).find('div.questiondiv').each(validationTraverse);
  //$(document.body).find('div.assumptionsdiv').each(validationTraverse);
  
  return returnVal;
}


var validationTraverseForScopes = function(){
   
        $('table.scope-table tbody tr').each(function(){
			            $(this).find('td').each(function(){
			            	if($(this).find('div.is-required').length > 0){             
					             $(this).find('div.is-required').removeClass('slds-has-error');
					             $(this).find('div.is-required').find('div.slds-form-element__help').hide();
					             var input_ele = $(this).find('div.is-required input.slds-input') ;
					             if(input_ele.length > 0 && input_ele.val() == ''){
					               //$(this).find('div.is-required').addClass('slds-has-error');
					               input_ele.parent().parent().addClass('slds-has-error');
					               //$(this).find('div.is-required').find('div.slds-form-element__help').show();
					               input_ele.parent().parent().find('div.slds-form-element__help').show();
					               if(returnVal_Scopes == true) input_ele.focus();
					               returnVal_Scopes = false;   
					             } 
					             
					             var select_ele = $(this).find('div.is-required select'); 
					             if(select_ele.length > 0 && select_ele.val() == ''){
					               select_ele.parent().parent().addClass('slds-has-error');
					               select_ele.parent().parent().find('div.slds-form-element__help').show();
					               if(returnVal_Scopes == true) select_ele.focus();
					               returnVal_Scopes = false;   
					             }
					             
					             if($(this).find('div.is-required textarea.slds-textarea').length > 0 && $(this).find('div.is-required textarea.slds-textarea').val() == ''){
					               $(this).find('div.is-required').addClass('slds-has-error');
					               $(this).find('div.is-required').find('div.slds-form-element__help').show();
					               if(returnVal_Scopes == true) $(this).find('div.is-required textarea.slds-textarea').focus();
					               returnVal_Scopes = false;   
					             }
					          }   
				        });
	  });
																	        
   
}

var validateScopes = function(){
  returnVal_Scopes = true;
  validationTraverseForScopes();
  return returnVal_Scopes;
}


var slideToggleEffort = function(){
  if(validateData() == false){  
    return false;
  }  
  
  closeAllSlides($(this).closest('tr').next('tr').find('.effortsdiv'));
  $(this).closest('tr').addClass('slds-selection-background').next('tr').addClass('slds-selection-background');
  $(this).closest('tr').next('tr').find('.effortsdiv').slideToggle( "slow", function() {
    toggleActions($(this), 'effort');   
    resetIframeHeight(); 
  });  
}

var slideToggleAssumption = function(){
  if(validateData() == false){  
    return false;
  }

  closeAllSlides($(this).closest('tr').next('tr').find('.assumptionsdiv'));
  $(this).closest('tr').addClass('slds-selection-background').next('tr').addClass('slds-selection-background');
  $(this).closest('tr').next('tr').find('.assumptionsdiv').slideToggle( "slow", function() {    
    toggleActions($(this), 'assumption');
    resetIframeHeight();
  });
  
}

var toggleActions = function(jqObj, slide){
    if(jqObj.is(':visible') == false){    
       jqObj.closest('tr').prev('tr').removeClass('slds-selection-background');
       //if(slide == 'effort') jqObj.closest('tr').prev('tr').find('a.effort_slide').removeClass('slide_background-selection');       
       if(slide == 'assumption') jqObj.closest('tr').prev('tr').find('a.assumption_slide').removeClass('slide_background-selection');       
       jqObj.closest('tr').prev('tr').first('td').find('[id$=slider_state]').val('');
    }else{
       jqObj.closest('tr').prev('tr').addClass('slds-selection-background');
       jqObj.closest('tr').prev('tr').first('td').find('[id$=slider_state]').val(slide);
       //if(slide == 'effort') jqObj.closest('tr').prev('tr').find('a.effort_slide').addClass('slide_background-selection');
       if(slide == 'assumption') jqObj.closest('tr').prev('tr').find('a.assumption_slide').addClass('slide_background-selection');       
    }
    
    //jqObj.closest('tr').prev('tr').find('input.reloadbtn').click();
    
}
var AddEditQuestionAnswer = {
    showEditQuestionRow : function(id) {
        $("tr#"+id).each(function() {
            if($(this).hasClass( "table-row-display" ))
                $(this).removeClass('table-row-display');
            else
                $(this).addClass('table-row-display');
        });
        resetIframeHeight();
        return false;
    },
    checkSelectedQuestionType : function(that) {
        if($(that).val() != 'Summary') {
            $(that).next().click();
        }
        return false;
    },
    showActionAlert : function(element) {
        var elementTag;
        if($(element).is("select")) {
            elementTag = $('option:selected', element);
        } else if(($(element).is(":radio") || $(element).is(":checkbox")) && $(element).is(":checked")) {
            elementTag = $(element);
        }
        if(elementTag) { 
            var questionid = elementTag.attr('questionid');
            var action = elementTag.attr('action');
            var value = elementTag.attr('value');
            var loe = elementTag.attr('loe');
             if(action != '') {
                CustomAlert.show('Selected answer will perform following action : '+action);
                if(action == 'Change Complexity to Low') {
                    $('select.scope-complexity').val('Low');
                }else if(action == 'Change Complexity to Medium') {
                    $('select.scope-complexity').val('Medium');
                }else if(action == 'Change Complexity to High') {
                    $('select.scope-complexity').val('High');
                }
            }
            var  selectedAnswers = [];
            if($(element).is(":checkbox")) {
                var name = $(element).attr('name');
                $("input[name="+name+"]").each(function() {
                    if($(this).is(":checked"))
                        selectedAnswers.push($(this).attr('value'));
                });
            }else {
                selectedAnswers.push(value);
            }
            $('#'+questionid).find("input[id$=selectedAnswer]").val(selectedAnswers.toString());
        }
    },
    answerActionElement : null,
    showJSTree : function(that) {
        if($(that).val() == 'Deactivate child scope' || $(that).val() == 'Activate child scope') {
            AddEditQuestionAnswer.answerActionElement = that;
            AddScopeTree.updateTreeState();
            CustomAlert.showJSTree();
        }
        return false;
    },
    hideJSTree : function() {
        var bindedScopeIds = AddScopeTree.getselectedTreeNode();
        $(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val(bindedScopeIds);
        CustomAlert.hideJSTree();
        return false;
    }
}
var CustomAlert = {
    notifyContainerCssSelector: '.slds-notify_container',
    notifyCloseCssSelector: '.slds-notify__close',
    notifyMsgCssSelector: '.slds-text-heading--small',
    notifyTypeCssDiv: '#sldsalertdiv',
    notifyEditContainer: '.slds-edit-alert',
    notifyEditContainerbackdrop: '.slds-edit-alert-backdrop',
    notifyJSTreeHeadingCSS : '.slds-text-heading--small',
    notifyJSTreeHeading : 'Select child scope',
    showJSTree: function() {
        $(CustomAlert.notifyEditContainerbackdrop).show().css('height', $(document).outerHeight());
        $(CustomAlert.notifyJSTreeHeadingCSS).html(CustomAlert.notifyJSTreeHeading);
        $(CustomAlert.notifyEditContainer).show();
    },
    hideJSTree: function() {
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
	updateTreeState : function() {
	    var $node = $(treeId).jstree(true).get_node('#');
		$.each($node.children_d, function(indx, id) {
		    $(treeId).jstree(true).deselect_node(id);
	    });
	}
}