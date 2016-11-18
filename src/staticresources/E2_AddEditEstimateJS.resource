 var AddEditEstimate = {
    DASHBOARD_ID : 'theIframeDashboard',
    setHeightOfDashboard: function(height){	
	   if($('#' + AddEditEstimate.DASHBOARD_ID).length){
	     $('#' + AddEditEstimate.DASHBOARD_ID).css('height', height + 'px');
	   }
	}
  }
  
  var CustomAlert = {
        notifyContainerCssSelector : '.slds-notify_container',
        notifyCloseCssSelector : '.slds-notify__close',
        notifyMsgCssSelector : '.slds-text-heading--small',
        notifyContainerSavePanelId : '#savePanel',
        show : function(msg){    
          $(CustomAlert.notifyContainerSavePanelId).css({ 'opacity' : '100', 'display' : 'block'});   
          $(CustomAlert.notifyContainerSavePanelId).find(CustomAlert.notifyMsgCssSelector).text(msg);
          $(CustomAlert.notifyContainerSavePanelId).find(CustomAlert.notifyCloseCssSelector).unbind( "click" );   
          $(CustomAlert.notifyContainerSavePanelId).find(CustomAlert.notifyCloseCssSelector).bind( "click", function() {        
              $(CustomAlert.notifyContainerSavePanelId).stop( true, true ).fadeTo().slideUp();        
              return false;
          });         
          window.setTimeout(function() {
            if($(CustomAlert.notifyContainerSavePanelId).is(":visible")){
                  $(CustomAlert.notifyContainerSavePanelId).fadeTo(500, 0).slideUp(500, function(){
                      $(this).hide(); 
                  });
            }  
          }, 2000);
        },  
        hide : function(){  
           $(CustomAlert.notifyContainerSavePanelId).hide();
        }  
    } 
  
    $( document ).ready(function() {
        $("li").each(function( index ) {
            if($(this).html().indexOf("Presales LOE Name: You must enter a value") != -1) {
                $(this).replaceWith("");
            }
        });
        if(is_save == 'true' && has_errors == 'false'){
           CustomAlert.show('Estimate has been saved successfully!!!');
        }                    
    });
    
    // Clone Estimate JS
    var ClonePresalesLOE = {
        ESTIMATE_ID : null,
        CLONED_ESITMATE_ID : null,
        cloneEstimate : function(estimateId) {
            $(loadSpinner.message_div_id).html("Cloning Estimate");
            loadSpinner.show();
            ClonePresalesLOE.ESTIMATE_ID = estimateId;
            sforce.apex.execute("E2_Estimator_WS", "cloneEstimate", {
                estimateId: estimateId
            }, ClonePresalesLOE.cloneEstimate_callback);
            return false;
        },
        cloneEstimate_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.CLONED_ESITMATE_ID = result;
                ClonePresalesLOE.cloneScope();
            },
            onFailure: function(error) {
                alert(error);
                loadSpinner.hide();
            }
        },
        cloneScope : function() {
            $(loadSpinner.message_div_id).html("Cloning Scopes");
            sforce.apex.execute("E2_Estimator_WS", "cloneEstimateScopes", {
                estimateId: ClonePresalesLOE.ESTIMATE_ID,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneScope_callback);
        },
        cloneScope_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneCapacity();
            },
            onFailure: function(error) {
                alert(error);
                loadSpinner.hide();
            }
        },
        cloneCapacity : function() {
            $(loadSpinner.message_div_id).html("Cloning Capacity");
            sforce.apex.execute("E2_Estimator_WS", "cloneEstimateCapacity", {
                estimateId: ClonePresalesLOE.ESTIMATE_ID,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneCapacity_callback);
        },
        cloneCapacity_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneTimeline();
                //ClonePresalesLOE.cloneMilestone();
            },
            onFailure: function(error) {
                alert(error);
                loadSpinner.hide();
            }
        },
        cloneMilestone : function() {
            $(loadSpinner.message_div_id).html("Cloning Estimate Milestones");
            sforce.apex.execute("E2_Estimator_WS", "cloneEstimateMilestone", {
                estimateId: ClonePresalesLOE.ESTIMATE_ID,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneMilestone_callback);
        },
        cloneMilestone_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneTimeline();
            },
            onFailure: function(error) {
                alert(error);
                loadSpinner.hide();
            }
        },
        cloneTimeline : function() {
            $(loadSpinner.message_div_id).html("Cloning Resource Timeline");
            sforce.apex.execute("E2_Estimator_WS", "cloneEstimateTimeline", {
                estimateId: ClonePresalesLOE.ESTIMATE_ID,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneTimeline_callback);
        },
        cloneTimeline_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                window.location.href = '/apex/E2_AddEditEstimate?id=' + ClonePresalesLOE.CLONED_ESITMATE_ID;
            },
            onFailure: function(error) {
                alert(error);
                loadSpinner.hide();
            }
        }
    }
var loadSpinner = {
    client_id : '#loadingSpinner',
    message_div_id : '#spinnerProcess',
    DEFAULT_MESSAGE : 'Preocessing',
    show: function(){
        $(loadSpinner.client_id).show().css('height', $(document).outerHeight()).css('z-index', 99999);
    },
    
    hide: function(){
        $(loadSpinner.message_div_id).html(loadSpinner.DEFAULT_MESSAGE);
        $(loadSpinner.client_id).hide();
    }
}    