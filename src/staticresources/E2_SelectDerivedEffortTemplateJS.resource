var spinner = {
	      show: function(){
	         $('#loadingSpinner').show();
	         return false;
	      },
	      hide: function(){
	         $('#loadingSpinner').hide();
	        return false;
	      }
	    }
	    var dEffortsGroups = {
	        selectedGroup : '',
	        storeSelectedGroup : function(checkeddEfforts) {
	            if($(checkeddEfforts).is(":checked")) {
	            	selectedGroup = $(checkeddEfforts).attr("dEffort-id");

	            }else {
	                selectedGroup = '';
	            }
	        },
	        resetselection : function() {
	        	selectedGroup : '';
	        },
	        selectGroup : function() {
	        	$('input[id$=checkedone]').each(function( index ) {
			    	if($(this).is(":checked") && selectedGroup == $(this).attr("dEffort-id")) {
			        	$(this).prop('checked', true);
			         }
			     });
	        },
	        selectedEfforts : function() {
	        	return selectedGroup;
	        }
	    }
	    var pagination = {
	        chrrentPage : function(currentCon, index, currentIndex, numberOfLinks) {
	            if(currentIndex != index) {
	                currentIndex = parseInt(index);
	                spinner.show();
	                getpage(currentIndex);
	            }
	        },
	        nextPage : function(currentCon, currentIndex, numberOfLinks) {
	            if(currentIndex < numberOfLinks) {
	            currentIndex = currentIndex + 1;
	            spinner.show();
	            getpage(currentIndex);
	            }
	        },
	        previousPage : function(currentCon, currentIndex, numberOfLinks) {
	            if(currentIndex > 1) {
	                spinner.show();
	             currentIndex = currentIndex - 1;
	             getpage(currentIndex); 
	            }
	        },
	        paginationStyle : function(currentCon, currentIndex, numberOfLinks) {
	            if(currentIndex == numberOfLinks) {
	                $("#nextUp" + currentCon).removeClass("next").addClass("notNext");
	                $("#last" + currentCon).removeClass("next").addClass("notNext");
	            } else {
	                $("#nextUp" + currentCon).removeClass("notNext").addClass("next");
	                $("#last" + currentCon).removeClass("notNext").addClass("next");
	            }
	            if(currentIndex == 1) {
	                $("#previousUp" + currentCon).removeClass("prev").addClass("notPrevious");
	                $("#first" + currentCon).removeClass("prev").addClass("notPrevious");
	            } else {
	                $("#previousUp" + currentCon).removeClass("notPrevious").addClass("prev");
	                $("#first" + currentCon).removeClass("notPrevious").addClass("prev");
	            }
	        }
	    }