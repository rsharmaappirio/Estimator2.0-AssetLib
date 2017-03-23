$(function() {
    $('#scopeepiccapacityneeds tbody tr.header').click(function(){
         var that = $(this);
         setTimeout(function(){
            that.toggleClass('expand').siblings('tr.' + that.attr('childCss')).toggle("fast");  
         }, 50);
    });
    tabpanel.bindEvents();
});
var tabpanel = {
    containerId : '#tabpanel',
    detail_tabId : '#tab-default-1__item',
    feed_tabId : '#tab-default-2__item',
    contentToShow : null,
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
                  tabpanel.contentToShow = $('#'+ $(this).find('a').attr('aria-controls'));
                  // slow hide the tabs in order to make hide work for rte
                  setTimeout(function() {
                      tabpanel.contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			          tabpanel.contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
                  }, 80);    
                  
		          $(this).addClass('slds-active');
			      $(this).find('a').attr('aria-selected', true);
			      tabpanel.contentToShow.removeClass('slds-hide');
			      tabpanel.contentToShow.addClass('slds-show');			
			      $(this).siblings().removeClass('slds-active');
			      $(this).siblings().find('a').attr('aria-selected', false);
			      
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
        
    },
    
    showDetailTab: function(){
        tabpanel.activateTab($(tabpanel.detail_tabId).parent());
    },
    
    showFeedTab: function(){
        tabpanel.activateTab($(tabpanel.feed_tabId).parent());
    }
    
}
var loadSpinner = {
    client_id : '#loadingSpinner',
    
    show: function(){
        $(loadSpinner.client_id).show().css('height', $(document).outerHeight()).css('z-index', 99999);
    },
    
    hide: function(){
        $(loadSpinner.client_id).hide();
    }
}