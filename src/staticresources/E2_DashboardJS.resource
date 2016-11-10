var renderTooltipStacked = function(data , item) {
	this.setTitle(item.yField+ ' : ' + item.value[1]);
}
var report_onclick = function(reportId){
	window.top.location = '/' + reportId;
	return false;
}        
var resetIframeHeight = function(){
	if(parent && parent.AddEditEstimate && parent.AddEditEstimate.setHeightOfDashboard){
		parent.AddEditEstimate.setHeightOfDashboard($(document.body).outerHeight()+20);         
	}
}
$( document ).ready(function() {
      $( window ).resize(resetIframeHeight);  
      resetIframeHeight();
});