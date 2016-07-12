  var AddEditDerivedEffort = {
    SELECT_TEMPLATE_IFRAME_ID : 'theIframeTemplate', 
    addfromtemplate_click : function(obj) {
        AddEditDerivedEffort.showAddFromTemplateModal();
        return false;
    },
    showAddFromTemplateModal : function(){
      $('#helpModal').show();
      $('#helpModal').find('#' + AddEditDerivedEffort.SELECT_TEMPLATE_IFRAME_ID).attr('src', '/apex/E2_SelectDerivedEffortTemplate');
      $('#helpBackdrop').show();
      return false;
   },
   addNewEffort : function() {
    var selectedIds = document.getElementById(AddEditDerivedEffort.SELECT_TEMPLATE_IFRAME_ID).contentWindow.dEffortsGroups.selectedEfforts();
    if(selectedIds == ''){
      alert('No Derived Effort being selected for Apply');  
      return;                 
    }                  
    /*var ans = confirm('Are you sure you want to apply selected Derived Effort Template?');
    if(ans == false){
      return;
    }*/
    $("[id$=deffortTemplateId]").val(selectedIds);
    $("[id$=clonedEfforts]").click();
    //AddEditDerivedEffort.hideAddFromTemplateModal();
  },
   hideAddFromTemplateModal : function(){
      $('#helpModal').hide();
      $('#helpModal').find('#' + AddEditDerivedEffort.SELECT_TEMPLATE_IFRAME_ID).attr('src', 'about:blank');
      $('#helpBackdrop').hide(); 
   }
  }
  /*var tooltipModal = {
  	showtip : function(div) {
  		var tooltip = '<div id="tooltipcontent" class="slds-popover slds-popover--tooltip slds-nubbin--bottom" role="tooltip" style="position: absolute; text-align: left; width: 11rem; left: -20px; top: -40px;">'+
			  '<div class="slds-popover__body">Derived Effort cloned from<br/>template can not be editted.</div>'+
			'</div>';
		$(div).append(tooltip);
  	},
  	hidetip : function() {
  		$("#tooltipcontent").replaceWith("");
  	}
  }*/