//on dome ready
$(function() {
    
    // lets handle the positioning of menu list of timelines 
    // when window scroll position change and utility bar scroll position change
    $(window).scroll(TimelineSummary.windowScrollHandler);
    $('.slds-utility-bar').scroll(TimelineSummary.utilityBarScrollHandler);
    $(window).resize(TimelineSummary.windowResizeHandler);
    if(customerMode == 'true') {
	    $("#addNew_button").prop('disabled', true);	  
    }
    TimelineDevCapacity.domReady();
    TimelineSummary.bind_events();
    TimelineSummary.open_timeline_onload();
    tabpanel.bindEvents();
});
// on timeline tab
var TimelineSummary = {
    SLDS_DOCK_OPEN : "slds-is-open",
    TIMELINE_PANEL : "#timeline_panel",
    ACTIVE_TIMELINE_TAB : "slds-is-active",
    UTILITY_BAR_ACTION : "bar_action",
    UTILITY_BAR_TEXT : "timelinename_text",
    ADD_EDIT_TIMELINE_DIV : "timeline_div",
    TIMELINE_HEADING : "timeline_heading",
    TIMELINE_PAGE : "E2_ResourceTimeline",
    CUSTOMER_PAGE : "E2_CustomerTimeline",
    ENDS_WITH : "TIMELINE",
    TIMELINE_TEXT_FIELD_END_WITH : "_text",
    TIMELINE_MENU_CLASS : ".slds-timeline_menu",
    CLICKS : 0,
    CLICK_EVENT : null,
    CLICKED_BUTTON : null,
    TIMELINE_NAME_ARR : [],
    windowResizeHandler: function(){
        TimelineSummary.resizeUtilityPanel();
    },
    windowScrollHandler: function(){
        TimelineSummary.positionTimelineListMenu(); 
    },
    utilityBarScrollHandler: function(){
        TimelineSummary.positionTimelineListMenu(); 
    },
    utilityTabTextEventHandler: function(event){
            if(event.keyCode == 13 || event.keyCode == 9) {
              TimelineSummary.TIMELINE_NAME_ARR = [];
              $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").each(function() {
                TimelineSummary.TIMELINE_NAME_ARR.push($(this).html());
              });
              console.log(TimelineSummary.TIMELINE_NAME_ARR);
              var label_id = $(this).attr("id").replace(TimelineSummary.TIMELINE_TEXT_FIELD_END_WITH, '');
              if($(this).val() != "" && $(this).attr("title") != $(this).val()) {
                  if($.inArray($(this).val(), TimelineSummary.TIMELINE_NAME_ARR ) != -1) {
                        alert("A timeline with the name \"" + $(this).val() + "\" already exists. Please enter another name.");
                        return false;
                  }
                  updateTimelineName( $(this).attr("timelineId"), $(this).val());
                  $('#'+label_id).attr("title",$(this).val());
                  $('#'+label_id).html($(this).val());
                  if($(this).attr("title") == $("#"+TimelineSummary.TIMELINE_HEADING).html()) {
                      $("#"+TimelineSummary.TIMELINE_HEADING).html($(this).val());
                  }
                  $(this).attr("title",$(this).val());
                  $( "div[name='" + $(this).attr("timelineId") + "']" ).children( ".timeline_name" ).html($(this).val());
                  $( "div[name='" + $(this).attr("timelineId") + "']" ).attr("title",$(this).val());
              } else {
                  $(this).val($(this).attr("title"));
              }
              $(this).hide();
              $('#'+label_id).show();
              return false;
            }
    },
    
    bind_events : function () {
        $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").bind('click', function(e){
            $(TimelineSummary.TIMELINE_MENU_CLASS).hide();
            TimelineSummary.CLICKS++;  //count clicks
            if(TimelineSummary.CLICKS === 1) {
                //$("input[name='timelinename_text']").hide();
                //$("input[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").show();
                TimelineSummary.CLICKED_BUTTON = this;
                TimelineSummary.CLICK_EVENT = setTimeout(function() {
                    TimelineSummary.commitCurrentEditOnTimeline();
                    // if clicks is still 1 then display the timeline
                    if(TimelineSummary.CLICKS === 1){
                        TimelineSummary.displayTimeline(TimelineSummary.CLICKED_BUTTON);
                        TimelineSummary.updateTimelineName();
                        TimelineSummary.CLICKS = 0;
                    }
                    
                    
                    //TimelineSummary.displayTimeline(TimelineSummary.CLICKED_BUTTON);
                    //TimelineSummary.updateTimelineName();
                    //TimelineSummary.CLICKS = 0;
                    
                }, 200);
            } else if(TimelineSummary.CLICKS === 2){
                clearTimeout(TimelineSummary.CLICK_EVENT);    //prevent single-click action
                if(customerMode != 'true') {
                    TimelineSummary.commitCurrentEditOnTimeline();
                    // functionality to perform on dblclick
                    TimelineSummary.updateTimelineName();
                    TimelineSummary.CLICKED_BUTTON = null;
                    TimelineSummary.CLICKS = 0;
                    var textId =  $(this).attr("id") + TimelineSummary.TIMELINE_TEXT_FIELD_END_WITH;
                    var textBox = $('#'+textId);
                    $(this).hide();
                    textBox.show();
                    var value = textBox.val();
                    var size  = value.length;
                    // playing with the size attribute
                    //$(this).attr('size',size);
                    
                    if(!isNaN(size)){
                        // playing css width
                        size = size*2; // average width of a char
                        textBox.css('width',size*3);
                    }
                    if(textBox.length) textBox.focus(); textBox.select();
                } else {
                    TimelineSummary.displayTimeline(TimelineSummary.CLICKED_BUTTON);
                    TimelineSummary.CLICKS = 0;
                }
            }
            return false;
        });
        
        $("input[name='"+TimelineSummary.UTILITY_BAR_TEXT+"']").bind('keydown', TimelineSummary.utilityTabTextEventHandler);
        $("input[name='"+TimelineSummary.UTILITY_BAR_TEXT+"']").bind('change', TimelineSummary.utilityTabTextEventHandler);
        
        
        $(window).click("mousedown", function(e){
            TimelineSummary.commitCurrentEditOnTimeline();
            TimelineSummary.updateTimelineName();
             var $eventTarget = $(e.target);
            if(!$eventTarget.hasClass("slds-button--list") && 
                !$eventTarget.hasClass("slds-timeline_menu") && 
                !$eventTarget.parent(TimelineSummary.TIMELINE_MENU_CLASS).length){
                $(TimelineSummary.TIMELINE_MENU_CLASS).hide();
            } 
        });
        
        $("input[name='"+TimelineSummary.UTILITY_BAR_TEXT+"']").bind('click',function(e) {
            e.stopPropagation(); // This is the preferred method.
            return false;        // This should not be used unless you do not want
                                 // any click events registering inside the element
        });
        
        $("input[name='"+TimelineSummary.UTILITY_BAR_TEXT+"']").bind('keyup',function(e){
            var value = $(this).val();
                var size  = value.length;
                // playing with the size attribute
                //$(this).attr('size',size);
                
                // playing css width
                size = size*2; // average width of a char
                $(this).css('width',size*3);
        });
        $(".menu").bind('click',function(e) {
           TimelineSummary.showhideTimelines();
           $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").removeClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
           $( ".menu" ).children( ".menu_checkbox" ).hide();
           var element = $(this);
           element.children( ".menu_checkbox" ).show();
           $( "button[timelineId='" + element.attr("timelineId") + "']" ).addClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
           TimelineSummary.open_timeline(element);
           return false;
        });
    },
    open_timeline_onload : function() {
        var hasActive = false;
        $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").each(function() {
            loadingSpinner.show();
            var element = $(this);
            var isActive = element.attr("isActive");
            if(isActive == "true") {
                hasActive = true;
                element.addClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
                $( "div[name='" + element.attr("timelineId") + "']" ).children( ".menu_checkbox" ).show();
                TimelineSummary.open_timeline(element);
                return false;
            }
        });
        if(!hasActive) {
            loadingSpinner.hide();
        }
    },
    open_timeline : function(element){
        var selectedEstimate = element.attr("timelineId");
        var timelineName = element.attr("title");
        TimelineSummary.appendIFRAME(selectedEstimate);
        $("#"+TimelineSummary.TIMELINE_HEADING).html(timelineName);
        var isActive = element.attr("isActive");
        if(isActive == "true") {
            $("#activate_button").hide();
            $("#deactivate_button").show();
        } else {
            $("#activate_button").show();
            $("#deactivate_button").hide();
        }
        $("#deactivate_button").attr("timelineId", selectedEstimate);
        $("#activate_button").attr("timelineId", selectedEstimate);
        $("#clone_button").attr("timelineId", selectedEstimate);
        $("#delete_button").attr("timelineId", selectedEstimate);
        $("#delete_button").attr("isActive", isActive);
        if(selectedEstimate == estimateId)  $("#delete_button").hide();
        else $("#delete_button").show();
        if(customerMode == 'true') {
		    $("#delete_button").hide();
		    $("#clone_button").hide();
		    $("#activate_button").hide();
		    $("#deactivate_button").hide();
		}
        $(TimelineSummary.TIMELINE_PANEL).addClass(TimelineSummary.SLDS_DOCK_OPEN);
        TimelineSummary.resizeUtilityPanel();
    },
    updateTimelineName : function() {
        TimelineSummary.TIMELINE_NAME_ARR = [];
        $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").each(function() {
            TimelineSummary.TIMELINE_NAME_ARR.push($(this).html());
        });
        $("input[name='"+TimelineSummary.UTILITY_BAR_TEXT+"']").each(function() {
                var hasError = false;
                var element = $(this);
                if(element.is(":visible")) {
                    var label_id = element.attr("id").replace(TimelineSummary.TIMELINE_TEXT_FIELD_END_WITH, '');
                    if(element.val() != "" && element.attr("title") != element.val()) {
                        if($.inArray($(this).val(), TimelineSummary.TIMELINE_NAME_ARR ) != -1) {
                            alert("A timeline with the name \"" + element.val() + "\" already exists. Please enter another name.");
                            hasError = true;
                        } else {
                            $( "div[name='" + element.attr("timelineId") + "']" ).children( ".timeline_name" ).html(element.val());
                            $( "div[name='" + element.attr("timelineId") + "']" ).attr("title",element.val());
                            updateTimelineName( element.attr("timelineId"), element.val());
                            $('#'+label_id).attr("title",element.val());
                            $('#'+label_id).html(element.val());
                            if(element.attr("title") == $("#"+TimelineSummary.TIMELINE_HEADING).html()) {
                                $("#"+TimelineSummary.TIMELINE_HEADING).html(element.val());
                            }
                            element.attr("title",element.val());
                        }
                    }
                    if(!hasError) {
                        element.hide();
                        $('#'+label_id).show();
                    }
                    return false;
                }
            });
    },
    minimizeTimeline : function() {
        $(TimelineSummary.TIMELINE_PANEL).removeClass(TimelineSummary.SLDS_DOCK_OPEN);
        return false;
    },
    displayTimeline : function(element) {
        $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").removeClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
        $(element).addClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
        TimelineSummary.open_timeline($(element));
        $( ".menu" ).children( ".menu_checkbox" ).hide();
        $( "div[name='" + $(element).attr("timelineId") + "']" ).children( ".menu_checkbox" ).show();
        return false;
    },
    appendIFRAME : function(selectedEstimate){
        var containerId = "#" + TimelineSummary.ADD_EDIT_TIMELINE_DIV;
	   var endsWith = TimelineSummary.ENDS_WITH;
	   var frame_id = '#' + selectedEstimate + endsWith;
	   var frame_id_standard = selectedEstimate + endsWith;
	   
	   if($(containerId).length){
		   $(containerId).find("iframe[id$='" + endsWith + "']").not(frame_id).hide(1, function() {});
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
    			   $(frame_id).show(1, function() {
    				   // whenever element is shown again; re-set the height with the dom content
    				   $(this).css({ 'min-height':'400px',width:'100%',margin:'0px', height : $(this.contentWindow.document).height()});
    				   $(frame_id).focus();
    			   });
		       }
		       loadingSpinner.hide();
		   }else{
		       loadingSpinner.show();
		       var pageName = TimelineSummary.TIMELINE_PAGE;
		       if(customerMode == 'true') {
		          pageName = TimelineSummary.CUSTOMER_PAGE;
		      }
		       // if iframe doesn't exist than create a new iframe for that scope
		       $('<iframe>', {
				   src: '/apex/'+ pageName +'?id=' + selectedEstimate,
				   id:  selectedEstimate + endsWith,
				   name: selectedEstimate + endsWith,
				   frameborder: 0,
				   scrolling: 'yes',
				   style : 'height:100%;width:100%;margin:0px',
				   class : 'slds-card'
				   }).appendTo(containerId);
				   
			   setTimeout(function(){
                    loadingSpinner.hide();
                  },  3000);
		   }
		   
		   
	   }
	   
    },
    refreshTimelineEstimates_Complete : function(newTimelineId) {
        loadingSpinner.show();
        var element = $("button[timelineId='" + newTimelineId +"']");
         element.addClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
         $( ".menu" ).children( ".menu_checkbox" ).hide();
         $( "div[name='" + $(element).attr("timelineId") + "']" ).children( ".menu_checkbox" ).show();
         TimelineSummary.open_timeline(element);
         TimelineSummary.bind_events();
         //loadingSpinner.hide();
    },
    updateTimelieState : function(element, status) {
        if($("#activeTimelineCount").val() == 1 && status == false) {
            alert("Atleast one timeline should remain active.");
            return false;
        }
        loadingSpinner.show();
        var timelineId = $(element).attr("timelineId");
        updateTimelineStatus(timelineId, status);
        return false;
    },
    updateTimelineStatus_Complete : function(newTimelineId) {
        loadingSpinner.show();
        var element = $("button[timelineId='" + newTimelineId +"']");
         element.addClass(TimelineSummary.ACTIVE_TIMELINE_TAB);
         $( ".menu" ).children( ".menu_checkbox" ).hide();
         $( "div[name='" + $(element).attr("timelineId") + "']" ).children( ".menu_checkbox" ).show();
         TimelineSummary.open_timeline(element);
         TimelineSummary.bind_events();
         loadingSpinner.hide();
    },
    showhideTimelines : function(source) {
        TimelineSummary.positionTimelineListMenu();
        $(TimelineSummary.TIMELINE_MENU_CLASS).toggle();
        return false;
    }, 
    hideTimelineListMenu: function(){
        $(TimelineSummary.TIMELINE_MENU_CLASS).hide();
    },
    positionTimelineListMenu: function(){
        //console.log($('.custom-positioner-menu-list').offset().top);
        $(TimelineSummary.TIMELINE_MENU_CLASS).css('top', $('.custom-positioner-menu-list').offset().top - $(TimelineSummary.TIMELINE_MENU_CLASS).outerHeight());
        $(TimelineSummary.TIMELINE_MENU_CLASS).css('left', $('.custom-positioner-menu-list').offset().left);
    },
    resizeUtilityPanel: function(){
        var heightAdjustment = 75;
        $('.slds-utility-panel').height(($(window).height() - $('.slds-utility-bar_container').height()) - heightAdjustment);
        TimelineSummary.resizeTabHeights();
    },
    resizeTabHeights: function(){
      var heightAdjustment = 75;    
      var topHeight = $('#tab-default-1__item').offset().top + $('#tab-default-1__item').height(); 
      var bottomHeight = $('.slds-utility-bar_container').height();
      $('#tab-default-1').css('overflow-y', 'auto');
      $('#tab-default-1').height($(window).height() - (topHeight + bottomHeight + heightAdjustment));
      
    },
    refreshTimelineSummaryOnUpdate: function() {
        rerenderTimelineSummary();
    },
    updateTimelineNameInIFrame: function(newTimelineId) {
        var element = $("button[timelineId='" + newTimelineId +"']");
        var newName = element.html();
        var endsWith = TimelineSummary.ENDS_WITH;
	    var frame_id = '#' + newTimelineId + endsWith;
	    var frame_id_standard = newTimelineId + endsWith;
        if($(frame_id).length) {
            var frameWin = document.getElementById(frame_id_standard).contentWindow;
            if(typeof frameWin != 'undefined' && typeof frameWin.Timeline != 'undefined' && typeof frameWin.Timeline.updateTimelineName == 'function'){
                frameWin.Timeline.updateTimelineName(newName);
            }
        }
    },
    commitCurrentEditOnTimeline: function() {
        $("button[name='"+TimelineSummary.UTILITY_BAR_ACTION+"']").each(function() {
            var timelineId = $(this).attr("timelineId");
            var endsWith = TimelineSummary.ENDS_WITH;
    	    var frame_id = '#' + timelineId + endsWith;
    	    var frame_id_standard = timelineId + endsWith;
            if($(frame_id).length) {
                var frameWin = document.getElementById(frame_id_standard).contentWindow;
                if(typeof frameWin != 'undefined' && typeof frameWin.Slick != 'undefined' && typeof frameWin.Slick.GlobalEditorLock.commitCurrentEdit == 'function'){
                    frameWin.Slick.GlobalEditorLock.commitCurrentEdit();
                }
            }
        });
    }
}
// Clone Estimate and 
var ClonePresalesLOE = {
        cloneNewTimeline : function(element) {
            //alert('coneTimlineCalled');
            var timelineId = $(element).attr("timelineId");
            // confirm from the user for this action first before actually 
            // starting the clone process. 
            $(TimelineSummary.TIMELINE_MENU_CLASS).hide();
            var timelineVersion = $("#timelinecount").val();
            var selectedTimelineName = $("#"+TimelineSummary.TIMELINE_HEADING).html();
            var timelineName = 'Copy of '+selectedTimelineName;
            $(loadingSpinner.message_div_id).html("Cloning timeline");
            loadingSpinner.show();
            var isNewTimeline = false;
            var timelineJSON = '[{"cloneFrom":"' + timelineId +  '", "currencyISOCode":"' + currency_code + '", "parentTimelineId":"' + estimateId + '", "isNewTimeline":' + isNewTimeline + ',"timelineName":"' +timelineName+ '"}]';
//console.log(timelineJSON);
            ClonePresalesLOE.ESTIMATE_ID = estimateId;
            sforce.apex.execute("E2_Clone_Estimate_WS", "createNewTimeline", {
                timelineJSON: timelineJSON
            }, ClonePresalesLOE.createOrCloneTimeline_callback);
            return false;
        },
        createNewTimeline : function(timelineId) { 
            //alert('createNewTimlineCalled');
            // confirm from the user for this action first before actually 
            // starting the clone process. 
            $(TimelineSummary.TIMELINE_MENU_CLASS).hide();
            if(!confirm('Are you sure to add new timeline?')) {
              return false;   
            }
            var timelineVersion = $("#timelinecount").val();
            var timelineName = 'Timeline v'+timelineVersion;
            $(loadingSpinner.message_div_id).html("Creating new timeline");
            loadingSpinner.show();
            var isNewTimeline = true;
             var timelineJSON = '[{"cloneFrom":"' + timelineId +  '", "currencyISOCode":"' + currency_code + '", "parentTimelineId":"' + estimateId + '", "isNewTimeline":' + isNewTimeline + ',"timelineName":"' +timelineName+ '"}]';
            //console.log(timelineJSON);
            ClonePresalesLOE.ESTIMATE_ID = estimateId;
            sforce.apex.execute("E2_Clone_Estimate_WS", "createNewTimeline", {
                timelineJSON: timelineJSON
            }, ClonePresalesLOE.createOrCloneTimeline_callback);
            return false;
        },
        createOrCloneTimeline_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingSpinner.hide();
                    return ;
                }
                var resultJSON = JSON.parse(result);
                if (resultJSON[0].isNewTimeline == 'true' || resultJSON[0].isNewTimeline === true) {
                    //ClonePresalesLOE.cloneTimelineRateCards(result);
                    refreshTimelineEstimates(resultJSON[0].newTimelineId);
                } else {
                    ClonePresalesLOE.cloneTimeline(result);
                }
            },
            onFailure: function(error) {
                alert(error);
                loadingSpinner.hide();
            }
        },
        cloneTimeline : function(timelineJSON) {
            //$(loadingSpinner.message_div_id).html("Cloning Resource Timeline");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneTimelineVersion", {
                timelineJSON: timelineJSON
            }, ClonePresalesLOE.cloneTimeline_callback);
        },
        cloneTimeline_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingSpinner.hide();
                    return ;
                }
                if (result.indexOf('success') != -1) {
                    refreshTimelineEstimates(result.replace('success',''));
                } else {
                    ClonePresalesLOE.cloneResourceWeek(result);
                }
            },
            onFailure: function(error) {
                alert(error);
                loadingSpinner.hide();
            }
        },
        cloneResourceWeek : function(timelineJSON) {
            //$(loadingSpinner.message_div_id).html("Cloning Resource Week");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneResourceWeeksTimelineVersion", {
                timelineJSON: timelineJSON
            }, ClonePresalesLOE.cloneResourceWeek_callback);
        },
        cloneResourceWeek_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingSpinner.hide();
                    return ;
                }
                //console.log('refresh after add');
                refreshTimelineEstimates(result);
            },
            onFailure: function(error) {
                alert(error);
                loadingSpinner.hide();
            }
        },
        cloneTimelineRateCards : function(timelineJSON) {
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneTimelineRateCards", {
                timelineJSON : timelineJSON
            }, ClonePresalesLOE.cloneTimelineRateCards_callback);
        },
        cloneTimelineRateCards_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingSpinner.hide();
                    return ;
                }
                var resultJSON = JSON.parse(result);
                refreshTimelineEstimates(resultJSON[0].newTimelineId);
            },
            onFailure: function(error) {
                alert(error);
                loadingSpinner.hide();
            }
        },
        deleteTimeline : function(element) {
            var isActive = $(element).attr("isActive");
            if($("#activeTimelineCount").val() == 1 && isActive == "true") {
                alert("Can not delete only active timeline.");
                return false;
            }
            if(!confirm('Are you sure to delete timeline?')) {
              return false;   
            }
            var timelineId = $(element).attr("timelineId");
            //console.log(timelineId);
            $(loadingSpinner.message_div_id).html("Deleting Timeline");
            loadingSpinner.show();
            sforce.apex.execute("E2_Clone_Estimate_WS", "deleteEstimate", {
                estimateId: timelineId
            }, ClonePresalesLOE.deleteTimeline_callback);
        },
        deleteTimeline_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingSpinner.hide();
                    return ;
                }
                refreshTimelineEstimates(estimateId);
                //loadingSpinner.hide();
            },
            onFailure: function(error) {
                alert(error);
                loadingSpinner.hide();
            }
        }
}
var loadingSpinner = {
    client_id : '#loadingCloneSpinner',
    message_div_id : '#spinnerProcess',
    DEFAULT_MESSAGE : 'Processing',
    show: function(){
        $(loadingSpinner.client_id).show().css('height', $(document).outerHeight());
    },
    
    hide: function(){
        $(loadingSpinner.message_div_id).html(loadingSpinner.DEFAULT_MESSAGE);
        $(loadingSpinner.client_id).hide();
    }
} 
var WEBSERVICE_NAME = "E2_TimelineWS";
var TimelineDevCapacity = {
   json: {}, 
   hoursPerWeek: 0,
   DEV_CAPACITY_PER_DAY_ID : '#devhoursperday',
   domReady : function() {
       
     $(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).keydown(function(event){
        if(event.keyCode == 13) {
          event.stopPropagation();    
          event.preventDefault();
          TimelineDevCapacity.onChange_InputDevHoursPerWeek();
          return false;
        }        
    });
     TimelineDevCapacity.applyNumericValidation();
     TimelineDevCapacity.generateSummarySection();
     TimelineDevCapacity.load();  
   },
   applyNumericValidation : function(){
	   $('.mandate-numeric').keyup(function(evt) {		    
		    //$('body div.slds-error--tooltip').remove();
		    var inputVal = $(this).val();
		    //var numericReg = /^\d*[0-9](|.\d*[0-9]|,\d*[0-9])?$/;
		    // var numericReg = /^[0-9]+\.?[0-9]*$/;
		    var numericReg = /^[0-9]*$/;
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
   
   load: function(){
     var hours = 0;
     if($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val() != '' && !isNaN($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val())) hours = parseInt($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val());
     TimelineDevCapacity.calcuateHoursPerWeek(hours);
     TimelineDevCapacity.updatejsonWithWeeks();
     TimelineDevCapacity.renderSummarySection();
   },
   
   generateSummarySection: function(){
      delete TimelineDevCapacity.json;
	  TimelineDevCapacity.json = {};
      var phaseHoursSum = 0;
	  var weekSum = 0;
      for(var _a in capacityNeeds_JSON){
	     if(_a == 'PhaseHours'){			    
			for(var _b in capacityNeeds_JSON[_a]){
			   TimelineDevCapacity.json[_b] = {};
			   var phaseHours = typeof capacityNeeds_JSON[_a][_b] != 'undefined' ? parseInt(capacityNeeds_JSON[_a][_b]) : 0;
			   TimelineDevCapacity.json[_b]['Hours'] = phaseHours;
			   TimelineDevCapacity.json[_b]['Weeks'] = 0;
			   phaseHoursSum += phaseHours;
			   
			}				
		 }		  
	  }
	  
	  TimelineDevCapacity.json['Total'] = {};
	  TimelineDevCapacity.json['Total']['Hours'] = phaseHoursSum;
	  TimelineDevCapacity.json['Total']['Weeks'] = weekSum;
	  
   },
   
   renderSummarySection: function(){
       var html = '';
       document.getElementById('summaryTbody').innerHTML = html;
	   for(var _c in TimelineDevCapacity.json){
	     html +=  '<tr '+ (_c.toLowerCase() == 'total' ? 'style="font-weight:bold;"' : '') + '>';
	     html +=  '<td>' + _c.toUpperCase() + '</td>';
		 html +=  '<td>' + TimelineDevCapacity.json[_c]['Hours'] + '</td>';
		 html +=  '<td>' + TimelineDevCapacity.json[_c]['Weeks'] + '</td>';
		 html +=  '</tr>';			 
	   }
	   document.getElementById('summaryTbody').innerHTML = html;
   },
   
   calcuateHoursPerWeek: function(devHours){
       var totalHours = capacityNeeds_JSON["TotalHours"];
       var role_json = capacityNeeds_JSON['RoleHours'];
	   var hoursPerDay = 0;
	   var hoursPerWeek = 0;
	   var validate = false;
	   // check that developer hours exists and is greater than 0
	   if(typeof role_json['developer'] != 'undefined' && parseInt(role_json['developer']) > 0){
	      validate = true;
	   } 
	   if(validate == true){
		   for(var _a in role_json){
			  if(_a != 'developer'){
			       var roleHours = isNaN(parseInt(role_json[_a])) ? 0 : parseInt(role_json[_a]);
			       var hours = (Math.round(roleHours/parseInt(totalHours)) * parseInt(devHours));
				   hoursPerDay += isNaN(hours) ? 0 : hours;
			  }			  
		   }
		   hoursPerDay += parseInt(devHours);
		   hoursPerWeek = hoursPerDay * 5;
		   TimelineDevCapacity.hoursPerWeek = parseInt(hoursPerWeek);
		   document.getElementById('hoursperweekdiv').innerHTML = hoursPerWeek;
       }
   },
   
   updatejsonWithWeeks: function(){
       var _weekSum = 0;    
       for(var _c in TimelineDevCapacity.json){
            if(_c.toLowerCase() != 'total'){
    	     	var phaseHour = parseInt(TimelineDevCapacity.json[_c]['Hours']);
                TimelineDevCapacity.json[_c]['Weeks'] = TimelineDevCapacity.hoursPerWeek > 0 ? Math.round(phaseHour/TimelineDevCapacity.hoursPerWeek) : 0;
                
                if(TimelineDevCapacity.json[_c]['Weeks'] < 1 && phaseHour > 0 && TimelineDevCapacity.hoursPerWeek > 0){
                      TimelineDevCapacity.json[_c]['Weeks'] = 1;
                }
                
                _weekSum += parseInt(TimelineDevCapacity.json[_c]['Weeks']);
                //console.log(_weekSum);
            }
	   }
	   
	  //TimelineDevCapacity.json['Total'] = {};
	  //TimelineDevCapacity.json['Total']['Hours'] = phaseHoursSum;
	  TimelineDevCapacity.json['Total']['Weeks'] = _weekSum;
	  //console.log(TimelineDevCapacity.json);
   },
   
   onChange_InputDevHoursPerWeek: function(){
       loadingSpinner.show();
       var hours = 0;
       if($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val() != '' && !isNaN($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val())) hours = parseInt($(TimelineDevCapacity.DEV_CAPACITY_PER_DAY_ID).val());
       sforce.apex.execute(WEBSERVICE_NAME, "updateDevCapacity", {
            estimateId : estimateId,
            devCapacity: hours
        }, TimelineDevCapacity.onChange_InputDevHoursPerWeek_Callback);
       
   },
   
   onChange_InputDevHoursPerWeek_Callback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                    alert(result);
                loadingSpinner.hide();
                return;
            }
            TimelineDevCapacity.load();
            loadingSpinner.hide();
        },
        onFailure: function(error) {
            alert(error);
            loadingSpinner.hide();
        }
    }
}
var tabpanel = {
    containerId : '#tabpanel',
    timeline_tabId : '#tab-default-1__item',
    ratecard_tabId : '#tab-default-2__item',
    contentToShow : null,
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
                  tabpanel.contentToShow = $('#'+ $(this).find('a').attr('aria-controls'));
                  $(this).addClass('slds-active');
			      $(this).find('a').attr('aria-selected', true);
			      tabpanel.contentToShow.removeClass('slds-hide');
			      tabpanel.contentToShow.addClass('slds-show');			
			      $(this).siblings().removeClass('slds-active');
			      $(this).siblings().find('a').attr('aria-selected', false);
			      tabpanel.contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			      tabpanel.contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
			      
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