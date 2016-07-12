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