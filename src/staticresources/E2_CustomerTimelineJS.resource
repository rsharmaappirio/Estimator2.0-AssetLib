(function($) {

    $.extend(true, window, {
        "Slick": {
            "AutoColumnSize": AutoColumnSize
        }
    });

    function AutoColumnSize(maxWidth) {

        var grid, $container, context,
            keyCodes = {
                'A': 65
            };

        function init(_grid) {
            grid = _grid;
            maxWidth = maxWidth || 200;

            $container = $(grid.getContainerNode());
            $container.on("dblclick.autosize", ".slick-resizable-handle", reSizeColumn);
            $container.keydown(handleControlKeys);

            context = document.createElement("canvas").getContext("2d");
        }

        function destroy() {
            $container.off();
        }

        function handleControlKeys(event) {
            if (event.ctrlKey && event.shiftKey && event.keyCode === keyCodes.A) {
                resizeAllColumns();
            }
        }

        function resizeAllColumns() {
            var elHeaders = $container.find(".slick-header-column");
            var allColumns = grid.getColumns();
            elHeaders.each(function(index, el) {
                var columnDef = $(el).data('column');
                var headerWidth = getElementWidth(el);
                var colIndex = grid.getColumnIndex(columnDef.id);
                var column = allColumns[colIndex];
                var autoSizeWidth = Math.max(headerWidth, getMaxColumnTextWidth(columnDef, colIndex)) + 1;
                autoSizeWidth = Math.min(maxWidth, autoSizeWidth);
                column.width = autoSizeWidth;
            });
            grid.setColumns(allColumns);
            grid.onColumnsResized.notify();
        }

        function reSizeColumn(e) {
            var headerEl = $(e.currentTarget).closest('.slick-header-column');
            var columnDef = headerEl.data('column');

            if (!columnDef || !columnDef.resizable) {
                return;
            }

            e.preventDefault();
            e.stopPropagation();

            var headerWidth = getElementWidth(headerEl[0]);
            var colIndex = grid.getColumnIndex(columnDef.id);
            var allColumns = grid.getColumns();
            var column = allColumns[colIndex];

            var autoSizeWidth = Math.max(headerWidth, getMaxColumnTextWidth(columnDef, colIndex)) + 1;

            if (autoSizeWidth !== column.width) {
                column.width = autoSizeWidth;
                grid.setColumns(allColumns);
                grid.onColumnsResized.notify();
            }
        }

        function getMaxColumnTextWidth(columnDef, colIndex) {
            var texts = [];
            var rowEl = createRow(columnDef);
            var data = grid.getData();
            if (Slick.Data && data instanceof Slick.Data.DataView) {
                data = data.getItems();
            }
            for (var i = 0; i < data.length; i++) {
                texts.push(data[i][columnDef.field]);
            }
            var template = getMaxTextTemplate(texts, columnDef, colIndex, data, rowEl);
            var width = getTemplateWidth(rowEl, template);
            deleteRow(rowEl);
            return width;
        }

        function getTemplateWidth(rowEl, template) {
            var cell = $(rowEl.find(".slick-cell"));
            cell.append(template);
            $(cell).find("*").css("position", "relative");
            return cell.outerWidth() + 1;
        }

        function getMaxTextTemplate(texts, columnDef, colIndex, data, rowEl) {
            var max = 0,
                maxTemplate = null;
            var formatFun = columnDef.formatter;
            $(texts).each(function(index, text) {
                var template;
                if (formatFun) {
                    template = $("<span>" + formatFun(index, colIndex, text, columnDef, data) + "</span>");
                    text = template.text() || text;
                }
                var length = text ? getElementWidthUsingCanvas(rowEl, text) : 0;
                if (length > max) {
                    max = length;
                    maxTemplate = template || text;
                }
            });
            return maxTemplate;
        }

        function createRow(columnDef) {
            var rowEl = $('<div class="slick-row"><div class="slick-cell"></div></div>');
            rowEl.find(".slick-cell").css({
                "visibility": "hidden",
                "text-overflow": "initial",
                "white-space": "nowrap"
            });
            var gridCanvas = $container.find(".grid-canvas");
            $(gridCanvas).append(rowEl);
            return rowEl;
        }

        function deleteRow(rowEl) {
            $(rowEl).remove();
        }

        function getElementWidth(element) {
            var width, clone = element.cloneNode(true);
            clone.style.cssText = 'position: absolute; visibility: hidden;right: auto;text-overflow: initial;white-space: nowrap;';
            element.parentNode.insertBefore(clone, element);
            width = clone.offsetWidth;
            clone.parentNode.removeChild(clone);
            return width;
        }

        function getElementWidthUsingCanvas(element, text) {
            context.font = element.css("font-size") + " " + element.css("font-family");
            var metrics = context.measureText(text);
            return metrics.width;
        }

        return {
            init: init,
            destroy: destroy
        };
    }
}(jQuery));
(function ($) {

	$.fn.exportToExcel = function (fileName,sheetName, data, options, afterExportCallback) {
        
		//actual data to be imported to excel
		var excelData = data;


        var rgbToHexForExcel_Color = function(color) {
             if(typeof color == 'undefined' || color == null || color == '' || color == 'transparent') return '00000000';  
            
             if (color.charAt(0) === "#") {
                return color.replace('#', '00');
             }
        
             color = color.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);
             
             color = (color && color.length === 4) ? "00" +
              ("0" + parseInt(color[1],10).toString(16)).slice(-2) +
              ("0" + parseInt(color[2],10).toString(16)).slice(-2) +
              ("0" + parseInt(color[3],10).toString(16)).slice(-2) : '';
            
             return color;
        };
        
        
        var rgbToHexForExcel_BgColor = function(color) {
            
            if(typeof color == 'undefined' || color == null || color == '' || color == 'transparent' || color == 'rgba(0, 0, 0, 0)') return '00ffffff';  
            
            if (color.charAt(0) === "#") {
                return color.replace('#', '00');
            }
            
            color = color.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);
            
            
            color = (color && color.length === 4) ? "00" +
              ("0" + parseInt(color[1],10).toString(16)).slice(-2) +
              ("0" + parseInt(color[2],10).toString(16)).slice(-2) +
              ("0" + parseInt(color[3],10).toString(16)).slice(-2) : '';
            
            return color;
        }; 


		//store the base 64 content to be returned
		var returnValue;
        require(['excel-builder'], function (EB, downloader) {
            
            //new excel workbook created
            var newWorkbook = EB.createWorkbook();

            //new worksheet created in the already created newWorsheet
            var newWorksheet = newWorkbook.createWorksheet({ name: sheetName });

            //new stylesheet for adding styles to the newworkbook
            var stylesheet = newWorkbook.getStyleSheet();


            //styles array to store header and cell styles
            var styles = new Array();

            	//if header style is defined by the user, then use that styles
            	if (options && options.headerStyle)
            		styles["headerstyle"] = stylesheet.createFormat(options.headerStyle);

            		//else use default styles
            	else {
            		styles["headerstyle"] = stylesheet.createFormat({
            			font: {
            				bold: true,
            				size: 12,
            				color: '00ffffff'
            			},
            			fill: {
            				type: 'pattern',
            				patternType: 'solid',
            				fgColor: '00428BCA'
            			}
            		});
            	}

            	//if cell style is defined by the user, then use that styles
            	if (options && options.cellStyles)
            		styles["cellstyles"] = stylesheet.createFormat(options.cellStyle);

            		//else use default styles
            	else {
            		styles["cellstyles"] = stylesheet.createFormat({
            			font: {
            				bold: false,
            				size: 12,
            				color: '00000000'
            			},
            			fill: {
            				type: 'pattern',
            				patternType: 'solid',
            				fgColor: '00ffffff'
            			}
            		});
            	}

           

        	//Write the headers of the slick grid values into excel
            function writeHeaders() {
            	//frozen column support
            	var headers = []; 

            	
                $.each(grid.getColumns(), function(indx1, colItem) {
                  headers.push({ value: (typeof colItem != 'undefined' && typeof colItem.name != 'undefined' ? colItem.name : ''), metadata: { style: styles["headerstyle"].id } });
                });
            	
            	//push the headers in to excel
            	newWorksheet.data.push(headers);
                
            	return headers;
            };

        	//write the cell values of each rows in to the excel
            function writeCell(headers) {
              
                
                var gridData = grid.getData();
                
                $.each(gridData, function(indx2, dataItem) {
                    var rowData = [];
                    var prev_cell;
                    
                    $.each(grid.getColumns(), function(indx1, colItem) {
                       var cell = grid.getCellNode(indx2, indx1);
                       
                       if(typeof cell != 'undefined'){ 
                           
                           var metaformat = {
                                        			font: { 
                                        				bold: false,
                                        				size: 12,
                                        				color: rgbToHexForExcel_Color((
                                                                        				    cell.css('color') == 'transparent' || cell.css('color') == '' ? 
                                                                        				    cell.parent('.slick-row').css('color') : 
                                                                        				    cell.css('color')))
                                        			}, 
                                        			fill: {
                                        				type: 'pattern',
                                        				patternType: 'solid',
                                        				fgColor: rgbToHexForExcel_BgColor((
                                                                        				    cell.css('background-color') == 'transparent' || cell.css('background-color') == '' ? 
                                                                        				    cell.parent('.slick-row').css('background-color') : 
                                                                        				    cell.css('background-color')))
                                        			},
                                        			alignment: {
                                                        horizontal: cell.css('text-align')
                                                    }
                                       		};
                               
                             
                             // 10/28/2016: RJ: To resolve issue of showing numbers as text in exported excel; need to typecast text to number;
                             var cellValue = (cell.find('div').length ? cell.find('div').text() : cell.text());
                             cellValue = cellValue.removeCommaFrmt();
                             cellValue = isNaN(parseInt(cellValue)) ? cellValue : parseInt(cellValue);
                             rowData.push({ value: cellValue, metadata: { style: stylesheet.createFormat(metaformat).id }});
                             // old code: commented for reference purpose; TODO: remove after some releases
                             //rowData.push({ value: (cell.find('div').length ? cell.find('div').text() : cell.text()), metadata: { style: stylesheet.createFormat(metaformat).id }});
                                


                             prev_cell = cell;  
                       }else if(typeof prev_cell != 'undefined'){
                           rowData.push({ value: '', metadata: { style: stylesheet.createFormat({
                                    			font: { 
                                    				bold: false,
                                    				size: 12,
                                    				color: rgbToHexForExcel_Color((
                                                                    				    prev_cell.css('color') == 'transparent' || prev_cell.css('color') == '' ? 
                                                                    				    prev_cell.parent('.slick-row').css('color') : 
                                                                    				    prev_cell.css('color')))
                                    			}, 
                                    			fill: {
                                    				type: 'pattern',
                                    				patternType: 'solid',
                                    				fgColor: rgbToHexForExcel_BgColor((
                                                                    				    prev_cell.css('background-color') == 'transparent' || prev_cell.css('background-color') == '' ? 
                                                                    				    prev_cell.parent('.slick-row').css('background-color') : 
                                                                    				    prev_cell.css('background-color')))
                                    			},
                                    			alignment: {
                                                    horizontal: prev_cell.css('text-align')
                                                }
                                    			
                                    		}).id } });
                           
                       }
                       
                    });
                    
                    newWorksheet.data.push(rowData);
                });
            	

            	
            };
                
        	//iniate the write Excel function
            var headers = writeHeaders();
            writeCell(headers);
            



            //set column width for each column in excel
            newWorksheet.setColumns([
                    { width: 30 },
                    { width: 20, hidden: false }, //enable hidden if that column needs to be hidden in the excel file
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
                    { width: 15 },
            ]);


            //downloader method to add the excel file as base 64 
            var downloader = function (filename, value) {
                
                //add the download and href attributes to the excel file download trigeer button
            	$("#downloadLink").attr({
                    download: filename,
                    href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + value
            	});

            	//store the base 64 content to be returned
            	returnValue = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + value;
            };


        	
            //add the created worksheet to the new workbook
            newWorkbook.addWorksheet(newWorksheet);

            //create the excel file
            var data = EB.createFile(newWorkbook);

            //call the downloader method with the parameteres, 1.Name of the Excel file to be downloaded, 2.Created Excel File
            downloader(fileName, data);

            //iniate the callback function
            if (afterExportCallback)
            	afterExportCallback(returnValue);
        });
    };

}(jQuery));
Number.prototype.toCommaFrmt = function(){
    return this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
String.prototype.toCommaFrmt = function(){
    return this.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

Number.prototype.removeCommaFrmt = function(){
    return this.toString().replace(/\,/g,'');
}
String.prototype.removeCommaFrmt = function(){
    return this.replace(/\,/g,'');
}

Date.prototype.startOfWeek = function(pStartOfWeek) {
    var mDifference = this.getDay() - pStartOfWeek;

    if (mDifference < 0) {
        mDifference += 7;
    }

    return new Date(this.addDays(mDifference * -1));
}

Date.prototype.addDays = function(pDays) {
    var mDate = new Date(this.valueOf());
    mDate.setDate(mDate.getDate() + pDays);
    return mDate;
}

Date.prototype.toYYYYMMDD = function() {
    var d = new Date(this.valueOf()),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join('-');
}

var undoRedoBuffer = {
    commandQueue: [],
    commandCtr: 0,

    queueAndExecuteCommand: function(editCommand) {
        this.commandQueue[this.commandCtr] = editCommand;
        this.commandCtr++;
        editCommand.execute();
    },

    undo: function() {
        if (this.commandCtr == 0)
            return;

        this.commandCtr--;
        var command = this.commandQueue[this.commandCtr];

        if (command && Slick.GlobalEditorLock.cancelCurrentEdit()) {
            command.undo();
        }
    },
    redo: function() {
        if (this.commandCtr >= this.commandQueue.length)
            return;
        var command = this.commandQueue[this.commandCtr];
        this.commandCtr++;
        if (command && Slick.GlobalEditorLock.cancelCurrentEdit()) {
            command.execute();
        }
    }
}


function SkillEditor(args) {
    var $input;
    var defaultValue;
    var scope = this;

    this.init = function () {
      $input = $("<INPUT type=text class='editor-text' />");
      
      // return when the row is phase or milestone or any fixed row
      if(typeof args.item.id == 'undefined' || typeof Timeline.fixedRowsTypes[args.item.id] != 'undefined') return;
      
          $input.appendTo(args.container)
          .bind("keydown.nav", function (e) {
            if (e.keyCode === $.ui.keyCode.LEFT || e.keyCode === $.ui.keyCode.RIGHT) {
              e.stopImmediatePropagation();
            }
          })
          .focus()
          .select();
    };

    this.destroy = function () {
      $input.remove();
    };

    this.focus = function () {
      $input.focus();
    };

    this.getValue = function () {
      return $input.val();
    };

    this.setValue = function (val) {
      $input.val(val);
    };

    this.loadValue = function (item) {
      defaultValue = item[args.column.field] || "";
      $input.val(defaultValue);
      $input[0].defaultValue = defaultValue;
      $input.select();
    };

    this.serializeValue = function () {
      return $input.val();
    };

    this.applyValue = function (item, state) {
      item[args.column.field] = state;
    };

    this.isValueChanged = function () {
      return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
    };

    this.validate = function () {
      if (args.column.validator) {
        var validationResults = args.column.validator($input.val());
        if (!validationResults.valid) {
          return validationResults;
        }
      }

      return {
        valid: true,
        msg: null
      };
    };

    this.init();
  }

function MilestoneEditor(args) {
    var $input;
    var defaultValue;
    var scope = this;

    this.init = function () {
      $input = $("<INPUT type=text class='editor-text' />")
          .appendTo(args.container)
          .bind("keydown.nav", function (e) {
            if (e.keyCode === $.ui.keyCode.LEFT || e.keyCode === $.ui.keyCode.RIGHT) {
              e.stopImmediatePropagation();
            }
          })
          .focus()
          .select();
    };

    this.destroy = function () {
      $input.remove();
    };

    this.focus = function () {
      $input.focus();
    };

    this.getValue = function () {
      return $input.val();
    };

    this.setValue = function (val) {
      $input.val(val);
    };

    this.loadValue = function (item) {
      defaultValue = item[args.column.field] || "";
      $input.val(defaultValue);
      $input[0].defaultValue = defaultValue;
      $input.select();
    };

    this.serializeValue = function () {
      return $input.val();
    };

    this.applyValue = function (item, state) {
      item[args.column.field] = state;
    };

    this.isValueChanged = function () {
      return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
    };

    this.validate = function () {
     return {
        valid: true,
        msg: null
      };
    };

    this.init();
}

function AutoCompleteEditor(args) {
    // USED FOR RESOURCE COLUMN 
    // LIKE A TYPE-AHEAD for resource search and apply
    
    var $input;
    var defaultValue = '';
    var scope = this;
    
    this.init = function () {
      $input = $("<INPUT placeholder='" + (typeof args.item.id == 'undefined' ? Timeline.ADD_RESOURCE_LABEL : '') + "' id='" + (typeof args.item.id == 'undefined' ? 'new' : args.item.id) + "' type=text class='editor-text' />");    
      //$input = $("<INPUT id='" + (typeof args.item.id == 'undefined' ? 'new' : args.item.id) + "' type=text class='editor-text' />");
      
      $input.appendTo(args.container)
            .keydown(function(e){
                if(e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40 || e.which == 13){
                    
                    // Don't propogate the event to the document
                    if (e.stopPropagation) {
                        e.stopPropagation();   // W3C model
                        e.preventDefault();
                    } else {
                          e.cancelBubble = true; // IE model
                    }
                }
            }).keypress(function(e){
                if(e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40 || e.which == 13){
                    
                    // Don't propogate the event to the document
                    if (e.stopPropagation) {
                        e.stopPropagation();   // W3C model
                        e.preventDefault();
                    } else {
                          e.cancelBubble = true; // IE model
                    }
                }
            });
            
      $input.focus().select();
      
      $input.autocomplete({
        delay: 0,
        minLength: 0,
        source: function(request, response){
        	var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
        	var results = [];
        	
        	$(Timeline.rt_json).each(function(index, element) {
        		if(matcher.test(element.resource)){
			        results.push(element);
			      }
			    });
        	
        	response(results);
        },
        select: function( event, ui ) {
            //console.log('---' + ui.item.resource);
            $input.val(ui.item.resource);
            var isValid = false;
            $(Timeline.rt_json).each(function(index, element) {
        	    if(element.resource == $input.val()){ 
            	        isValid = true;
                        return false;
        	    }
        	});
            
            if(isValid){
                //console.log('valid entry');
                //Timeline.onResourceSelectionChange(event, ui, $input.attr('id'));
            }
            
            return false;
		}
        
      }).data( "autocomplete" )._renderItem  = function( ul, item ) {
          
          return $( "<li></li>" )
	                .data( "item.autocomplete", item )
	                .append( "<a>" + item.resource + "</a>" )
	                .appendTo( ul ); 
      };
      
      
    };



    this.destroy = function() {
        $input.autocomplete("destroy");
        //$input.remove();
    };

    this.focus = function() {
        $input.focus();
    };

    this.loadValue = function(item) {
      defaultValue = item[args.column.field] || "";
      $input.val(defaultValue);
      $input[0].defaultValue = defaultValue;
      $input.select();
    };

    this.serializeValue = function() {
        return $input.val();
    };

    this.applyValue = function(item, state) {
        item[args.column.field] = state;
    };

    this.isValueChanged = function() {
        return ($input.val() != defaultValue);
    };

    this.validate = function() {
        var isValid = false;
        
        if($input.val() == defaultValue){
            isValid = true;
        }
        
    	$(Timeline.rt_json).each(function(index, element) {
    	    if(element.resource == $input.val()){ 
    	        isValid = true;
                return false;
    	    }
    	});
        
        return {
            valid: isValid,
            msg: null
        };
    };

    this.init();
}


function AutoFillEditor(args) {
    var $input, $picker;
    var defaultValue = 0;
    var scope = this; 

    this.init = function () {
      //console.log(args);
      $picker = $("<div class='editor-autofill-picker' />")
      
      // return when the row is phase or milestone 
      if(typeof args.item.id == 'undefined' || typeof Timeline.fixedRowsTypes[args.item.id] != 'undefined') return;
      
      
       // In case of frozen column feature; the picker gets hidden behind the divs
      // the position of the picker should be set specifically based on the parent container offset values
      // we also need to append the picker to dom and not to container as to display the picker over and above all the html elements;
      var parentOffset = args.container.offset();
      $picker.css({ 'position': 'absolute', 'left' : parentOffset.left, 'top' : parentOffset.top});
      $picker.appendTo(document.body);
      
      // commented to append picker to container; 
      //$picker.appendTo(args.container);
      
      
      $picker.append("<div class='editor-autofill-helper'><div class='editor-autofill-wrapper'><div class='editor-autofill-slider' /></div>");

      //$input.focus().select();

      $picker.find(".editor-autofill-slider").slider({
        min: 0,
        max: 40,
        step: 4,
        value: defaultValue,
        orientation: "horizontal",
        range: "min",
        slide: function (event, ui) {
          //$input.val(ui.value)
        },
        create: function( event, ui ) {
           
            // Get the options for this slider (specified above)
            var opt = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40];
    
            // Get the number of possible values
            //var vals = opt.max - opt.min;
        
            // Position the labels
            for (var i = 0; i < opt.length; i++) {
        
                // Create a new element and position it with percentages
                var el = $('<label>' + opt[i] + '</label>').css('left', ((opt[i]/(opt[opt.length - 1]))*100)+'%');
        
                // Add the element inside #slider
                $(this).append(el);
            }
           
        },
        stop: function( event, ui ) {
            //alert(args.item);
            
            if(typeof args.item.id != 'undefined'){
                var resourceId = args.item.id; 
                var nodes_order_json = '[';
                $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                             args.item[colItem.id] = ui.value;
                             nodes_order_json += '{"resourceId":"' + resourceId + '", "weekId":"' + colItem.id + '", "hours" : "' + ui.value + '"},';
                        }
                });        
                nodes_order_json = nodes_order_json.slice(0, -1);
                nodes_order_json += ']';
                Timeline.autoFill(nodes_order_json);
            }
            
            grid.focus();
            grid.setData(data);
            Timeline.renderGrid();
            
        }
      });
      
    };

    this.destroy = function () {
      //$input.remove();
      $picker.remove();
    };

    this.focus = function () {
      //$input.focus();
    };

    this.loadValue = function (item) {
      //$input.val(defaultValue = item[args.column.field]);
      //$input.select();
      //$input.val('Auto');
    };

    this.serializeValue = function () {
      return '';//$picker.find(".editor-autofill-slider").slider("option", "value"); 
    };

    this.applyValue = function (item, state) {
      item[args.column.field] = state;
    };

    this.isValueChanged = function () {
      return true;//(!($input.val() == "" && defaultValue == null)) && ((parseInt($input.val(), 10) || 0) != defaultValue);
    };

    this.validate = function () {
      return {
        valid: true,
        msg: null
      };
    };

    this.init();
}

