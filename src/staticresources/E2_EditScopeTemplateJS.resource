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

var typeahead_input = {
    searchKey : '',
    resourceUrl : '',
    selectedAssetsMap : {},
    load : function(){
        $('.Typeahead-input').typeahead({
            hint: $('.Typeahead-hint'),
            menu: $('.Typeahead-menu'),
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
            source: function(query, syncResults, asyncResults){
                typeahead_input.searchKey = query;
                var selectedAssets = typeahead_input.getAlreadyAddedAssets();
                //console.log(selectedAssets);
                sforce.apex.execute("E2_Estimator_WS", "searchAssets", {
                    searchStr: query, exisitingAssetIds : selectedAssets}, function(result){
                        if(result.length > 0) {
                          //console.log(result);
                          if(typeahead_input.searchKey == result[0].searchKey){
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
                    //console.log(data);
                    return typeahead_input.prepareSuggestionTemplate(data);
                },
                notFound : function(){
                    return '<div class="EmptyMessage">Your search turned up 0 results.</div>';
                }
                
            }
        })
        .on('typeahead:select', function(ev, suggestion) {
            typeahead_input.addRowToTable(suggestion);
            if(typeof typeahead_input.selectedAssetsMap[suggestion.id] == 'undefined'){
                typeahead_input.selectedAssetsMap[suggestion.id] = suggestion;
            }
            else{
                typeahead_input.selectedAssetsMap[suggestion.id].isDeleted = 'false';    
            }
            $("input[Id$='existingAssetIds']").val(JSON.stringify(typeahead_input.selectedAssetsMap));
        })
        .on('typeahead:render', function(ev, suggestion, flag, dataset) {
            var containerId = '#' + parent.AddEditScope.EDIT_SCOPE_INLINE_DIV_ID;
            parent.AddEditScope.setHeightOfEditScopeFrame($(document).height(), window.name);
        })
        .on('typeahead:asyncrequest', function() {
            $('.Typeahead-spinner').show();
        })
        .on('typeahead:asynccancel typeahead:asyncreceive', function() {        		
            $('.Typeahead-spinner').hide();
        });
    },
    
    prepareSuggestionTemplate : function(data){
        var returnHtmlStr = '<div class = "ProfileCard u-cf"><img class="ProfileCard-avatar" src="' + typeahead_input.resourceUrl + '/images/' + data.imageName + '"/>';
        returnHtmlStr += '<div class="ProfileCard-details"><div class="ProfileCard-realName"><a onclick="typeahead_input.goToAssetDetailPage(event, this);" href="/' + data.id + '" target="_blank">'+ data.assetName + '</a> <span class="slds-badge">' + data.assetUsage + '</span>';
        if(data.isRecommended == 'true'){
            returnHtmlStr += '<span style="margin-left: 5px; background-color:#FA9500;" class="slds-badge">Recommended</span>';
        }
        returnHtmlStr += '</div>';
        returnHtmlStr += '<div class="ProfileCard-description">' + data.description + '</div></div>';
        returnHtmlStr += '<div class="ProfileCard-stats"><div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Primary Contributor : </span>' + data.primaryContributors + '</div>';
        returnHtmlStr += '<div class="ProfileCard-stat"><span class="ProfileCard-stat-label">Technologies : </span>' + data.technologies + '</div></div></div>';
        return returnHtmlStr;
    },
    
    addRowToTable : function(suggestion){
        var tableRowStr = '<tr id="' + suggestion.id + '"><td class="slds-truncate whitespace_normal"><a href="/' + suggestion.id + '" target="_blank">' + suggestion.assetName + '</a></td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">' + suggestion.description + '</td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">' + suggestion.technologies + '</td>';
        tableRowStr += '<td class="slds-truncate whitespace_normal">' + (suggestion.totalHours - suggestion.reuseLoe) + '</td>';
        tableRowStr += '<td class="slds-cell-shrink" data-label="Actions"><a onclick="typeahead_input.removeAssetRow(\''+ suggestion.id + '\');return false" class="delete_button slds-button--right--float"/></td></tr>';    
        $("#RecommendedAssetsTable tbody").append(tableRowStr);
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
        if(typeof typeahead_input.selectedAssetsMap[rowId] != 'undefined'){
            typeahead_input.selectedAssetsMap[rowId].isDeleted = 'true';
        }
        $("input[Id$='existingAssetIds']").val(JSON.stringify(typeahead_input.selectedAssetsMap));
    },
    
    getAlreadyAddedAssets : function(){
        var existingAssetIds = [];
        $.each(typeahead_input.selectedAssetsMap, function(index, element) {
            if(element.isDeleted == 'false'){
                existingAssetIds.push(element.id);
            }
        });
        return existingAssetIds;
    },
    
    showTypeahead : function(){
        $('.Typeahead').show();
        $('#addAsset').hide();
    },
    
    hideTypeahead : function(){
        $('.Typeahead').hide();
        $('#addAsset').show();
    }
}

$( document ).ready(function() {
    showSpinner();
    validations.load();
    ck_custom_editor.load();
    bindSliders();
    hideSpinner();
    
    if(msg.toLowerCase() == 'success'){
       parent&&parent.AddEditScope&&parent.AddEditScope.closeEditScopeModelPopup&&parent.AddEditScope.closeEditScopeModelPopup();
       if($("input[id$='dmlMessage']").length) $("input[id$='dmlMessage']").val('Fail');
       parent&&parent.AddEditScope&&parent.AddEditScope.showSaveSuccessMessage&&parent.AddEditScope.showSaveSuccessMessage(scope_sfdc_id, scope_sfdc_name);
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