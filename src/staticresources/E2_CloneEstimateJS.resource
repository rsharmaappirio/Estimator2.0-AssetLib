  
    // Clone Estimate JS
    var ClonePresalesLOE = {
        ESTIMATE_ID : null,
        CLONED_ESITMATE_ID : null,
        CLONE_ESTIMATE_MODEL : "cloneModal",
        CLONE_ESTIMATE_MODEL_BAG : "cloneModaldrop2",
        CLONE_RADIO_NAME : "cloneTimeline",
        showCloneEstimatePopup : function() {
            $("#"+ClonePresalesLOE.CLONE_ESTIMATE_MODEL).show();
            $("#"+ClonePresalesLOE.CLONE_ESTIMATE_MODEL_BAG).show();
        },
        hideCloneEstimatePopup : function() {
            $("#"+ClonePresalesLOE.CLONE_ESTIMATE_MODEL).hide();
            $("#"+ClonePresalesLOE.CLONE_ESTIMATE_MODEL_BAG).hide();
        },
        cloneEstimate : function(estimateId) {
            // confirm from the user for this action first before actually 
            // starting the clone process. 
            if(!confirm('Are you sure to clone this estimate?')){
              return false;   
            }
            var partialClone = false;
            var cloneOption = $("[name="+ ClonePresalesLOE.CLONE_RADIO_NAME +"]:checked").val();
            if(cloneOption == "activeOnly") {
                partialClone = true;
            }
            $(loadingCloneSpinner.message_div_id).html("Cloning Estimate");
            loadingCloneSpinner.show();
            ClonePresalesLOE.ESTIMATE_ID = estimateId;
            
            var estimateJSON = '{"cloneFrom":"' + estimateId +  '", "partialClone":' + partialClone + ', "estimateIsActive":' + estimateIsActive + '}';
            ClonePresalesLOE.hideCloneEstimatePopup();
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimate", {
                estimateWrapperJSON: estimateJSON
            }, ClonePresalesLOE.cloneEstimate_callback);
            return false;
        },
        cloneEstimate_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                //if(result.indexOf('success') == -1) {
                   var resultJSON = JSON.parse(result);
                   ClonePresalesLOE.CLONED_ESITMATE_ID = resultJSON.newEstimateId;
                   ClonePresalesLOE.cloneScope(result); 
               // }
            },
            onFailure: function(error) {
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneScope : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Scopes");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateScopes", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneScope_callback);
        },
        cloneScope_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                if (result.indexOf('ScopeMapping') == -1) {
                    ClonePresalesLOE.cloneCapacity(result);
                } else {
                    result = result.replace("ScopeMapping","");
                    ClonePresalesLOE.reparentCloneScope(result);
                }
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        reparentCloneScope : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Scopes");
            sforce.apex.execute("E2_Clone_Estimate_WS", "reParentClonedScopes", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.reparentCloneScope_callback);
        },
        reparentCloneScope_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneCapacity(result);
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneCapacity : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Capacity");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateCapacity", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneCapacity_callback);
        },
        cloneCapacity_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneMilestone(result);
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneMilestone : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Estimate Milestones");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateMilestone", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneMilestone_callback);
        },
        cloneMilestone_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                if (result.indexOf('milestonemapping') == -1) {
                    console.log('test '+result);
                    ClonePresalesLOE.cloneTimeline(result);
                } else {
                    result = result.replace("milestonemapping","");
                    ClonePresalesLOE.cloneMilestoneWeek(result);
                }
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneMilestoneWeek : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Milestones Week");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneMilestoneWeeks", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneMilestoneWeek_callback);
        },
        cloneMilestoneWeek_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                console.log('test1 '+result);
                ClonePresalesLOE.cloneTimeline(result);
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneTimeline : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Resource Timeline");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateTimeline", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneTimeline_callback);
        },
        cloneTimeline_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                if (result.indexOf('success') != -1) {
                    CustomAlert.show('Estimate has been cloned successfully!!! Re-directing to cloned estimate.');
                    window.setTimeout( ClonePresalesLOE.reDirectToClonedEstimate, 1000);
                } else {
                    ClonePresalesLOE.cloneResourceWeek(result);
                }
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneResourceWeek : function(estimateWrapperJSON) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Resource Week");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneResourceWeeks", {
                estimateWrapperJSON: estimateWrapperJSON
            }, ClonePresalesLOE.cloneResourceWeek_callback);
        },
        cloneResourceWeek_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadingCloneSpinner.hide();
                    return ;
                }
                CustomAlert.show('Estimate has been cloned successfully!!! Re-directing to cloned estimate.');
                window.setTimeout( ClonePresalesLOE.reDirectToClonedEstimate, 1000);
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        deleteEstimate : function() {
            $(loadingCloneSpinner.message_div_id).html("Deleting Estimate");
            sforce.apex.execute("E2_Clone_Estimate_WS", "deleteEstimate", {
                estimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.deleteEstimate_callback);
        },
        deleteEstimate_callback : {
            onSuccess: function(result) {
                loadingCloneSpinner.hide();
            },
            onFailure: function(error) {
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        reDirectToClonedEstimate : function() {
            window.top.location.href = '/apex/E2_AddEditEstimate?id=' + ClonePresalesLOE.CLONED_ESITMATE_ID;
        }
        
    }
var loadingCloneSpinner = {
    client_id : '#loadingCloneSpinner',
    message_div_id : '#spinnerProcess',
    DEFAULT_MESSAGE : 'Preocessing',
    show: function(){
        $(loadingCloneSpinner.client_id).show().css('height', $(document).outerHeight());
    },
    
    hide: function(){
        $(loadingCloneSpinner.message_div_id).html(loadingCloneSpinner.DEFAULT_MESSAGE);
        $(loadingCloneSpinner.client_id).hide();
    }
}    