jQuery.fn.center = function () {
    this.css("position","absolute");
    this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) +
                                                $(window).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + 
                                                $(window).scrollLeft()) + "px");
    return this;
}



var data = [];
var columns = [];
var loadingIndicator = null;
var grid;
var WEBSERVICE_NAME = "E2_TimelineWS";


var loadSpinner = {
    client_id : '#loadingSpinner',
    
    show: function(){
        $(loadSpinner.client_id).show().css('height', $(document).outerHeight()).css('z-index', 99999);
    },
    
    hide: function(){
        $(loadSpinner.client_id).hide();
    }
}



var CustomAlert = {
    notifyContainerCssSelector: '.slds-notify_container',
    notifyCloseCssSelector: '.slds-notify__close',
    notifyMsgCssSelector: '.slds-text-heading--small',
    notifyTypeCssDiv: '#sldsalertdiv',
    notifyEditContainer: '.slds-edit-alert',
    notifyEditContainerbackdrop: '.slds-edit-alert-backdrop',
    showIsDirtyWarning: function() {
        $(CustomAlert.notifyEditContainerbackdrop).show().css('height', $(document).outerHeight());
        $(CustomAlert.notifyEditContainer).show();
    },
    hideIsDirtyWarning: function() {
        $(CustomAlert.notifyEditContainer).hide();
        $(CustomAlert.notifyEditContainerbackdrop).hide();
    },
    show: function(msg) {
        $(CustomAlert.notifyContainerCssSelector).css({
            position: 'absolute !important',
            'opacity': '100',
            'display': 'block'
        });
        $(CustomAlert.notifyTypeCssDiv).removeClass("slds-theme--error");
        $(CustomAlert.notifyTypeCssDiv).addClass("slds-theme--success");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyMsgCssSelector).text(msg);
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).unbind("click");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).bind("click", function() {
            $(CustomAlert.notifyContainerCssSelector).stop(true, true).fadeTo().slideUp();
            return false;
        });
        window.setTimeout(function() {
            if ($(CustomAlert.notifyContainerCssSelector).is(":visible")) {
                $(CustomAlert.notifyContainerCssSelector).fadeTo(500, 0).slideUp(500, function() {
                    $(this).hide();
                });
            }
        }, 2000);
    },
    hide: function() {
        $(CustomAlert.notifyContainerCssSelector).hide();
    },
    showError: function(msg) {
        $(CustomAlert.notifyContainerCssSelector).css({
            position: 'absolute !important',
            'opacity': '100',
            'display': 'block'
        });
        $(CustomAlert.notifyTypeCssDiv).removeClass("slds-theme--success");
        $(CustomAlert.notifyTypeCssDiv).addClass("slds-theme--error");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyMsgCssSelector).text(msg);
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).unbind("click");
        $(CustomAlert.notifyContainerCssSelector).find(CustomAlert.notifyCloseCssSelector).bind("click", function() {
            $(CustomAlert.notifyContainerCssSelector).stop(true, true).fadeTo().slideUp();
            return false;
        });
        window.setTimeout(function() {
            if ($(CustomAlert.notifyContainerCssSelector).is(":visible")) {
                $(CustomAlert.notifyContainerCssSelector).fadeTo(500, 0).slideUp(500, function() {
                    $(this).hide();
                });
            }
        }, 2000);
    }
}

