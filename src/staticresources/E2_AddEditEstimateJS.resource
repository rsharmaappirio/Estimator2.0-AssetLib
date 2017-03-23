 var AddEditEstimate = {
    DASHBOARD_ID : 'theIframeDashboard',
    setHeightOfDashboard: function(height){	
	   if($('#' + AddEditEstimate.DASHBOARD_ID).length){
	     $('#' + AddEditEstimate.DASHBOARD_ID).css('height', height + 'px');
	   }
	},
	
	//Added for set primary functionality : Vikash Goyal : 12/9/2016
	setPrimary: function(estimateId, psrId){
	    $(loadSpinner).show().css('height', $(document).outerHeight());
	    sforce.apex.execute("CMC_PresalesEstimate", "setPrimary", {
                newPrimaryId: estimateId,
                psrId:psrId
        }, AddEditEstimate.setPrimary_callback);
        return false;
	},
	
	setPrimary_callback : {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result); 
            if (result.indexOf('Fail') != -1) {
                alert(result);
                $(loadSpinner).hide();
                return ;
            }
            CustomAlert.show('The estimate has been set as primary!!!');
            $(loadSpinner).hide();
            
            //To hide the set primary button and update primary checkbox as checked once set primary button is clicked on estimate
            $("input[id*=setPrimaryBtn]").hide();
            $("[id*=isPrimaryFlag]").find("img").attr("src", "/img/checkbox_checked.gif");
            $("[id*=isPrimaryInputHidden]").val(true);
        },
        onFailure: function(error) {
            alert(error);
            $(loadSpinner).hide();
        }
    }
  }
  
  var loadSpinner = '#loadingCloneSpinner';
  
  var CustomAlert = {
        notifyContainerCssSelector : '.slds-notify_container',
        notifyCloseCssSelector : '.slds-notify__close',
        notifyMsgCssSelector : '.slds-text-heading--small',
        notifyContainerSavePanelId : '#savePanel',
        show : function(msg){    
          $(CustomAlert.notifyContainerSavePanelId).css({ 'opacity' : '100', 'display' : 'block'}).css('z-index', 99999);   
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