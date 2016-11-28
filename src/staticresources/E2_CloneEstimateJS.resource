  
    // Clone Estimate JS
    var ClonePresalesLOE = {
        ESTIMATE_ID : null,
        CLONED_ESITMATE_ID : null,
        cloneEstimate : function(estimateId) {
            $(loadSpinner.message_div_id).html("Cloning Estimate");
            loadSpinner.show();
            ClonePresalesLOE.ESTIMATE_ID = estimateId;
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimate", {
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
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        cloneScope : function() {
            $(loadSpinner.message_div_id).html("Cloning Scopes");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateScopes", {
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
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        cloneCapacity : function() {
            $(loadSpinner.message_div_id).html("Cloning Capacity");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateCapacity", {
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
                ClonePresalesLOE.cloneMilestone();
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        cloneMilestone : function() {
            $(loadSpinner.message_div_id).html("Cloning Estimate Milestones");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateMilestone", {
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
                if (result.indexOf('success') != -1) {
                    ClonePresalesLOE.cloneTimeline();
                } else {
                    ClonePresalesLOE.cloneMilestoneWeek(result);
                }
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        cloneMilestoneWeek : function(resultString) {
            $(loadSpinner.message_div_id).html("Cloning Milestones Week");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneMilestoneWeeks", {
                milestoneWeekJSON: resultString,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneMilestoneWeek_callback);
        },
        cloneMilestoneWeek_callback : {
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
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        cloneTimeline : function() {
            $(loadSpinner.message_div_id).html("Cloning Resource Timeline");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneEstimateTimeline", {
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
                loadSpinner.hide();
            }
        },
        cloneResourceWeek : function(resultString) {
            $(loadSpinner.message_div_id).html("Cloning Resource Week");
            sforce.apex.execute("E2_Clone_Estimate_WS", "cloneResourceWeeks", {
                resourceWeekJSON: resultString,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.cloneResourceWeek_callback);
        },
        cloneResourceWeek_callback : {
            onSuccess: function(result) {
                result = (result.length > 0 ? result[0] : result); 
                if (result.indexOf('Fail') != -1) {
                    alert(result);
                    loadSpinner.hide();
                    return ;
                }
                CustomAlert.show('Estimate has been cloned successfully!!! Re-directing to cloned estimate.');
                window.setTimeout( ClonePresalesLOE.reDirectToClonedEstimate, 1000);
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        deleteEstimate : function() {
            $(loadSpinner.message_div_id).html("Deleting Estimate");
            sforce.apex.execute("E2_Clone_Estimate_WS", "deleteEstimate", {
                estimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
            }, ClonePresalesLOE.deleteEstimate_callback);
        },
        deleteEstimate_callback : {
            onSuccess: function(result) {
                loadSpinner.hide();
            },
            onFailure: function(error) {
                alert(clone_error_message);
                loadSpinner.hide();
            }
        },
        reDirectToClonedEstimate : function() {
            window.top.location.href = '/apex/E2_AddEditEstimate?id=' + ClonePresalesLOE.CLONED_ESITMATE_ID;
        }
        
    }
var loadSpinner = {
    client_id : '#loadingCloneSpinner',
    message_div_id : '#spinnerProcess',
    DEFAULT_MESSAGE : 'Preocessing',
    show: function(){
        $(loadSpinner.client_id).show().css('height', $(document).outerHeight());
    },
    
    hide: function(){
        $(loadSpinner.message_div_id).html(loadSpinner.DEFAULT_MESSAGE);
        $(loadSpinner.client_id).hide();
    }
}    