var makeManageRateCardsCollapsible = function(){
    $('#manageratecardtable tbody tr.header').click(function(){
         
         loadSpinner.show();
         var that = $(this);
         setTimeout(function(){
            that.toggleClass('expand').siblings('tr.' + that.attr('childCss')).toggle("slow", function() {
              loadSpinner.hide();
            });  
         }, 50);
         
         
         
    });
}

function preventEnterSubmit(e) {
    if (e.which == 13) {
        var $targ = $(e.target);

        if (!$targ.is("textarea") && !$targ.is(":button,:submit")) {
            var focusNext = false;
            $(this).find(":input:visible:not([disabled],[readonly]), a").each(function(){
                if (this === e.target) {
                    focusNext = true;
                }
                else if (focusNext){
                    $(this).focus();
                    return false;
                }
            });

            return false;
        }
    }
}



// On DOM Ready
$(function() {
    // Bind the window resize event to adjust the with of all the iframes with the resized 
    // width of the window
    // on screen for good user experience
    //$( window ).resize(function() {
    //    if(typeof grid != 'undefined') grid.resizeCanvas();
    //});
    

    applyNumericValidation();
    makeManageRateCardsCollapsible();
    tabpanel.bindEvents();
    tabpanel.showTimelineTab();
    // undo shortcut
    $(document).keydown(function(e) {
        if (e.which == 90 && (e.ctrlKey || e.metaKey)) { // CTRL + (shift) + Z
            if (e.shiftKey) {
                undoRedoBuffer.redo();
            } else {
                undoRedoBuffer.undo();
            }
        }
    });
    // document click event to save chnages in grid when moved outside gird : 	I-232609
    $(document).click(function(e) {
        if (e.target.id != "myDiv" && !$(e.target).parents("#myDiv").size()) { 
             Slick.GlobalEditorLock.commitCurrentEdit();
        }
    });
    reFreshGrid();
    loadSpinner.show();
});


var reFreshGrid = function(){
    
    if(grid != null || typeof grid != 'undefined'){
        Timeline.rt_json = null;
        Timeline.rt_json = [];
        grid.destroy();
        grid = null;
    }
    gridMainInitiate();
    //Timeline.init(estimateId);
    Timeline.getEstimateRateCards(estimateId);
}


var gridMainInitiate = function(){
    //var dataProvider = new TotalsDataProvider(data, columns); 
    
    grid = new Slick.Grid("#myGrid", data, columns, Timeline.getGridOptions());
                                                    
     // set keyboard focus on the grid 
    //grid.getCanvasNode().focus(); // commented to get default page focus on load : I-232604
    
    grid.registerPlugin( new Slick.AutoColumnSize());
    
    /*** AUTO - TOOLTIP **/
    grid.registerPlugin(new Slick.AutoTooltips());

    
    //$('#myGrid').on('blur', 'input.editor-text', function() {
   //     Slick.GlobalEditorLock.commitCurrentEdit();
   // });
    
    Timeline.renderGrid();
    
    
}

