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
            limit: 20,
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
        var tableRowStr = '<tr id="{asset_id}"><td data-label="Asset Name" class="slds-truncate whitespace_normal"><a href="/{asset_id}" target="_blank">{asset_name}</a></td>';
        tableRowStr += '<td data-label="Short Descripition" class="slds-truncate whitespace_normal">{description}</td>';
        //tableRowStr += '<td data-label="Technologies" class="slds-truncate whitespace_normal">{technologies}</td>';
        tableRowStr += '<td data-label="Hours Saved" class="slds-truncate whitespace_normal">{reuse_loe}</td>';
        tableRowStr += '<td data-label="Release Stage" class="slds-truncate whitespace_normal">{release_stage}</td>';
        tableRowStr += '<td class="slds-cell-shrink" data-label="Actions"><a onclick="Typeahead_input.removeAssetRow(\'{asset_id}\');return false" class="delete_button slds-button--right--float"/></td></tr>';
        
        tableRowStr = tableRowStr.replace(/{asset_id}/gi, suggestion.id)
                                 .replace(/{asset_name}/gi, suggestion.assetName)
                                 .replace(/{description}/gi, suggestion.description)
                                 //.replace(/{technologies}/gi, suggestion.technologies)
                                 .replace(/{reuse_loe}/gi, (suggestion.totalHours - suggestion.reuseLoe))
                                 .replace(/{release_stage}/gi, suggestion.releaseStage);
        
        if($('#noAssetRow') !== null && $('#noAssetRow').length){
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
    
    populatedSelectedAssetMap : function(suggestions, isWebServiceRecord){
        $.each(JSON.parse(suggestions), function(index, element) {
                if(typeof Typeahead_input.selectedAssetsMap[element.id] == 'undefined'){ 
                    if(isWebServiceRecord || (!isWebServiceRecord && element.isExisting != 'true'))
                        Typeahead_input.selectedAssetsMap[element.id] = element;
                }
                else if(Typeahead_input.selectedAssetsMap[element.id].isDeleted == 'false' && element.isDeleted == 'true'){
                    Typeahead_input.selectedAssetsMap[element.id].isDeleted = 'true';
                }
        });
    },
    
    retrieveExistingAssets : function(){
       Typeahead_input.selectedAssetsMap = {};
       sforce.apex.execute("E2_Estimator_WS", "getExistingAssetsForScope", 
                            {scopeId: scope_sfdc_id}, function(result){
            if(result !== null && result.length > 0) {
                var assetsRecsJson = result[0];
                if (assetsRecsJson !== null && assetsRecsJson !== '' && assetsRecsJson.length > 0) {
                      Typeahead_input.prepareExistingAssetRows(assetsRecsJson);
                }
                else{
                      Typeahead_input.prepareExistingAssetRows(null);
                }
            }
            else{
                Typeahead_input.addNoAssetsRow();
            }
       });
    },
    
    prepareExistingAssetRows : function(assetsRecsJson){
        var existingAssets = $("input[Id$='existingAssetRecs']").val();
        
        if(assetsRecsJson !== null && assetsRecsJson.length !== 0){
            Typeahead_input.populatedSelectedAssetMap(assetsRecsJson, true);
        }
        
        if(existingAssets !== null && existingAssets.length !== 0){
            Typeahead_input.populatedSelectedAssetMap(existingAssets, false);
        }
        
        var hasValidAsset = false; 
        $.each(Typeahead_input.selectedAssetsMap, function(index, element) {
            if(element.isDeleted == 'false'){
                Typeahead_input.addRowToTable(element);
                hasValidAsset = true;
            }
        });
        
        if(hasValidAsset){
            Typeahead_input.removeNoAssetsRow();
        }
        else{
            Typeahead_input.addNoAssetsRow();
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
    //Typeahead_input.load();
    //Typeahead_input.retrieveExistingAssets();
    //Question JS
    $('#' + AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).attr('src', '/apex/E2_ScopeTree?Id='+scope_sfdc_id);
    //AddEditQuestionAnswer.bindEvent();
    tabpanel.bindEvents();
    resetIframeHeight();
    //Question JS
    hideSpinner();
    
    if(msg.toLowerCase() == 'success'){
       //parent&&parent.AddEditScope&&parent.AddEditScope.closeEditScopeModelPopup&&parent.AddEditScope.closeEditScopeModelPopup();
       if($("input[id$='dmlMessage']").length) $("input[id$='dmlMessage']").val('Fail');
       parent&&parent.AddEditScope&&parent.AddEditScope.updateChildScopeOnParentScopeEdit&&parent.AddEditScope.updateChildScopeOnParentScopeEdit(scope_sfdc_id, scope_sfdc_name, changeComplexity, scopeToActivate, scopeToDeactivate);
       //parent&&parent.AddEditScope&&parent.AddEditScope.showSaveSuccessMessage&&parent.AddEditScope.showSaveSuccessMessage(scope_sfdc_id, scope_sfdc_name);
       window.setTimeout(function() {
            resetIframeHeight();
        }, 2000);
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
	
	$('.Typeahead-input').keydown(function(event){
        if(event.keyCode == 13){
            event.preventDefault();
            return false;
        }
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
  if(validateDataQuestion() == false) {
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
// Question 
var returnQVal
var validateDataQuestion = function(){
  returnQVal = true;
  $(document.body).find('div#QuestionanswerDiv').each(validationQuestionTraverse);
  return returnQVal;
}
var validationQuestionTraverse = function(){
    
    $(this).find('div.slds-col--padded').each(function(){
        if($(this).find('div.is-required').length > 0){             
		    $(this).find('div.is-required').removeClass('slds-has-error');
			$(this).find('div.is-required').find('div.slds-form-element__help').hide();
			if($(this).find('div.is-required input.slds-input').length > 0 && $(this).find('div.is-required input.slds-input').val() == ''){
			    $(this).find('div.is-required').addClass('slds-has-error');
				$(this).find('div.is-required').find('div.slds-form-element__help').show();
				returnQVal = false;   
			}   
			if($(this).find('div.is-required select').length > 0 && $(this).find('div.is-required select').val() == ''){
			    $(this).find('div.is-required').addClass('slds-has-error');
				$(this).find('div.is-required').find('div.slds-form-element__help').show();
				returnQVal = false;   
			}
			if($(this).find('div.is-required textarea.slds-textarea').length > 0 && $(this).find('div.is-required textarea.slds-textarea').val() == ''){
			    $(this).find('div.is-required').addClass('slds-has-error');
				$(this).find('div.is-required').find('div.slds-form-element__help').show();
				returnQVal = false;   
			}           
		}   
	});
}
var AddEditQuestionAnswer = {
    SCOPE_TREE_IFRAME_ID : 'scopeTreeIframe',
    setHeightOfEditScopeModal: function(height) {
        if ($('#' + AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).length) {
            $('#' + AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).css('height', height + 'px');
        }
    },
    bindEvent : function() {
        $("[id$=questionText]").on('dblclick', function() {
            var id = $(this).attr('id');
            var questionInput = id.replace('questionText', 'questionInput');
            var answerText = id.replace('questionText', 'answerText');
            var answerInput = questionInput.replace('questionInput', 'answerInput');
                $(document).find("[id$=answerInput]").not("#"+answerInput).not("#answerInput").hide();
                $(document).find("[id$=answerText]").not("#"+answerText).not("#answerText").show();
                $(document).find("[id$=questionInput]").not("#"+questionInput).not("#questionInput").hide();
                $(document).find("[id$=questionText]").not(this).not("#questionText").show("fast", function() {
                    AddEditQuestionAnswer.updateQuestionContent(this);
                });
            $("#"+answerInput).show();
            $("#"+answerText).hide();
            $(this).siblings( "#"+questionInput ).show();
            $(this).hide();
            resetIframeHeight();
        });
    },
    editQuestion : function(id) {
        var questionInput = id.replace('questionText', 'questionInput');
        var answerText = id.replace('questionText', 'answerText');
        var answerInput = questionInput.replace('questionInput', 'answerInput');
        $(document).find("[id$=answerInput]").not("#"+answerInput).not("#answerInput").hide();
        $(document).find("[id$=answerText]").not("#"+answerText).not("#answerText").show();
        $(document).find("[id$=questionInput]").not("#"+questionInput).not("#questionInput").hide();
        $(document).find("[id$=questionText]").not(this).not("#questionText").show("fast", function() {
            AddEditQuestionAnswer.updateQuestionContent(this);
        });
        $("#"+answerInput).show();
        $("#"+answerText).hide();
        $("#"+id).siblings( "#"+questionInput ).show();
        $("#"+id).hide();
        resetIframeHeight();
    },
    hideQuestionEditDiv : function(id) {
        var questionText = id.replace('questionInput', 'questionText');
        var that = "#"+questionText;
        var answerText = questionText.replace('questionText', 'answerText');
        var answerInput = id.replace('questionInput', 'answerInput');
        AddEditQuestionAnswer.updateQuestionContent(that);
        $(that).show();
        $("#"+id).hide();
        $("#"+answerInput).hide();
        $("#"+answerText).show();
        resetIframeHeight();
    },
    updateQuestionContent : function(that) {
        var id = $(that).attr('id');
        var questionInput = id.replace('questionText', 'questionInput');
        var answerText = id.replace('questionText', 'answerText');
        var answerInput = questionInput.replace('questionInput', 'answerInput');
        var questionUpdatedValue = $("#"+questionInput).find("input[id$=questionValue]").val();
        var question = '<strong>Question</strong>  '+questionUpdatedValue;
        if(questionUpdatedValue.indexOf('?') == -1) {
            question += '?';
        }
        $(that).find("span#text").html(question);
        $("#"+answerInput).find("[id$=answerEditDiv]").each(function(answerText){
            var action = $(this).find("select[id$=answerAction]").val();
            var value = $(this).find("input[id$=answerValue]").val();
            var loe = $(this).find("input[id$=answerLOE]").val();
            var answerId = $(this).attr('id').replace('answerEditDiv', '');
            $("#"+answerId).attr( "action", action );
            $("#"+answerId).attr( "loe", loe );
            $("#"+answerId+'Text').html( value );
        });
    },
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
        $(that).next().click();
        return false;
    },
    showActionAlert : function(element) {
        var elementTag;
        if($(element).is("select")) {
            elementTag = $('option:selected', element);
        } else if(($(element).is(":radio") || $(element).is(":checkbox"))) {
            elementTag = $(element);
        }
        if(elementTag) { 
            var questionid = elementTag.attr('questionid');
            var action = elementTag.attr('action');
             if(action != '' && (($(element).is(":radio") || $(element).is(":checkbox")) && $(element).is(":checked"))) {
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
                if(!$(element).is(":radio") || $(element).is(":checked")) {
                    selectedAnswers.push($(element).attr('value'));
                }
            }
            $('#'+questionid+'answerText').find("input[id$=selectedAnswer]").val(selectedAnswers.toString());
        }
    },
    answerActionElement : null,
    showJSTree : function(that) {
        if($(that).val() == 'Deactivate child scope' || $(that).val() == 'Activate child scope') {
            AddEditQuestionAnswer.answerActionElement = that;
            CustomAlert.showJSTree();
            document.getElementById(AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).contentWindow.AddScopeTree.updateTreeState($(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val());
        }else {
            var displayAnswerDivId = $(that).attr("displayAnswerDivId");
            $("#"+displayAnswerDivId).hide();
        }
        return false;
    },
     showJSTreeEdit : function(id) {
        AddEditQuestionAnswer.answerActionElement = $("#"+id).find("select[id$=answerAction]");
        CustomAlert.showJSTree();
        document.getElementById(AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).contentWindow.AddScopeTree.updateTreeState($(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val());
    },
    hideJSTree : function() {
        var bindedScopeIds = document.getElementById(AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).contentWindow.AddScopeTree.getselectedTreeNode();
        var scopeNameString = '<span class="slds-float-left" style="font-weight:bold;">Selected scopes : </span>';
        var selectedScopesNames = document.getElementById(AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).contentWindow.AddScopeTree.getselectedTreeNodeNames();
        var displayAnswerDivId = $(AddEditQuestionAnswer.answerActionElement).attr("displayAnswerDivId");
        if(selectedScopesNames && selectedScopesNames.length) {
            $.each(selectedScopesNames, function(indx, name) {
                scopeNameString += '<span class="slds-badge slds-theme--default slds-float-left slds-custom-badge-background-grey" style="font-weight:bold;">'+name+'</span>';
            });
        } else {
            alert("Child scopes required for selected answer action.");
            return false;
        }
        var id = displayAnswerDivId.replace('ActionScopes', 'answerEditDiv');
         scopeNameString += '<a class="edit-button1 slds-button--right--float" href="javascript:void(0);" onclick="AddEditQuestionAnswer.showJSTreeEdit(\''+id+'\');"> </a>';
        
        $("#"+displayAnswerDivId).html(scopeNameString);
        if(selectedScopesNames && selectedScopesNames.length) {
            $("#"+displayAnswerDivId).show();
        }else {
            $("#"+displayAnswerDivId).hide();
        }
        $(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val(bindedScopeIds);
        console.log($(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val());
        CustomAlert.hideJSTree();
        return false;
    },
    cancelAnswerAction : function() {
        var bindedScope = $(AddEditQuestionAnswer.answerActionElement).next("[id$=bindedScopes]").val();
        var displayAnswerDivId = $(AddEditQuestionAnswer.answerActionElement).attr("displayAnswerDivId");
        if(bindedScope == '') {
            $(AddEditQuestionAnswer.answerActionElement).val('');
            $("#"+displayAnswerDivId).hide();
        }
        CustomAlert.hideJSTree();
        return false;
    }
}
var CustomAlert = {
    notifyEditContainer: '.slds-edit-alert',
    notifyEditContainerbackdrop: '.slds-edit-alert-backdrop',
    notifyJSTreeHeadingCSS : '.slds-text-heading--small',
    notifyJSTreeHeading : 'Select child scope',
    showJSTree: function() {
        if(document.getElementById(AddEditQuestionAnswer.SCOPE_TREE_IFRAME_ID).contentWindow.AddScopeTree.hasChildScope == true) {
            $(CustomAlert.notifyEditContainerbackdrop).show().css('height', $(document).outerHeight());
            $(CustomAlert.notifyJSTreeHeadingCSS).html(CustomAlert.notifyJSTreeHeading);
            $(CustomAlert.notifyEditContainer).show();
        } else {
           alert('No child scope under current scope hierarchy');
        }
    },
    hideJSTree: function() {
        $(CustomAlert.notifyEditContainer).hide();
        $(CustomAlert.notifyEditContainerbackdrop).hide();
    }
}
var tabpanel = {
    assetloaded : 0,
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
                  $('#'+ $(this).find('a').attr('aria-controls'));
                  $('#'+ $(this).find('a').attr('aria-controls')).siblings('.slds-tabs--default__content').removeClass('slds-show');
			      $('#'+ $(this).find('a').attr('aria-controls')).siblings('.slds-tabs--default__content').addClass('slds-hide');
		          $(this).addClass('slds-active');
			      $(this).find('a').attr('aria-selected', true);
			      $('#'+ $(this).find('a').attr('aria-controls')).removeClass('slds-hide');
			      $('#'+ $(this).find('a').attr('aria-controls')).addClass('slds-show');
			      if($(this).attr('title')=='Recommended Assets' && tabpanel.assetloaded == 0) {
			            Typeahead_input.load();
			            Typeahead_input.retrieveExistingAssets();
			            tabpanel.assetloaded = 1;
			      }
			      $(this).siblings().removeClass('slds-active');
			      $(this).siblings().find('a').attr('aria-selected', false);
			      resetIframeHeight();
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
        
    }
}
var EditScope = {
    ADD_BULK_EFFORTS_FRAME_ID : 'bulkEffortIframe',
    
    addEfforts: function() {
        var func = document.getElementById(EditScope.ADD_BULK_EFFORTS_FRAME_ID).contentWindow.prepareJson;
        if (typeof func != 'undefined') {
            func();
        }
    },
    
    updateAddEffortsJson: function(jsonStr){
        $("input[Id$='effortsJson']").val(jsonStr);
        addBulkEfforts();
        EditScope.hideAddBulkEffortsModal();
    },
    
    addBulkEfforts_click : function(obj){
        EditScope.showAddBulkEffortsModal();
        return false;
    },
    
    showAddBulkEffortsModal : function(){
        $('#helpModal').show();
        $('#helpModal').find('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).attr('src', '/apex/E2_AddBulkEfforts');
        $('#helpModal').find('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop').css({'height' : $(window.document).height()});
        $('#helpBackdrop').show();
    },
    
    hideAddBulkEffortsModal: function() {
        $('#helpModal').hide();
        $('#helpModal').find('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).attr('src', 'about:blank');
        $('#helpModal').find('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).closest('div.slds-modal__content').scrollTop(0);
        $('#helpBackdrop').hide();
    },
    
    setHeightOfAddNewModal: function(height) {
        if ($('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).length) {
            $('#' + EditScope.ADD_BULK_EFFORTS_FRAME_ID).css('height', height + 'px');
        }
    }
}