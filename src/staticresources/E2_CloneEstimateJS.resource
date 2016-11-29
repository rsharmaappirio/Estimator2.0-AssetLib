  
    // Clone Estimate JS
    var ClonePresalesLOE = {
        ESTIMATE_ID : null,
        CLONED_ESITMATE_ID : null,
        cloneEstimate : function(estimateId) {
            // confirm from the user for this action first before actually 
            // starting the clone process. 
            if(!confirm('Are you sure to clone this estimate?')){
              return false;   
            }
            $(loadingCloneSpinner.message_div_id).html("Cloning Estimate");
            loadingCloneSpinner.show();
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
                    loadingCloneSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.CLONED_ESITMATE_ID = result;
                ClonePresalesLOE.cloneScope();
            },
            onFailure: function(error) {
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneScope : function() {
            $(loadingCloneSpinner.message_div_id).html("Cloning Scopes");
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
                    loadingCloneSpinner.hide();
                    return ;
                }
                if (result.indexOf('success') != -1) {
                    ClonePresalesLOE.cloneCapacity();
                } else {
                    ClonePresalesLOE.reparentCloneScope(result);
                }
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        reparentCloneScope : function(resultString) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Scopes");
            sforce.apex.execute("E2_Clone_Estimate_WS", "reParentClonedScopes", {
                clonedSourceJSON: resultString,
                newEstimateId: ClonePresalesLOE.CLONED_ESITMATE_ID
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
                ClonePresalesLOE.cloneCapacity();
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneCapacity : function() {
            $(loadingCloneSpinner.message_div_id).html("Cloning Capacity");
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
                    loadingCloneSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneMilestone();
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneMilestone : function() {
            $(loadingCloneSpinner.message_div_id).html("Cloning Estimate Milestones");
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
                    loadingCloneSpinner.hide();
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
                loadingCloneSpinner.hide();
            }
        },
        cloneMilestoneWeek : function(resultString) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Milestones Week");
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
                    loadingCloneSpinner.hide();
                    return ;
                }
                ClonePresalesLOE.cloneTimeline();
            },
            onFailure: function(error) {
                ClonePresalesLOE.deleteEstimate();
                alert(clone_error_message);
                loadingCloneSpinner.hide();
            }
        },
        cloneTimeline : function() {
            $(loadingCloneSpinner.message_div_id).html("Cloning Resource Timeline");
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
        cloneResourceWeek : function(resultString) {
            $(loadingCloneSpinner.message_div_id).html("Cloning Resource Week");
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