var loader = {
    show: function() {
        if (!loadingIndicator) {
            loadingIndicator = $("<span class='loading-indicator'><label>Processing...</label></span>").appendTo(document.body);
            var $g = $("#myGrid");

            loadingIndicator
                .css("position", "absolute")
                .css("top", $g.position().top + $g.height() / 2 - loadingIndicator.height() / 2)
                .css("left", $g.position().left + $g.width() / 2 - loadingIndicator.width() / 2);
        }

        loadingIndicator.show();
    },

    hide: function() {

        loadingIndicator.fadeOut();
        // To refresh the overview panel
        //if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
    }
}


var tabpanel = {
    containerId : '#tabpanel',
    timeline_tabId : '#tab-default-1__item',
    ratecard_tabId : '#tab-default-2__item',
    contentToShow : null,
    bindEvents : function(){
       $('.slds-tabs--default__item').on('click', function(){
                  tabpanel.contentToShow = $('#'+ $(this).find('a').attr('aria-controls'));
                  $(this).addClass('slds-active');
			      $(this).find('a').attr('aria-selected', true);
			      tabpanel.contentToShow.removeClass('slds-hide');
			      tabpanel.contentToShow.addClass('slds-show');			
			      $(this).siblings().removeClass('slds-active');
			      $(this).siblings().find('a').attr('aria-selected', false);
			      tabpanel.contentToShow.siblings('.slds-tabs--default__content').removeClass('slds-show');
			      tabpanel.contentToShow.siblings('.slds-tabs--default__content').addClass('slds-hide');
			      
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
    
    showTimelineTab: function(){
        tabpanel.activateTab($(tabpanel.timeline_tabId).parent());
    },
    
    showRatecardTab: function(){
        tabpanel.activateTab($(tabpanel.ratecard_tabId).parent());
    }
    
}





var Timeline = {
    fixedRows: 7,
    fixedColumns : 3,
    maxHours : 45,
    calcuation_cols_css : {'text-align' : 'center', 'background-color': '#666666', 'color' : '#ffffff', 'font-weight' : 'bold'},
    highlight_cols_css : {'text-align' : 'center', 'background-color': '#000080', 'color' : '#ffffff', 'font-weight' : 'bold'},
    capacityneeds_cols_css : {'text-align' : 'center', 'background-color': '#0070d2', 'color' : '#fff', 'font-weight' : 'bold'},
    hoursperphase_cols_css : {'text-align' : 'center', 'background-color': '#0070d2', 'color' : '#fff', 'font-weight' : 'bold'},
    rt_json : [],
    cellOldText : '',
    ADD_RESOURCE_LABEL : 'Type here to add resource...',
    renderGrid: function(){
        grid.setCellCssStyles("label_highlights", {
           1: {
                move: "slds-weekname-cell",
                id: "slds-weekname-cell",
                selector1: "slds-weekname-cell",
                skill: "slds-weekname-cell",
                autofill: "slds-weekname-cell"
               }
               ,
            2: {
                move: "slds-milestones-cell",
                id: "slds-milestones-cell",
                selector1: "slds-milestones-cell",
                skill: "slds-milestones-cell",
                autofill: "slds-milestones-cell"
               },
             3: {
                move: "slds-milestones-cell",
                id: "slds-milestones-cell",
                selector1: "slds-milestones-cell",
                skill: "slds-milestones-cell",
                autofill: "slds-milestones-cell"
               },
                4: {
                move: "slds-milestones-cell",
                id: "slds-milestones-cell",
                selector1: "slds-milestones-cell",
                skill: "slds-milestones-cell",
                autofill: "slds-milestones-cell"
               }
        });
        
        grid.render();
        
        Timeline.applyAddNewRowResourceCellLabel();
        
    },
    
    applyAddNewRowResourceCellLabel: function(){
        if(Timeline.getGridOptions().enableAddRow)  $(grid.getCellNode(grid.getData().length, 2)).not(':has(.add-resource-label)').append('<span class="add-resource-label">' + Timeline.ADD_RESOURCE_LABEL + '</span>');
    },
    
     // Method to convert b64 to blob for IE10+ export
    b64toBlob : function(b64Data, contentType, sliceSize) {
              contentType = contentType || '';
              sliceSize = sliceSize || 512;
            
              var byteCharacters = atob(b64Data);
              var byteArrays = [];
            
              for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
                var slice = byteCharacters.slice(offset, offset + sliceSize);
            
                var byteNumbers = new Array(slice.length);
                for (var i = 0; i < slice.length; i++) {
                  byteNumbers[i] = slice.charCodeAt(i);
                }
            
                var byteArray = new Uint8Array(byteNumbers);
            
                byteArrays.push(byteArray);
              }
            
              var blob = new Blob(byteArrays, {type: contentType});
              return blob;
     },
    
    
    registerExportToExcel: function(){
       var gridData = grid.getData();    
       
       $('body').exportToExcel('Timeline - ' + estimate_name + ".xlsx", 'Timeline', gridData, null, function (response) {
            //console.log(response);
            // use vanilla way of calling click action on anchor tag
            // jquery click doesn't work on anchor tags
            //document.getElementById("downloadLink").click();
            
            if (navigator.msSaveBlob) { // IE 10+ 
                //alert('in IE');
                response = response.replace('data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,', '');
                //console.log('NEWRESPONSE' + response);
                navigator.msSaveBlob(Timeline.b64toBlob(response, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'), 'Timeline - ' + estimate_name + '.xlsx'); 
            
                
            }else if(typeof sforce != 'undefined' && typeof sforce.one != 'undefined'){
                 
                 // Lightning experience show - working
                 window.top.location.href = document.getElementById("downloadLink").getAttribute("href");
                 
                
            }else {
                //alert('in Firefox/Mozilla/Chrome');
                // use vanilla way of calling click action on anchor tag
                // jquery click doesn't work on anchor tags
              
                // Does Not work in lightning
                document.getElementById("downloadLink").click();
                
            }
            
            $('#myGrid').css({'width': '100%', height: '450px'});
            grid.resizeCanvas(); 
           
            loadSpinner.hide();
            loader.hide();
        }); 
        
        gridData = null;
    },
    
    downloadExcel_Click: function(src, event){
       // change the width and height of the grid to make all the columns visible to be 
       // able to be available at the time of render
       
       $('#myGrid').css({'width': '15000px', height: '15000px'});
       grid.resizeCanvas();
       Timeline.applyAddNewRowResourceCellLabel();
       
       //grid.destroy();
       //gridMainInitiate();
       loadSpinner.show();
       loader.show();
       // 3 seconds are benchmarks
       // Need to give 3 secs wait period to load the grid with 
       // all the asyncPostRender items and then start reading grid content
       
       setTimeout(function(){
           try{
              Timeline.registerExportToExcel();
           }catch(ex){
              //in case exception comes while generating the xlsx; do handle the exception 
              // and render the grid properly
              loadSpinner.hide();
              loader.hide();
           }
       }, 3000);
       
       return false;       
    },
    
    
    getGridOptions: function(){ 
      return {
                                                        explicitInitialization : true,
                                                        editable: false,
                                                        enableAddRow: false,
                                                        enableCellNavigation: true,
                                                        asyncEditorLoading: true, // need true to implement single click
                                                        autoEdit: true,
                                                        enableColumnReorder: false
                                                        ,forceFitColumns : false
                                                        ,headerRowHeight : 30
                                                        ,enableAsyncPostRender: true
                                                        ,asyncPostRenderDelay : 50 // default 50
                                                        ,leaveSpaceForNewRows : true
                                                        ,frozenColumn : 2
                                                        ,frozenRow : 7
                                                        ,autoHeight: true
                                                    };  
        
    },
     
    getDefaultColumns: function() {
        return [{
            id: "move",
            name: "",
            field: "move",
            width: 15,
            behavior: "selectAndMove",
            selectable: false,
            resizable: false,
            focusable : false,
            cssClass: "cell-reorder dnd",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
        },  {
            id: "selector1",
            field: "e2Resource",
            name: "Resource",
            behavior: "",
            width: 350,
            selectable: false,
            resizable: false,
            focusable : true,
            editor: AutoCompleteEditor,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
            ,formatter: function(row, cell, value, columnDef, dataContext) {
                // 09/23 RJ: Added this formatter to display only role name in the column
                // Need not to display the whole text with practice, region, role 
                // show the whole text as tooltip than on screen
                var SEPARATOR = ' - ';
                if(typeof value != 'undefined' && value != ''){
                    var valArr = value.split(SEPARATOR);
                    if(valArr.length > 0){ 
                        return '<div class="info_icon" style="cursor:pointer;font-weight:bold;color:#000" title="' + value + '">' + dataContext.roleToDisplay + '</div>';
                    }
                }
                return value;
            }
        },{
            id: "skill",
            field: "skill",
            name: "Notes", 
            width: 100,
            selectable: false,
            resizable: true,
            focusable : true,
            editor: SkillEditor,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
        }];
    },
    
     getEndColumns: function() {
        return [{
                    id: "hours",
                    name: "Hours",
                    field: "hours",
                    //width: 50,
                    selectable: false,
                    resizable: true,
                    focusable : false,
                    order: null
                    ,cssClass : "slds-calculated-cell"
                    ,headerCssClass: "Fixed-Header-Style"
                    ,notUsedForCalculation : true
                    ,formatter: Timeline.waitingFormatter
                    ,asyncPostRender: function(cellNode, row, dataContext, colDef) {
                        //console.log('postrender');
                        if(row < Timeline.fixedRows){
                            if(data[row].id == Timeline.fixedRowsTypes.total.id){
                                 //$(cellNode).empty().html(Timeline.getSumOfHoursForRows()).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                                 $(cellNode).empty().html(Timeline.getSumOfHoursForAllRows(cellNode, row, dataContext, colDef).toCommaFrmt()).addClass('slds-totalhrsperweek-cell-sum');
                            }
                            return;
                        }else{
                          $(cellNode).empty().html(Timeline.getHoursSum(cellNode, row, dataContext, colDef).toCommaFrmt()).addClass('slds-totalhrsperweek-cell');//.css({'text-align':'center','background-color': '#bacde3'});
                        }
                    }
                }, {

                    id: "rate",
                    name: "Rate",
                    field: "rate",
                    width: 100,
                    selectable: false,
                    resizable: true,
                    focusable : false,
                    order: null
                    ,cssClass : "slds-weekname-cell"// "slds-calculated-cell"
                    ,headerCssClass: "Fixed-Header-Style"
                    ,notUsedForCalculation : true
                    ,formatter: function(row, cell, value, columnDef, dataContext) {
                        //if(row < Timeline.fixedRows){
                        //    return '';
                        //}
                        if(typeof Timeline.fixedRowsTypes[data[row].id] != 'undefined' || dataContext.id == '') return "";
                        var returnVal =  value == '' ? '0.00' : parseFloat(value).toFixed(2).toCommaFrmt();
                        
                        //if(typeof dataContext.isRateOverridden != 'undefined' 
                          //  && dataContext.isRateOverridden == 'true') {
                            //return '<div class="isRateOverridden">' + returnVal + '</div>';
                        //}
                        return returnVal;
                        
                    },asyncPostRender: function(cellNode, row, dataContext, colDef) {
                        if(typeof dataContext.isRateOverridden != 'undefined' && dataContext.isRateOverridden == 'true') {
                            $(cellNode).addClass('isRateOverridden');
                        }
                        //if(row < Timeline.fixedRows){
                            //if(data[row].id == Timeline.fixedRowsTypes.total.id){
                                 //$(cellNode).empty().html(Timeline.getSumOfBelowRows()).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                                 //var rate = Timeline.getAvgOfBelowRows(cellNode, row, dataContext, colDef);
                                 //$(cellNode).empty().html(parseFloat(isNaN(rate) ? 0 : rate).toFixed(2).toCommaFrmt()).css(Timeline.calcuation_cols_css);
                                 
                            //}
                            //return;
                        //}
                    }
                },{
                    id: "selling_price",
                    name: "Total Price",
                    field: "selling_price",
                    width: 100,
                    selectable: false,
                    resizable: true,
                    focusable : false,
                    order: null
                    ,cssClass : "slds-weekname-cell"//"slds-calculated-cell"
                    ,headerCssClass: "Fixed-Header-Style"
                    ,notUsedForCalculation : true
                    ,formatter: Timeline.waitingFormatter
                    ,asyncPostRender: function(cellNode, row, dataContext, colDef) {
                        if(row < Timeline.fixedRows){
                            if(data[row].id == Timeline.fixedRowsTypes.total.id){
                                 var sum = 0;
                                 var rowData = data.slice(Timeline.fixedRows);
                                 var colData = columns.slice(Timeline.fixedColumns);
                                 $.each(rowData, function(indx, rowItem) {
                                    var row_sum = 0; 
                                    $.each(colData, function(indx1, colItem) {
                                       if(typeof colItem.notUsedForCalculation == 'undefined' || !colItem.notUsedForCalculation) {
                                           row_sum += (typeof rowItem[colItem.id] == 'undefined' || rowItem[colItem.id] == ''? 0 : parseInt(rowItem[colItem.id]));
                                       }       
                                    });
                                    sum += parseInt(row_sum) * parseInt(rowItem.rate);
                                    //console.log('----------' + sum + '-------------' + rowItem.id);
                                 });
                                 
                                 var total_price = parseFloat(sum).toFixed(2);
                                 $(cellNode).empty().html(total_price.toCommaFrmt()).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }
                        $(cellNode).empty().html(parseFloat(Timeline.getHoursSum(cellNode, row, dataContext, colDef) * dataContext.rate).toFixed(2).toCommaFrmt());
                    }
                }];
    },
    
    
    // Code for enablePhaseContextMenu : Rohit
    fixedRowsTypes : {
                      'weekname' : {
                          id : 'weekname',
                          defaultValue : '',
                          valuefield: 'order'
                          , rowLabel: 'WEEK'
                          , enableColorCodeContextMenu : false
                          , enablePhaseContextMenu : false
                          ,editable : false
                          ,rowIndex : 0
                      }, 
                      'phase' : {
                          id : 'phase',
                          defaultValue : '',
                          valuefield: 'phase',
                          colorcodefield : 'phaseColorCode',
                          colorcodepostfix : '_phasecolorcode',
                          apply_css : true
                          , rowLabel: 'PHASE'
                          , enableColorCodeContextMenu : false
                          , enablePhaseContextMenu : true
                          ,rowIndex : 1
                          ,editable : false
                          
                          
                      }, 'milestone' : {
                          id : 'milestone',
                          defaultValue : '',
                          valuefield: 'milestone',
                          colorcodefield : 'milestoneColorCode',
                          colorcodepostfix : '_milestonecolorcode',
                          apply_css : true
                          , rowLabel: 'MILESTONE'
                          , enableColorCodeContextMenu : true
                          , enablePhaseContextMenu : false
                          ,rowIndex : 2
                          
                      }, 'milestone1' : {
                          id : 'milestone1',
                          defaultValue : '',
                          valuefield: 'milestone1',
                          colorcodefield : 'milestoneColorCode1',
                          colorcodepostfix : '_milestonecolorcode1',
                          apply_css : true
                          , rowLabel: ''
                          , enableColorCodeContextMenu : true
                          , enablePhaseContextMenu : false
                          ,rowIndex : 3
                          
                      }, 'milestone2' : {
                          id : 'milestone2',
                          defaultValue : '',
                          valuefield: 'milestone2',
                          colorcodefield : 'milestoneColorCode2',
                          colorcodepostfix : '_milestonecolorcode2',
                          apply_css : true
                          , rowLabel: ''
                          , enableColorCodeContextMenu : true
                          , enablePhaseContextMenu : false
                          ,rowIndex : 4
                          
                      },'hoursperphase' : {
                          id : 'hoursperphase',
                          defaultValue : 0
                          , rowLabel: 'HOURS PER PHASE (Hrs)'
                          , enableColorCodeContextMenu : false
                          , enablePhaseContextMenu : false,
                          apply_css : false
                          ,editable : false
                          ,rowIndex : 5
                          
                      }, 'total' : {
                          id : 'total',
                          defaultValue : 0
                          , rowLabel: 'TOTAL PER WEEK (Hrs)'
                          , enableColorCodeContextMenu : false
                          , enablePhaseContextMenu : false,
                          apply_css : false
                          ,editable : false
                          ,rowIndex : 6
                      }
        
    },
                                                          
    bindMetadata: function(){
        // set the grid's data as new rows
        data.getItemMetadata = function (row) {
                  
                   var metadata =  {
                      selectable: false,
                      //cssClasses: "custom-fix-row",
                      "columns": {
                                        "id": {
                                                  formatter: function(row, cell, value, columnDef, dataContext) {
                                                        return "";
                                                  },
                                                  focusable : false,
                                                  editor: ""
                                                },
                                        "selector1" : {
                                                  formatter: function(row, cell, value, columnDef, dataContext) {
                                                      var meta_info = Timeline.fixedRowsTypes[data[row].id];
                                                      if(typeof meta_info != 'undefined'){
                                                          var rowLabel = (typeof meta_info.rowLabel == 'undefined' ? '' : meta_info.rowLabel);
                                                          return "<div style='width:100%;text-align:right;font-weight: bold;'>" + rowLabel + "</div>";
                                                      }
                                                      return value;
                                                  },
                                                  focusable : false,
                                                  editor: ""
                                        }       
                      }
                    };
                
               
                
                
                if(typeof data[row] != 'undefined' && (data[row].id == Timeline.fixedRowsTypes.milestone.id || data[row].id == Timeline.fixedRowsTypes.milestone1.id || data[row].id == Timeline.fixedRowsTypes.milestone2.id)){
                      var currentRow = data[row];
                      
                     $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                             //added code for colspan
                             metadata.selectable = true;
                             var val = currentRow[columns[indx1].field];
                             var nextCellIndex = indx1 + 1;
                             var colspan = 1;
                             while(nextCellIndex < columns.length){
                                 if(val == currentRow[columns[nextCellIndex].field] && val != ''){ 
                                   colspan++;  
                                 }else {
                                     break;
                                 } 
                                 nextCellIndex += 1;
                             }
                             // end of colspan calcuation
                             metadata.columns[colItem.field] = {};
                             metadata.columns[colItem.field].editor = MilestoneEditor;
                             metadata.columns[colItem.field].colspan = colspan; // added for colspan
                        }
                    });
                    //metadata['cssClasses'] = 'slds-milestones-cell';
                    return metadata;
                    
                }else if(typeof data[row] != 'undefined' && data[row].id == Timeline.fixedRowsTypes.phase.id){
                    
                    var currentRow = data[row];
                             
                    $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                            //added code for colspan
                             metadata.selectable = true;
                             var val = currentRow[columns[indx1].field];
                             var nextCellIndex = indx1 + 1;
                             var colspan = 1;
                             while(nextCellIndex < columns.length){
                                 if(val == currentRow[columns[nextCellIndex].field] && val != ''){ 
                                   colspan++;  
                                 }else {
                                     break;
                                 } 
                                 nextCellIndex += 1;
                             }
                             // end of colspan calcuation
                             metadata.columns[colItem.field] = {};
                             //metadata.columns[colItem.field].editor = MilestoneEditor; // commented after adding colspan no need for phase editor now
                             //metadata.columns[colItem.field].editor = PhaseSelectionEditor; 
                             metadata.columns[colItem.field].colspan = colspan; // added for colspan
                        }
                    });
                    
                    return metadata;
                    
                }else if(typeof data[row] != 'undefined' && data[row].id == Timeline.fixedRowsTypes.hoursperphase.id){
                    
                    //for(var _a in Timeline.fixedRowsTypes.phase.rowIndex)
                    
                    var currentRow = data[Timeline.fixedRowsTypes.phase.rowIndex];
                    
                             
                    $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                            //added code for colspan
                             //metadata.selectable = true;
                             metadata.focusable = false;
                             var val = currentRow[columns[indx1].field];
                             var nextCellIndex = indx1 + 1;
                             var colspan = 1;
                             while(nextCellIndex < columns.length){
                                 if(val == currentRow[columns[nextCellIndex].field] && val != ''){ 
                                   colspan++;  
                                 }else {
                                     break;
                                 } 
                                 nextCellIndex += 1;
                             }
                             // end of colspan calcuation
                             metadata.columns[colItem.field] = {};
                             metadata.columns[colItem.field].colspan = colspan; // added for colspan
                        }
                    });
                    metadata['cssClasses'] = 'slds-hoursperphase-cell';
                    return metadata;
                    
                }else if(typeof data[row] != 'undefined' && data[row].id == Timeline.fixedRowsTypes.total.id){
                    
                   metadata['cssClasses'] = 'slds-totalhrsperweek-cell';
                   metadata.focusable = false;
                   return metadata;
                }else if(typeof data[row] != 'undefined' && data[row].id == Timeline.fixedRowsTypes.weekname.id){
                    
                   metadata['cssClasses'] = 'slds-weekname-cell';
                   return metadata;
                }else if(typeof data[row] != 'undefined' && typeof Timeline.fixedRowsTypes[data[row].id] != 'undefined'){
                    return metadata;
                }
                
           }
        
        
    },

    numFieldValidator : function(value) {
        if (value == null || value == undefined || !value.length || !(/\D/.test(value))) {
          if((value != null || value != undefined || value.length) && value > Timeline.maxHours){
             return {valid: false, msg: "More than 40 not allowed"};    
          }else{
             return {valid: true, msg: null};   
          }   
        } else {
          return {valid: false, msg: "This requires only number"};
        }
    },
    textFieldValidator : function(value) {
       
             return {valid: true, msg: null};   
          
    },
    waitingFormatter : function (row, cell, value, columnDef, dataContext) {
        
        if(typeof dataContext.id != 'undefined' && typeof Timeline.fixedRowsTypes[dataContext.id.toLowerCase()] != 'undefined') return '';
        
        return '';
        //return 'wait..';
    },

    
    getHoursSum: function(cellNode, row, dataContext, colDef){
            var rowData = data[row];
            var sum = 0;
            $.each(columns, function(indx1, colItem) {
                if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                    //sum += parseInt(isNaN(rowData[colItem.field]) ? 0 : rowData[colItem.field]);
                    sum += (typeof rowData[colItem.field] == 'undefined' || rowData[colItem.field] == '' ? 0 : parseInt(rowData[colItem.field]));
                }
            });
            //console.log(str);
            return sum;
    },
    getSumOfHoursForAllRows: function(cellNode, row, dataContext, colDef){
        var sum = 0;
        var rowData = data.slice(Timeline.fixedRows);
        var colData = columns.slice(Timeline.fixedColumns);
        $.each(rowData, function(indx, rowItem) {
            $.each(colData, function(indx1, colItem) {
               if(!colItem.notUsedForCalculation) {
                   sum += (typeof rowItem[colItem.id] == 'undefined' || rowItem[colItem.id] == ''? 0 : parseInt(rowItem[colItem.id]));
               }
            });
        });
        return sum;
    },
    getSumOfBelowRows: function(cellNode, row, dataContext, colDef){
        var sum = 0;
        var rowData = data.slice(row + 1);
         $.each(rowData, function(indx, rowItem) {
            sum += (typeof rowItem[colDef.id] == 'undefined' || rowItem[colDef.id] == ''? 0 : parseInt(rowItem[colDef.id]));
         });
         
         return sum;
    },
    getAvgOfBelowRows: function(cellNode, row, dataContext, colDef){
        var sum = 0;
        var rowData = data.slice(row + 1);
         $.each(rowData, function(indx, rowItem) {
            sum += (typeof rowItem[colDef.id] == 'undefined' || rowItem[colDef.id] == ''? 0 : parseInt(rowItem[colDef.id]));
         });
         
         return parseFloat(sum/rowData.length).toFixed(2);
    },
   
    getEstimateRateCards: function(estimateId){
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "getEstimateRateCards", {
            estimateId: estimateId
        }, Timeline.getEstimateRateCards_Callback);
        
    }, 
    getEstimateRateCards_Callback: {
         onSuccess: function(result) {
             Timeline.rt_json = [];
            //result = (result.length > 0 ? result[0] : result); 
            $.each(result, function(indx, row) {
                var e1resource = row.Region__c + ' - ' + row.Resource_Role__c;
                var resource = row.Practice__c + ' - ' + e1resource;
                var json_obj = {};
                json_obj['id'] = row.Id;
                json_obj['practice'] = row.Practice__c;
                json_obj['region'] = row.Region__c;
                json_obj['role'] = row.Resource_Role__c;
                json_obj['code'] = row.Code__c;
                
                // 12/26: RJ: Added Resource Level field changes 
                json_obj['level'] = '';
                if(typeof row.Resource_Level__c != 'undefined' && row.Resource_Level__c != ''){ 
                    json_obj['level'] = row.Resource_Level__c;
                    resource += ' - ' + row.Resource_Level__c;
                }
                
                // rate card rate
                json_obj['suggestedRate'] = row.Bill_Rate__c;
                // custom/editable bill rate
                json_obj['discountedRate'] = row.Discounted_Rate__c;
                // resource cost
                json_obj['cost'] = row.Resource_Cost__c;
                json_obj['e1resource'] = e1resource;
                json_obj['resource'] = resource;
                
                
                
                Timeline.rt_json.push(json_obj);
            });
            
            // clear the initital array
            result = [];
            Timeline.init(estimateId);
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
        
    },
    init: function(estimateId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
            estimateId: estimateId
        }, Timeline.initCallback);
    },
    initCallback: {
        onSuccess: function(result) {
            //result = (result.length > 0 ? result[0] : result); 
            columns = Timeline.getDefaultColumns();
            
            if(result.length == 0) $('#build_div').show();
            
            $.each(result, function(indx, column) {
                columns.push(Timeline.defineAddPropForColumn(column));
            });
            
            
            // clear the initital array
            result = [];
            
            columns = columns.concat(Timeline.getEndColumns());
            // set the grid's columns as the new columns
            grid.setColumns(columns);
            
            // when columns are now in; go for grid init
            grid.init();
            
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                estimateId: estimateId
            }, Timeline.getRows_CallBack);
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }

    },
    defineAddPropForColumn : function(column){
        column.header = JSON.parse(column.header);
        column.editor = Slick.Editors.Text;
        column.width = parseInt(column.width);
        column.order = parseInt(column.order);
        column["usedForCalculation"] = true;
        column["headerCssClass"] = "Fixed-Header-Style";
        // 09/23: RJ Added below line for applying css on hours column too. 
        column["cssClass"] = "hours-cell-style-text-center";
        column["validator"] = Timeline.numFieldValidator;
        column.asyncPostRender = function(cellNode, row, dataContext, colDef) {
                //console.log('postrender');
                if(row < Timeline.fixedRows){
                     if(data[row].id == Timeline.fixedRowsTypes.total.id){
                        var sum = 0;
                        var rowData = data.slice(row + 1);
                         $.each(rowData, function(indx, rowItem) {
                            sum += (typeof rowItem[colDef.id] == 'undefined' || rowItem[colDef.id] == ''? 0 : parseInt(rowItem[colDef.id]));
                         });
                         $(cellNode).empty().html(sum).addClass('slds-totalhrsperweek-cell');;//.css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                     }
                     if(data[row].id == Timeline.fixedRowsTypes.hoursperphase.id){
                                 var sum = 0;
                                 var selectedPhase = data[Timeline.fixedRowsTypes.phase.rowIndex][colDef.id];
                                 if(selectedPhase != ''){
                                     var rowData = data.slice(Timeline.fixedRows);
                                     var colData = columns.slice(Timeline.fixedColumns);
                                     $.each(rowData, function(indx, rowItem) {
                                        var row_sum = 0; 
                                        $.each(colData, function(indx1, colItem) {
                                           if(typeof selectedPhase != 'undefined' && 
                                                       typeof data[Timeline.fixedRowsTypes.phase.rowIndex] != 'undefined' && 
                                                       typeof data[Timeline.fixedRowsTypes.phase.rowIndex][colItem.id] != 'undefined' && 
                                                       data[Timeline.fixedRowsTypes.phase.rowIndex][colItem.id].toLowerCase() == selectedPhase.toLowerCase() && 
                                                       (typeof colItem.notUsedForCalculation == 'undefined' || !colItem.notUsedForCalculation)) {
                                               row_sum += (typeof rowItem[colItem.id] == 'undefined' || rowItem[colItem.id] == ''? 0 : parseInt(rowItem[colItem.id]));
                                           }       
                                        });
                                        sum += parseInt(row_sum);
                                     });
                                     $(cellNode).css({'text-align' : 'center', 'background-color': (typeof renderOptions_Phases[selectedPhase] == 'undefined' ? '' : renderOptions_Phases[selectedPhase]), 'color' : '#fff'});
                                     $(cellNode).empty().html(sum);  
                                 }else{
                                      $(cellNode).css({'text-align' : 'center', 'background-color': '', 'color' : ''});  
                                      $(cellNode).empty().html('');
                                 }
                                 //$(cellNode).empty().css(Timeline.hoursperphase_cols_css);
                     }
                     
                     
                     var meta_info = Timeline.fixedRowsTypes[data[row].id];
                      if(typeof meta_info != 'undefined'){
                          var colorCodePostFix = meta_info.colorcodepostfix;
                          var apply_css = meta_info.apply_css;
                          
                          if(meta_info.id == Timeline.fixedRowsTypes.phase.id){
                              $(cellNode).css({'background-color': '', 'color' : '#000000'});
                              var phase_value = data[row][colDef.id];
                              if(typeof renderOptions_Phases != 'undefined' && typeof phase_value != 'undefined' && typeof renderOptions_Phases[phase_value] != 'undefined') $(cellNode).css({'background-color': renderOptions_Phases[phase_value], 'color' : '#FFFFFF'});
                            
                          }else if(typeof colorCodePostFix != 'undefined' && typeof apply_css != 'undefined' && apply_css == true){
                               var backgroundColor = data[row][colDef.id + colorCodePostFix]; 
                               $(cellNode).css({'background-color': '', 'color' : '#000000'}); 
                               if(typeof backgroundColor != 'undefined') $(cellNode).css({'text-align' : 'center', 'background-color': backgroundColor, 'color' : (backgroundColor == '' ? '#000' : '#eee')});
                          }
                      }
                      
                }else{
                    return;
                }
        };
        
        
        return column;
    },
    getColumns_Callback: {
        onSuccess: function(result) {
            //result = (result.length > 0 ? result[0] : result); 
            columns = Timeline.getDefaultColumns();
            
            if(result.length == 0) $('#build_div').show();
            
            $.each(result, function(indx, column) {
                columns.push(Timeline.defineAddPropForColumn(column));
            });
            // clear the initital array
            result = [];
            // set the grid's columns as the new columns
            columns = columns.concat(Timeline.getEndColumns());
            grid.setColumns(columns);
             // when columns are now in; go for grid init
            grid.init();
            loader.hide();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }

    },
    getRows: function() {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
            estimateId: estimateId
        }, Timeline.getRows_CallBack);
    },
    
    
    
    getRows_CallBack: {
        onSuccess: function(result) {
            data = [];
            
            
            for(var _a in Timeline.fixedRowsTypes){
                var row = {
                    id : _a
                };
                
                $.each(columns, function(indx1, colRow) {
                    if(indx1 >= Timeline.fixedColumns){
                      //console.log('phase' + indx1 + ':' + (typeof colRow.phase == 'undefined' || colRow.phase == null ? '' : colRow.phase));    
                      var meta_info = Timeline.fixedRowsTypes[row.id];
                      if(typeof meta_info != 'undefined'){
                          row[colRow.id] = meta_info.defaultValue;
                          var valueField = meta_info.valuefield;
                          var colorCodeField = meta_info.colorcodefield;
                          var colorCodePostFix = meta_info.colorcodepostfix;
                          if(typeof valueField != 'undefined'){
                            row[colRow.id] = (typeof colRow[valueField] == 'undefined' || colRow[valueField] == null ? '' : colRow[valueField]);  
                          } 
                          
                          if(typeof colorCodeField != 'undefined' && typeof colorCodePostFix != 'undefined'){
                            row[colRow.id + colorCodePostFix] = (typeof colRow[colorCodeField] == 'undefined' || colRow[colorCodeField] == null ? '' : colRow[colorCodeField]); 
                          }
                      }
                    }        
                });
                data.push(row);
                
            }
            
           
            $.each(result, function(indx, row) {
                row.cost = parseInt(row.cost);
                row.rate = parseInt(row.rate);
                if (typeof row.colRows != 'undefined') {
                    if (row.colRows.constructor === Array) {
                        $.each(row.colRows, function(indx1, colRow) {
                            row[colRow.columnId] = parseInt(colRow.hours);
                        });
                    } else {
                        row[row.colRows.columnId] = parseInt(row.colRows.hours);
                    }
                }
                
                data.push(row);
            });

            // clear the initital array
            result = [];
             
            Timeline.bindMetadata();                      
            grid.setData(data);
            Timeline.renderGrid();
            //grid.init();
            loadSpinner.hide();
            loader.hide();
        },
        onFailure: function(error) {
            alert(error);
            loadSpinner.hide();
            loader.hide();
        }

    },
    onStartDateSelectionChange: function(sDate) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "onStartDateSelectionChange", {
            estimateId: estimateId,
            sDate: sDate,
            order: 1,
            name: 'Week1'
        }, Timeline.onStartDateSelectionChange_Callback);
    },

    onStartDateSelectionChange_Callback: {
        onSuccess: function(result) {
            //alert('in in in');
            //alert(result);
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    addMoreColumnsOnRight: function(weekId, noOfColumnsToAdd) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "addMoreColumnsOnRight", { 
            estimateId: estimateId,
            weekId: weekId,
            noOfColumnsToAdd: noOfColumnsToAdd
        }, Timeline.addMoreColumnsOnRight_Callback);
    },
    addMoreColumnsOnRight_Callback: {
        onSuccess: function(result) {
            
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            
            // Refresh top panel on estimate on resource change
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    addMoreColumnsOnLeft: function(weekId, noOfColumnsToAdd) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "addMoreColumnsOnLeft", {
            estimateId: estimateId,
            weekId: weekId,
            noOfColumnsToAdd: noOfColumnsToAdd
        }, Timeline.addMoreColumnsOnLeft_Callback);
    },
    addMoreColumnsOnLeft_Callback: {
        onSuccess: function(result) {
            
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            
            // Refresh top panel on estimate on resource change
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    deleteColumn: function(weekId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "deleteColumn", {
            estimateId: estimateId,
            weekId: weekId
        }, Timeline.deleteColumn_Callback);
    },
    deleteColumn_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // Refresh top panel on estimate on resource change
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    deleteRow: function(link) {
        var result = confirm("Are you sure you want to permenantly delete this record!");
        if (result == true) {
            var rowId = ($(link).attr('rowId'));
            loader.show();
            sforce.apex.execute(WEBSERVICE_NAME, "deleteRow", {
                rowId: rowId
            }, Timeline.deleteRow_Callback);
        }
    },
    deleteRow_Callback: {
        onSuccess: function(result) {

            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                estimateId: estimateId
            }, Timeline.getRows_CallBack);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    addRow: function(estimateId, order,
        cost, rate, role, e2role,
        skill, rateCode, estimateRateCardId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "addRow", {
            estimateId: estimateId,
            order: ((data.length - Timeline.fixedRows) + 1),
            cost: cost,
            rate: rate,
            role: role,
            e2role: e2role,
            skill: skill,
            rateCode: rateCode,
            estimateRateCardId : estimateRateCardId
        }, Timeline.addRow_Callback);
       
    },
    addRow_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // Refresh top panel on estimate on resource change
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    updateRow: function(estimateId, rowId,
        role, e2role,
        skill, rateCode, cost,rate,estimateRateCardId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "updateRow", {
            estimateId: estimateId,
            rowId: rowId,
            role: role,
            e2role: e2role,
            skill: skill,
            rateCode: rateCode,
            cost: cost, 
            rate: rate,  
            estimateRateCardId: estimateRateCardId
        }, Timeline.updateRow_Callback);
    },
    updateRow_Callback: {
        onSuccess: function(result) {

            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            //loader.hide();
            // Refresh top panel on estimate on resource change
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            // Because we need rate and cost updated as per the latest selected resource
            // also needed the phases/milestone data too.
             sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    reOrderResources: function(data) {
        if (data.length > 0) {
            loader.show();
            var nodes_order_json = '[';
            
            $.each(data, function(indx, row) {
                // bypass fixedRows count
                if(indx >= Timeline.fixedRows) nodes_order_json += '{"resourceId":"' + row.id + '", "displayOrder":"' + ((indx + 1) - Timeline.fixedRows) + '"},';
            });
            nodes_order_json = nodes_order_json.slice(0, -1);
            nodes_order_json += ']';

            sforce.apex.execute(WEBSERVICE_NAME, "reOrderResources", {
                jsonstr: nodes_order_json
            }, Timeline.reOrderResources_Callback);
        }
    },
    reOrderResources_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            loader.hide();
            Timeline.renderGrid();
            //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
            //    estimateId: estimateId
            //}, Timeline.getRows_CallBack);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    updateHours_call_register: {},
    updateHours: function(weekId, resourceId, hours) {
        loader.show();
        var hrs = 0;
        if(hours != '' && !isNaN(hours)) hrs = parseInt(hours);
        Timeline.updateHours_call_register[weekId + '-' + resourceId] = 'hrs';  
        sforce.apex.execute(WEBSERVICE_NAME, "updateHours", {
            weekId: weekId,
            resourceId: resourceId,
            hours: hrs
        }, Timeline.updateHours_Callback);
        
    },
    updateHours_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateHours_call_register && Timeline.updateHours_call_register[result]){ delete Timeline.updateHours_call_register[result];}
            if (Timeline.updateHours_call_register && JSON.stringify(Timeline.updateHours_call_register) == '{}') {
                loader.hide();
                if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            } 
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    updateSkill: function(resourceId, skill) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "updateSkill", {
            estimateId: estimateId,
            resourceId: resourceId,
            skill: skill
        }, Timeline.updateSkill_Callback);
        
    },
    
    
    updateSkill_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
           
            loader.hide();
                
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    updatePhaseAndColorCode_call_register: {},
    updatePhaseAndColorCode: function(weekId, phase, colorCode) {
        loader.show();
        Timeline.updatePhaseAndColorCode_call_register[weekId] = 'phaseAndColorCode';  
        sforce.apex.execute(WEBSERVICE_NAME, "updatePhaseAndColorCode", {
            weekId: weekId,
            phase: phase,
            colorCode: colorCode
        }, Timeline.updatePhaseAndColorCode_Callback);
        
    },
    updatePhaseAndColorCode_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updatePhaseAndColorCode_call_register && Timeline.updatePhaseAndColorCode_call_register[result]){ delete Timeline.updatePhaseAndColorCode_call_register[result];}
            if (Timeline.updatePhaseAndColorCode_call_register && JSON.stringify(Timeline.updatePhaseAndColorCode_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
            
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    
    updatePhase_call_register: {},
    updatePhase: function(weekId, phase) {
        loader.show();
        Timeline.updatePhase_call_register[weekId] = Timeline.fixedRowsTypes.phase.id;  
        sforce.apex.execute(WEBSERVICE_NAME, "updatePhase", {
            weekId: weekId,
            phase: phase
        }, Timeline.updatePhase_Callback);
        
    },
    updatePhase_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updatePhase_call_register && Timeline.updatePhase_call_register[result]){ delete Timeline.updatePhase_call_register[result];}
            if (Timeline.updatePhase_call_register && JSON.stringify(Timeline.updatePhase_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
            
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    updatePhaseColorCode_call_register: {},
    updatePhaseColorCode: function(weekId, phaseColorCode) {
        loader.show();
        Timeline.updatePhaseColorCode_call_register[weekId] = 'phaseColorCode';  
        sforce.apex.execute(WEBSERVICE_NAME, "updatePhaseColorCode", {
            weekId: weekId,
            phaseColorCode: phaseColorCode
        }, Timeline.updatePhaseColorCode_Callback);
        
    },
    updatePhaseColorCode_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updatePhaseColorCode_call_register && Timeline.updatePhaseColorCode_call_register[result]){ delete Timeline.updatePhaseColorCode_call_register[result];}
            if (Timeline.updatePhaseColorCode_call_register && JSON.stringify(Timeline.updatePhaseColorCode_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
            
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    updateMilestone_call_register: {},
    updateMilestone: function(weekId, milestone) {
        loader.show();
        Timeline.updateMilestone_call_register[weekId] = Timeline.fixedRowsTypes.milestone.id; 
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestone", {
            weekId: weekId,
            milestone: milestone
        }, Timeline.updateMilestone_Callback);
        
    },
    updateMilestone_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestone_call_register && Timeline.updateMilestone_call_register[result]){ delete Timeline.updateMilestone_call_register[result];}
            if (Timeline.updateMilestone_call_register && JSON.stringify(Timeline.updateMilestone_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    updateMilestone1_call_register: {},
    updateMilestone1: function(weekId, milestone1) {
        loader.show();
        Timeline.updateMilestone1_call_register[weekId] = Timeline.fixedRowsTypes.milestone1.id; 
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestone1", {
            weekId: weekId,
            milestone1: milestone1
        }, Timeline.updateMilestone1_Callback);
        
    },
    updateMilestone1_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestone1_call_register && Timeline.updateMilestone1_call_register[result]){ delete Timeline.updateMilestone1_call_register[result];}
            if (Timeline.updateMilestone1_call_register && JSON.stringify(Timeline.updateMilestone1_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    updateMilestone2_call_register: {},
    updateMilestone2: function(weekId, milestone2) {
        loader.show();
        Timeline.updateMilestone2_call_register[weekId] = Timeline.fixedRowsTypes.milestone2.id; 
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestone2", {
            weekId: weekId,
            milestone2: milestone2
        }, Timeline.updateMilestone2_Callback);
        
    },
    updateMilestone2_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestone2_call_register && Timeline.updateMilestone2_call_register[result]){ delete Timeline.updateMilestone2_call_register[result];}
            if (Timeline.updateMilestone2_call_register && JSON.stringify(Timeline.updateMilestone2_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    updateMilestoneColorCode_call_register: {},
    updateMilestoneColorCode: function(weekId, milestoneColorCode) {
        loader.show();
        Timeline.updateMilestoneColorCode_call_register[weekId] = 'milestonecolor'; 
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestoneColorCode", {
                                                                            weekId: weekId,
                                                                            milestoneColorCode: milestoneColorCode
                                                                        }, Timeline.updateMilestoneColorCode_Callback);
        
    },
    updateMilestoneColorCode_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestoneColorCode_call_register && Timeline.updateMilestoneColorCode_call_register[result]){ delete Timeline.updateMilestoneColorCode_call_register[result];}
            if (Timeline.updateMilestoneColorCode_call_register && JSON.stringify(Timeline.updateMilestoneColorCode_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert('ERROR:' + error);
            loader.hide();
        }
    },
   
   updateMilestoneColorCode1_call_register: {},
   updateMilestoneColorCode1: function(weekId, milestoneColorCode1) {
        loader.show();
        Timeline.updateMilestoneColorCode1_call_register[weekId] = 'milestonecolor1'; 
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestoneColorCode1", {
                                                                            weekId: weekId,
                                                                            milestoneColorCode1: milestoneColorCode1
                                                                        }, Timeline.updateMilestoneColorCode1_Callback);
        
    },
   updateMilestoneColorCode1_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestoneColorCode1_call_register && Timeline.updateMilestoneColorCode1_call_register[result]){ delete Timeline.updateMilestoneColorCode1_call_register[result];}
            if (Timeline.updateMilestoneColorCode1_call_register && JSON.stringify(Timeline.updateMilestoneColorCode1_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert('ERROR:' + error);
            loader.hide();
        }
    }, 
   
   updateMilestoneColorCode2_call_register: {},
   updateMilestoneColorCode2: function(weekId, milestoneColorCode2) {
        loader.show();
        Timeline.updateMilestoneColorCode2_call_register[weekId] = 'milestonecolor2'; 
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestoneColorCode2", {
                                                                            weekId: weekId,
                                                                            milestoneColorCode2: milestoneColorCode2
                                                                        }, Timeline.updateMilestoneColorCode2_Callback);
        
    },
   updateMilestoneColorCode2_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            // if there is no failure; delete respective call registers
            if (Timeline.updateMilestoneColorCode2_call_register && Timeline.updateMilestoneColorCode2_call_register[result]){ delete Timeline.updateMilestoneColorCode2_call_register[result];}
            if (Timeline.updateMilestoneColorCode2_call_register && JSON.stringify(Timeline.updateMilestoneColorCode2_call_register) == '{}') {
                loader.hide();
                //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
                //    estimateId: estimateId
                //}, Timeline.getRows_CallBack);
            }
        },
        onFailure: function(error) {
            alert('ERROR:' + error);
            loader.hide();
        }
    },
   
    updateColorCode: function(jsonstr) {
        loader.show();
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateColorCode", {
            jsonstr: jsonstr
        }, Timeline.updateColorCode_Callback);
        
    },
    
    updateColorCode_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            
            loader.hide();
            //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
            //    estimateId: estimateId
            //}, Timeline.getRows_CallBack);
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    updateMilestoneWeeks: function(jsonstr) {
        loader.show();
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestoneWeeks", {
            jsonstr: jsonstr
        }, Timeline.updateMilestoneWeeks_Callback);
        
    },
    
    updateMilestoneWeeks_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            
            loader.hide();
            //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
            //    estimateId: estimateId
            //}, Timeline.getRows_CallBack);
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    autoFill: function(jsonstr) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "autoFill", {
            jsonstr: jsonstr
        }, Timeline.autoFill_Callback);
    },
    autoFill_Callback: {
        onSuccess: function(result) {

            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            loader.hide();
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            //sforce.apex.execute(WEBSERVICE_NAME, "getTimelineRows", {
            //    estimateId: estimateId
            //}, Timeline.getRows_CallBack);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    updateEstimateRateCards: function(){
        loadSpinner.show();
        // invoke action function
        updateEstimateRateCards();
        return false;
    },
    updateEstimateRateCards_complete: function(){
        loadSpinner.hide();
        makeManageRateCardsCollapsible();
        CustomAlert.show('Rate card has been successfully updated!!!');
        tabpanel.showTimelineTab();
        if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
        reFreshGrid();
    },
    refreshRateCardRatesAndCost: function(){
        if(!confirm('Refreshing cost and rate will updated existing rate card entries with the latest rates & cost in the system!!\nAre you sure you want to try this?')){
            return false;
        }
        loadSpinner.show();
        // invoke action function
        refreshRateCardRatesAndCost();
        return false;
    },
    refreshRateCardRatesAndCost_complete: function(){
        loadSpinner.hide();
        makeManageRateCardsCollapsible();
        CustomAlert.show('Rate card has been successfully refreshed!!!');
        tabpanel.showTimelineTab();
        if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
        reFreshGrid();
    },
    updateResourceWeeks: function(jsonstr) {
        loader.show();
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateResourceWeeks", {
            jsonstr: jsonstr
        }, Timeline.updateResourceWeeks_Callback);
        
    },
    
    updateResourceWeeks_Callback: {
        onSuccess: function(result) {
            result = (result.length > 0 ? result[0] : result);
            // check for failure message, show alert and stop
            if (result.indexOf('Fail') != -1) {
                var exception = 'INSUFFICIENT_ACCESS_OR_READONLY';
                if (result.toLowerCase().indexOf(exception.toLowerCase()) != -1) {
                    alert(result); //CustomAlert.showError('Reparenting Failed: You do not have permission to reparent this scope!!! Please contact scope owner for reparenting!!');    
                } else {
                    alert(result);
                }
                loader.hide();
                return;
            }
            if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
            loader.hide();
            Timeline.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    }
    
}
// method for numeric field validation
var applyNumericValidation = function(){
            $('.mandate-numeric-estimate').keyup(function(evt) {		    
		    $('body div.slds-error--tooltip').remove();
		    var inputVal = $(this).val();
		    var numericReg = /^[0-9]*$/;
		    if(!numericReg.test(inputVal)) {
		        $(this).val(inputVal.substring(0, inputVal.length - 1)); 
		        $(document.body).append('<div class="slds slds-error--tooltip"><div class="slds slds-popover slds-popover--tooltip slds-nubbin--bottom" role="tooltip"><div class="slds-popover__body">Numeric only.</div></div></div>');
		        var top = $(this).offset().top - ($(this).height() + 10) + 'px';
		        var left = $(this).offset().left + 'px';
		        $('body div.slds-error--tooltip').css({position : 'absolute', top : top , left : left});
		    }
		    
		});
		
		$('.mandate-numeric-estimate').blur(function(evt) {
		   $('body div.slds-error--tooltip').remove(); 
		});
}