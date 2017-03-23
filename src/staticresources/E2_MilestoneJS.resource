(function ($) {
  // register namespace
  $.extend(true, window, {
    "Slick": {
      "CellCopyManager": CellCopyManager
    }
  });


  function CellCopyManager() {
    var _grid;
    var _self = this;
    var _copiedRanges;

    function init(grid) {
      _grid = grid;
      _grid.onKeyDown.subscribe(handleKeyDown);
    }

    function destroy() {
      _grid.onKeyDown.unsubscribe(handleKeyDown);
    }

    function handleKeyDown(e, args) {
      var ranges;
      if (!_grid.getEditorLock().isActive()) {
        if (e.which == $.ui.keyCode.ESCAPE) {
          if (_copiedRanges) {
            e.preventDefault();
            clearCopySelection();
            _self.onCopyCancelled.notify({ranges: _copiedRanges});
            _copiedRanges = null;
          }
        }

        if (e.which == 67 && (e.ctrlKey || e.metaKey)) {
          ranges = _grid.getSelectionModel().getSelectedRanges();
          if (ranges.length != 0) {
            e.preventDefault();
            _copiedRanges = ranges;
            markCopySelection(ranges);
            _self.onCopyCells.notify({ranges: ranges});
          }
        }

        if (e.which == 86 && (e.ctrlKey || e.metaKey)) {
          if (_copiedRanges) {
            e.preventDefault();
            clearCopySelection();
            ranges = _grid.getSelectionModel().getSelectedRanges();
            _self.onPasteCells.notify({from: _copiedRanges, to: ranges}); 
            
            // 12 Aug 2016: RJ: Commented this line to allow user to paste the copied data as much as possible on
            // this screen
            //_copiedRanges = null;
          }
        }
      }
    }

    function markCopySelection(ranges) {
      var columns = _grid.getColumns();
      var hash = {};
      for (var i = 0; i < ranges.length; i++) {
        for (var j = ranges[i].fromRow; j <= ranges[i].toRow; j++) {
          hash[j] = {};
          for (var k = ranges[i].fromCell; k <= ranges[i].toCell; k++) {
            hash[j][columns[k].id] = "copied";
          }
        }
      }
      _grid.setCellCssStyles("copy-manager", hash);
    }

    function clearCopySelection() {
      _grid.removeCellCssStyles("copy-manager");
    }

    $.extend(this, {
      "init": init,
      "destroy": destroy,
      "clearCopySelection": clearCopySelection,

      "onCopyCells": new Slick.Event(),
      "onCopyCancelled": new Slick.Event(),
      "onPasteCells": new Slick.Event()
    });
  }
})(jQuery);

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

(function($) {
    // register namespace
    $.extend(true, window, {
        "Slick": {
            "CellSelectionModel": CellSelectionModel
        }
    });
    function CellSelectionModel(options) {
        var _grid;
        var _canvas;
        var _ranges = [];
        var _self = this;
        var _selector = new Slick.CellRangeSelector({
            "selectionCss": {
                "border": "2px solid black"
            }
        });
        var _options;
        var _defaults = {
            selectActiveCell: true
        };


        function init(grid) {
            _options = $.extend(true, {}, _defaults, options);
            _grid = grid;
            _canvas = _grid.getCanvasNode();
            _grid.onActiveCellChanged.subscribe(handleActiveCellChange);
            _grid.onKeyDown.subscribe(handleKeyDown);
            grid.registerPlugin(_selector);
            _selector.onCellRangeSelected.subscribe(handleCellRangeSelected);
            _selector.onBeforeCellRangeSelected.subscribe(handleBeforeCellRangeSelected);
        }

        function destroy() {
            _grid.onActiveCellChanged.unsubscribe(handleActiveCellChange);
            _grid.onKeyDown.unsubscribe(handleKeyDown);
            _selector.onCellRangeSelected.unsubscribe(handleCellRangeSelected);
            _selector.onBeforeCellRangeSelected.unsubscribe(handleBeforeCellRangeSelected);
            _grid.unregisterPlugin(_selector);
        }

        function removeInvalidRanges(ranges) {
            var result = [];

            for (var i = 0; i < ranges.length; i++) {
                var r = ranges[i];
                if (_grid.canCellBeSelected(r.fromRow, r.fromCell) && _grid.canCellBeSelected(r.toRow, r.toCell)) {
                    result.push(r);
                }
            }

            return result;
        }

        function setSelectedRanges(ranges) {
            _ranges = removeInvalidRanges(ranges);
            _self.onSelectedRangesChanged.notify(_ranges);
        }

        function getSelectedRanges() {
            return _ranges;
        }

        function handleBeforeCellRangeSelected(e, args) {
            if (_grid.getEditorLock().isActive()) {
                e.stopPropagation();
                return false;
            }
        }

        function handleCellRangeSelected(e, args) {
            setSelectedRanges([args.range]);
        }

        function handleActiveCellChange(e, args) {
            if (_options.selectActiveCell && args.row != null && args.cell != null) {
                setSelectedRanges([new Slick.Range(args.row, args.cell)]);
            }
        }

        function handleKeyDown(e) {
            /***
             * ?ey codes
             * 37 left
             * 38 up
             * 39 right
             * 40 down                     
             */
            var ranges, last;
            var active = _grid.getActiveCell();
            //console.log('1' + active);
            if (active && e.shiftKey && !e.ctrlKey && !e.altKey &&
                (e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40)) {

                ranges = getSelectedRanges();
                if (!ranges.length)
                    ranges.push(new Slick.Range(active.row, active.cell));

                // keyboard can work with last range only          
                last = ranges.pop();

                // can't handle selection out of active cell
                if (!last.contains(active.row, active.cell))
                    last = new Slick.Range(active.row, active.cell);

                var dRow = last.toRow - last.fromRow,
                    dCell = last.toCell - last.fromCell,
                    // walking direction
                    dirRow = active.row == last.fromRow ? 1 : -1,
                    dirCell = active.cell == last.fromCell ? 1 : -1;

                if (e.which == 37) {
                    dCell -= dirCell;
                } else if (e.which == 39) {
                    dCell += dirCell;
                } else if (e.which == 38) {
                    dRow -= dirRow;
                } else if (e.which == 40) {
                    dRow += dirRow;
                }

                // define new selection range 
                var new_last = new Slick.Range(active.row, active.cell, active.row + dirRow * dRow, active.cell + dirCell * dCell);
                if (removeInvalidRanges([new_last]).length) {
                    ranges.push(new_last);
                    var viewRow = dirRow > 0 ? new_last.toRow : new_last.fromRow;
                    var viewCell = dirCell > 0 ? new_last.toCell : new_last.fromCell;
                    _grid.scrollRowIntoView(viewRow);
                    _grid.scrollCellIntoView(viewRow, viewCell);
                } else
                    ranges.push(last);

                setSelectedRanges(ranges);

                e.preventDefault();
                e.stopPropagation();
            }
        }

        $.extend(this, {
            "getSelectedRanges": getSelectedRanges,
            "setSelectedRanges": setSelectedRanges,

            "init": init,
            "destroy": destroy,

            "onSelectedRangesChanged": new Slick.Event()
        });
    }
})(jQuery);



(function($) {
    // register namespace
    $.extend(true, window, {
        "Slick": {
            "CellRangeSelector": CellRangeSelector
        }
    });


    function CellRangeSelector(options) {
        var _grid;
        var _gridOptions;
        var _$activeCanvas;
        var _dragging;
        var _decorator;
        var _self = this;
        var _handler = new Slick.EventHandler();
        var _defaults = {
            selectionCss: {
                "border": "2px dashed blue"
            }
        };
        
        // Frozen row & column variables
        var _rowOffset;
        var _columnOffset;
        var _isRightCanvas;
        var _isBottomCanvas;


        function init(grid) {
            options = $.extend(true, {}, _defaults, options);
            _decorator = new Slick.CellRangeDecorator(grid, options);
            _grid = grid;
            _gridOptions = _grid.getOptions();
            _handler
                .subscribe(_grid.onDragInit, handleDragInit)
                .subscribe(_grid.onDragStart, handleDragStart)
                .subscribe(_grid.onDrag, handleDrag)
                .subscribe(_grid.onDragEnd, handleDragEnd);
        }

        function destroy() {
            _handler.unsubscribeAll();
        }

        function handleDragInit(e, dd) {
            
            // Set the active canvas node because the decorator needs to append its
            // box to the correct canvas
            _$activeCanvas = $( _grid.getActiveCanvasNode( e ) );
    
            var c = _$activeCanvas.offset();
    
            _rowOffset = 0;
            _columnOffset = 0;
            _isBottomCanvas = _$activeCanvas.hasClass( 'grid-canvas-bottom' );
    
            if ( _gridOptions.frozenRow > -1 && _isBottomCanvas ) {
                _rowOffset = ( _gridOptions.frozenBottom ) ? $('.grid-canvas-bottom').height() : $('.grid-canvas-top').height();
            }
            
            _isRightCanvas = _$activeCanvas.hasClass( 'grid-canvas-right' );
            
            if ( _gridOptions.frozenColumn > -1 && _isRightCanvas ) {
                _columnOffset = $('.grid-canvas-left').width();
            }
            
            //S-448253 : commit current edit to resolve double drag problem
            if(typeof Slick.GlobalEditorLock.commitCurrentEdit != 'undefined') {
              window.setTimeout(function(){
                Slick.GlobalEditorLock.commitCurrentEdit();
              },  0);
            }
            // prevent the grid from cancelling drag'n'drop by default
            e.stopImmediatePropagation();
        }

        function handleDragStart(e, dd) {
            var cell = _grid.getCellFromEvent(e);
            if (_self.onBeforeCellRangeSelected.notify(cell) !== false) {
                if (_grid.canCellBeSelected(cell.row, cell.cell)) {
                    _dragging = true;
                    e.stopImmediatePropagation();
                }
            }
            if (!_dragging) {
                return;
            }

            _grid.focus();

            // new code
            var start = _grid.getCellFromPoint(
                dd.startX - _$activeCanvas.offset().left + _columnOffset,
                dd.startY - _$activeCanvas.offset().top + _rowOffset);

            dd.range = {
                start: start,
                end: {}
            };

            return _decorator.show(new Slick.Range(start.row, start.cell));
        }

        function handleDrag(e, dd) {
            if (!_dragging) {
                return;
            }
            e.stopImmediatePropagation();

            var end = _grid.getCellFromPoint(
                e.pageX - _$activeCanvas.offset().left + _columnOffset,
                e.pageY - _$activeCanvas.offset().top + _rowOffset
            );

            if (!_grid.canCellBeSelected(end.row, end.cell)) {
                return;
            }

            dd.range.end = end;
            // RJ: 11/23: Scroll Row into view
            _grid.scrollRowIntoView(end.row);
            // scroll the viewport in case scroll bar is visible
            _grid.scrollCellIntoView(end.row, end.cell);
            _decorator.show(new Slick.Range(dd.range.start.row, dd.range.start.cell, end.row, end.cell));
        }

        function handleDragEnd(e, dd) {
            if (!_dragging) {
                return;
            }

            _dragging = false;
            e.stopImmediatePropagation();

            _decorator.hide();
            _self.onCellRangeSelected.notify({
                range: new Slick.Range(
                    dd.range.start.row,
                    dd.range.start.cell,
                    dd.range.end.row,
                    dd.range.end.cell
                )
            });
        }

        $.extend(this, {
            "init": init,
            "destroy": destroy,

            "onBeforeCellRangeSelected": new Slick.Event(),
            "onCellRangeSelected": new Slick.Event()
        });
    }
})(jQuery);

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


(function ($) {
  // register namespace
  $.extend(true, window, {
    "Slick": {
      "CellExternalCopyManager": CellExternalCopyManager
    }
  });


  function CellExternalCopyManager(options) {
    /*
      This manager enables users to copy/paste data from/to an external Spreadsheet application
      such as MS-Excel® or OpenOffice-Spreadsheet.
      
      Since it is not possible to access directly the clipboard in javascript, the plugin uses
      a trick to do it's job. After detecting the keystroke, we dynamically create a textarea
      where the browser copies/pastes the serialized data. 
      
      options:
        copiedCellStyle : sets the css className used for copied cells. default : "copied"
        copiedCellStyleLayerKey : sets the layer key for setting css values of copied cells. default : "copy-manager"
        dataItemColumnValueExtractor : option to specify a custom column value extractor function
        dataItemColumnValueSetter : option to specify a custom column value setter function
        clipboardCommandHandler : option to specify a custom handler for paste actions
        includeHeaderWhenCopying : set to true and the plugin will take the name property from each column (which is usually what appears in your header) and put that as the first row of the text that's copied to the clipboard
        bodyElement: option to specify a custom DOM element which to will be added the hidden textbox. It's useful if the grid is inside a modal dialog.
        onCopyInit: optional handler to run when copy action initializes
        onCopySuccess: optional handler to run when copy action is complete
    */
    var _grid;
    var _self = this;
    var _copiedRanges;
    var _options = options || {};
    var _copiedCellStyleLayerKey = _options.copiedCellStyleLayerKey || "copy-manager";
    var _copiedCellStyle = _options.copiedCellStyle || "copied";
    var _clearCopyTI = 0;
    var _bodyElement = _options.bodyElement || document.body;
    var _onCopyInit = _options.onCopyInit || null;
    var _onCopySuccess = _options.onCopySuccess || null;
    var _scrollInterval;
    
    var keyCodes = {
      'C': 67,
      'V': 86,
      'ESC': 27,
      'INSERT': 45
    };

    function init(grid) {
	  _grid = grid;
      _grid.onKeyDown.subscribe(handleKeyDown);
      
      // we need a cell selection model
      var cellSelectionModel = grid.getSelectionModel();
      if (!cellSelectionModel){
        throw new Error("Selection model is mandatory for this plugin. Please set a selection model on the grid before adding this plugin: grid.setSelectionModel(new Slick.CellSelectionModel())");
      }
      // we give focus on the grid when a selection is done on it.
      // without this, if the user selects a range of cell without giving focus on a particular cell, the grid doesn't get the focus and key stroke handles (ctrl+c) don't work
      //cellSelectionModel.onSelectedRangesChanged.subscribe(function(e, args){
      //  _grid.focus();
      //});
    }

    function destroy() {
      _grid.onKeyDown.unsubscribe(handleKeyDown);
    }
    
    function getDataItemValueForColumn(item, columnDef) {
      if (_options.dataItemColumnValueExtractor) {
        var dataItemColumnValueExtractorValue = _options.dataItemColumnValueExtractor(item, columnDef);

        if (dataItemColumnValueExtractorValue)
          return dataItemColumnValueExtractorValue;
      }

      var retVal = '';

      // if a custom getter is not defined, we call serializeValue of the editor to serialize
      if (columnDef.editor){
        var editorArgs = {
          'container':$("<p>"),  // a dummy container
          'column':columnDef,
          'position':{'top':0, 'left':0},  // a dummy position required by some editors
          'grid':_grid
        };
        var editor = new columnDef.editor(editorArgs);
        editor.loadValue(item);
        retVal = editor.serializeValue();
        editor.destroy();
      }
      else {
        retVal = item[columnDef.field];
      }
      return retVal;
    }
    
    function setDataItemValueForColumn(item, columnDef, value) {
      if (_options.dataItemColumnValueSetter) {
        return _options.dataItemColumnValueSetter(item, columnDef, value);
      }

      // if a custom setter is not defined, we call applyValue of the editor to unserialize
      if (columnDef.editor){
        var editorArgs = {
          'container':$("body"),  // a dummy container
          'column':columnDef,
          'position':{'top':0, 'left':0},  // a dummy position required by some editors
          'grid':_grid
        };
        var editor = new columnDef.editor(editorArgs);
        editor.loadValue(item);
        editor.applyValue(item, value);
        editor.destroy();
      }
    }
    
    
    function _createTextBox(innerText){
      var ta = document.createElement('textarea');
      var windowScrollTopPosition = $(window).scrollTop();
      
      ta.style.position = 'absolute';
      ta.style.left = '-1000px'; 
      ta.style.top = '0px';
      ta.style.zIndex = '-99999';
      
      ta.value = innerText;
      _bodyElement.appendChild(ta); 
      
      ta.select();
      
      ta.focus();
      
      var adjustScrollingPosition = function(){
          // clear the interval when window scroll matches the origin one
          if($(window).scrollTop() == windowScrollTopPosition){
            if(_scrollInterval) window.clearInterval(_scrollInterval);
          }  
          // set the scroll top
          $(window).scrollTop(windowScrollTopPosition); 
      }
      // clear the interval if that already exists
      if(_scrollInterval) window.clearInterval(_scrollInterval);
      // set the interval again for new operation
      _scrollInterval = window.setInterval(adjustScrollingPosition, 150);
      
      return ta;
    }
    
    function _decodeTabularData(_grid, ta){
      var columns = _grid.getColumns();
      var clipText = ta.value;
      
      if (typeof(Storage) !== 'undefined' && clipText != null && typeof clipText != 'undefined') {
        // Store
        if(sessionStorage.getItem("milestoneclipText") != null && clipText.replace(/[\n\f\r]/g, '').trim() === sessionStorage.getItem("milestoneclipText").replace(/[\n\f\r]/g, '').trim()){
            sessionStorage.setItem("isSameMilestoneText", "true");
        }
        else{
            sessionStorage.setItem("isSameMilestoneText", "false");
        }
      }
      
      // below line support when pasting from excel;
      // from excel you always get trailing new line charater 
      clipText = clipText.replace(/[\n\f\r]$/, '');
      
      var clipRows = clipText.split(/[\n\f\r]/); 
      
      var clippedRange = [];
      _bodyElement.removeChild(ta);
      
      for (var i = 0; i < clipRows.length; i++) {
        if (clipRows[i] != ""){
            clippedRange[i] = clipRows[i].split("\t");  
        }else{
          clippedRange[i] = [""];
        }
      }
      var selectedCell = _grid.getActiveCell();
      var ranges = _grid.getSelectionModel().getSelectedRanges();
      var selectedRange = ranges && ranges.length ? ranges[0] : null;   // pick only one selection
      var activeRow = null;
      var activeCell = null;
      
      if (selectedRange){
        activeRow = selectedRange.fromRow;
        activeCell = selectedRange.fromCell;
      } else if (selectedCell){
        activeRow = selectedCell.row;
        activeCell = selectedCell.cell;
      } else {
        // we don't know where to paste
        return;
      }
      
      var oneCellToMultiple = false;
      var destH = clippedRange.length;
      var destW = clippedRange.length ? clippedRange[0].length : 0;
      if (clippedRange.length == 1 && clippedRange[0].length == 1 && selectedRange){
        oneCellToMultiple = true;
        destH = selectedRange.toRow - selectedRange.fromRow + 1;
        destW = selectedRange.toCell - selectedRange.fromCell + 1;
      }
      var availableRows = _grid.getData().length - activeRow;
      var addRows = 0;
      
      /**
      if(availableRows < destH)
      {
        var d = _grid.getData();
        for(addRows = 1; addRows <= destH - availableRows; addRows++)
          d.push({});
        _grid.setData(d);
        _grid.render();
      }
      **/
      var clipCommand = {

        isClipboardCommand: true,
        clippedRange: clippedRange,
        oldValues: [],
        cellExternalCopyManager: _self,
        _options: _options,
        setDataItemValueForColumn: setDataItemValueForColumn,
        markCopySelection: markCopySelection,
        oneCellToMultiple: oneCellToMultiple,
        activeRow: activeRow,
        activeCell: activeCell,
        destH: destH,
        destW: destW,
        desty: activeRow,
        destx: activeCell,
        maxDestY: _grid.getDataLength(),
        maxDestX: _grid.getColumns().length,
        h: 0,
        w: 0,
          
        execute: function() {
          this.h = 0;
          for (var y = 0; y < destH; y++){
            this.oldValues[y] = [];
            this.w = 0;
            this.h++;
            for (var x = 0; x < destW; x++){
              this.w++;
              var desty = activeRow + y;
              var destx = activeCell + x;
              
              if (desty < this.maxDestY && destx < this.maxDestX ) {
                var nd = _grid.getCellNode(desty, destx);
                var dt = _grid.getDataItem(desty);
                this.oldValues[y][x] = dt[columns[destx]['id']];
                
                if (oneCellToMultiple)
                  this.setDataItemValueForColumn(dt, columns[destx], clippedRange[0][0]);
                else{
                  //console.log(dt.id);
                  //console.log(dt + ',' + columns[destx] + ',' + clippedRange[y] + '?' + clippedRange[y][x] + ':' + '');
                  if(typeof dt.id != 'undefined') this.setDataItemValueForColumn(dt, columns[destx], clippedRange[y] ? clippedRange[y][x] : '');
                }
                _grid.updateCell(desty, destx);
                
                // commented this out of box method; for our own purpose in e2
                /**_grid.onCellChange.notify({
                   row: desty,
                   cell: destx,
                   item: dt,
                   grid: _grid
                });**/ 
              }
            }
          }
          
          var bRange = {
            'fromCell': activeCell,
            'fromRow': activeRow,
            'toCell': activeCell + this.w - 1,
            'toRow': activeRow + this.h - 1
          }

          this.markCopySelection([bRange]);
          _grid.getSelectionModel().setSelectedRanges([bRange]);
          
          if (typeof(Storage) !== 'undefined' && (typeof _copiedRanges != 'undefined' || _copiedRanges == null) && sessionStorage.getItem("_milestoneCopiedRanges") != null) {
                // Store
                _copiedRanges = JSON.parse(sessionStorage.getItem("_milestoneCopiedRanges"));
          }
          
          this.cellExternalCopyManager.onPasteCells.notify({ranges: [bRange], clippedRange: clippedRange, oneCellToMultiple : oneCellToMultiple, copiedRanges : _copiedRanges});
        },

        undo: function() {
          for (var y = 0; y < destH; y++){
            for (var x = 0; x < destW; x++){
              var desty = activeRow + y;
              var destx = activeCell + x;
              
              if (desty < this.maxDestY && destx < this.maxDestX ) {
                var nd = _grid.getCellNode(desty, destx);
                var dt = _grid.getDataItem(desty);
                if (oneCellToMultiple)
                  this.setDataItemValueForColumn(dt, columns[destx], this.oldValues[0][0]);
                else
                  this.setDataItemValueForColumn(dt, columns[destx], this.oldValues[y][x]);
                _grid.updateCell(desty, destx);
                _grid.onCellChange.notify({
                    row: desty,
                    cell: destx,
                    item: dt,
                    grid: _grid
                });
              }
            }
          }
          
          var bRange = {
            'fromCell': activeCell,
            'fromRow': activeRow,
            'toCell': activeCell+this.w-1,
            'toRow': activeRow+this.h-1
          }

          this.markCopySelection([bRange]);
          _grid.getSelectionModel().setSelectedRanges([bRange]);
          this.cellExternalCopyManager.onPasteCells.notify({ranges: [bRange], clippedRange: clippedRange, oneCellToMultiple : oneCellToMultiple, copiedRanges : _copiedRanges});
          
          if(addRows > 1){            
            var d = _grid.getData();
            for(; addRows > 1; addRows--)
              d.splice(d.length - 1, 1);
            _grid.setData(d);
            _grid.render();
          }
        }
      };

      if(_options.clipboardCommandHandler) {
        _options.clipboardCommandHandler(clipCommand);
      }
      else {
        clipCommand.execute();
      }
    }
    
    
    function handleKeyDown(e, args) {
      var ranges;
      //alert(_grid.getOptions().autoEdit);
      //console.log(_grid.getEditorLock().isActive());
      if (!_grid.getEditorLock().isActive() || _grid.getOptions().autoEdit) {
        if (e.which == keyCodes.ESC) {
          if (_copiedRanges) {
            e.preventDefault();
            clearCopySelection();
            _self.onCopyCancelled.notify({ranges: _copiedRanges});
            _copiedRanges = null;
          }
        }

        if ((e.which === keyCodes.C || e.which === keyCodes.INSERT) && (e.ctrlKey || e.metaKey) && !e.shiftKey) {    // CTRL+C or CTRL+INS
          if (_onCopyInit) {
            _onCopyInit.call();
          }
          ranges = _grid.getSelectionModel().getSelectedRanges();
          if (ranges.length != 0) {
            _copiedRanges = ranges;
            var columns = _grid.getColumns();
            var colorRanges = [];
            if (typeof(Storage) !== 'undefined' && _copiedRanges != null && typeof _copiedRanges != 'undefined') {
                // Store
                for (var rg = 0; rg < _copiedRanges.length; rg++){
                    var rowIndex = 0;
                    for(var i = _copiedRanges[rg].fromRow; i < _copiedRanges[rg].toRow + 1 ; i++){
                        var cellValues = [];
                        var cellIndex = 0;
                        for(var j = _copiedRanges[rg].fromCell; j < _copiedRanges[rg].toCell + 1 ; j++){
                            cellValues[cellIndex] = data[i][columns[j].field + Milestone.colorcodePostFixStr];
                            cellIndex++;
                        }
                        colorRanges[rowIndex] = cellValues;
                        rowIndex++;
                    }
                }
                sessionStorage.setItem("_milestoneCopiedRanges", JSON.stringify(colorRanges));
            }
            
            markCopySelection(ranges);
            _self.onCopyCells.notify({ranges: ranges});
            
            var clipText = "";

            for (var rg = 0; rg < ranges.length; rg++){
                var range = ranges[rg];
                var clipTextRows = [];
                for (var i = range.fromRow; i < range.toRow + 1 ; i++){
                    var clipTextCells = [];
                    var dt = _grid.getDataItem(i);
                    
                    if (clipTextRows == "" && _options.includeHeaderWhenCopying) {
                        var clipTextHeaders = [];
                        for (var j = range.fromCell; j < range.toCell + 1 ; j++) {
                            if (columns[j].name.length > 0)
                                clipTextHeaders.push(columns[j].name);
                        }
                        clipTextRows.push(clipTextHeaders.join("\t"));
                    }

                    var column;
                    var prevCellText;
                    for (var j = range.fromCell; j < range.toCell + 1 ; j++){
						column = j;
						prevCellText = getDataItemValueForColumn(dt, columns[j]);
                        clipTextCells.push(prevCellText);
                    }

					if(typeof data[i] != 'undefined' && 
                        typeof data[i].id != 'undefined' 
                        //&& typeof Timeline.fixedRowsTypes[data[i].id.toLowerCase()] != 'undefined'
                        ){
                    
                        for(var cellValue = column + 1; cellValue <= columns.length - 1; cellValue++) {
                            var cellText = getDataItemValueForColumn(dt, columns[cellValue]);
                            if(cellText != '' && cellText == prevCellText) {
                                clipTextCells.push(cellText);
                            } else {
                                break;
                            }
                        }
                    }
                    clipTextRows.push(clipTextCells.join("\t"));
                }
                clipText += clipTextRows.join("\r\n") + "\r\n";
            }
            
            if(window.clipboardData) {
                window.clipboardData.setData("Text", clipText);
                if (typeof(Storage) !== 'undefined' && clipText != null && typeof clipText != 'undefined') {
                    // Store
                    sessionStorage.setItem("milestoneclipText", clipText.trim());
                }
                return true;
            }
            else {
                var $focus = $(_grid.getActiveCellNode());
                var ta = _createTextBox(clipText);
                
                if (typeof(Storage) !== 'undefined' && clipText != null && typeof clipText != 'undefined') {
                    // Store
                    sessionStorage.setItem("milestoneclipText", clipText.trim());
                }

                setTimeout(function(){
                     _bodyElement.removeChild(ta);
                    // restore focus
                    if ($focus && $focus.length>0) {
                        $focus.attr('tabIndex', '-1');
                        $focus.focus();
                        $focus.removeAttr('tabIndex');
                    }
                }, 150);

                if (_onCopySuccess) {
                    var rowCount = 0;
                    // If it's cell selection, use the toRow/fromRow fields
                    if (ranges.length === 1) {
                        rowCount = (ranges[0].toRow + 1) - ranges[0].fromRow;
                    }
                    else {
                        rowCount = ranges.length;
                    }
                    _onCopySuccess.call(this, rowCount);
                }

                return false;
            }
          }
        }

        if ((e.which === keyCodes.V && (e.ctrlKey || e.metaKey) && !e.shiftKey || (e.which === keyCodes.INSERT && e.shiftKey && !e.ctrlKey))) {    // CTRL+V or Shift+INS
            var ta = _createTextBox('');
            
            setTimeout(function(){
                _decodeTabularData(_grid, ta);
            }, 100);
            
            return false;
        }
      }
    }

    function markCopySelection(ranges) {

      clearCopySelection();
      
      var columns = _grid.getColumns();
      var hash = {};
      for (var i = 0; i < ranges.length; i++) {
        for (var j = ranges[i].fromRow; j <= ranges[i].toRow; j++) {
          hash[j] = {};
          for (var k = ranges[i].fromCell; k <= ranges[i].toCell && k < columns.length; k++) {
            hash[j][columns[k].id] = _copiedCellStyle;
          }
        }
      }
      _grid.setCellCssStyles(_copiedCellStyleLayerKey, hash);
      clearTimeout(_clearCopyTI);
      _clearCopyTI = setTimeout(function(){
        _self.clearCopySelection();
      }, 2000);
    }

    function clearCopySelection() {
      _grid.removeCellCssStyles(_copiedCellStyleLayerKey);
    }

    $.extend(this, {
      "init": init,
      "destroy": destroy,
      "clearCopySelection": clearCopySelection,
      "handleKeyDown":handleKeyDown,
      
      "onCopyCells": new Slick.Event(),
      "onCopyCancelled": new Slick.Event(),
      "onPasteCells": new Slick.Event()
    });
  }
})(jQuery);

(function ($) {
  // register namespace
  $.extend(true, window, {
    "Slick": {
      "Plugins": {
        "HeaderMenu": HeaderMenu
      }
    }
  });

  function HeaderMenu(options) {
    var _grid;
    var _self = this;
    var _handler = new Slick.EventHandler();
    var _defaults = {
      buttonCssClass: null,
      buttonImage: null
    };
    var $menu;
    var $activeHeaderColumn;


    function init(grid) {
      options = $.extend(true, {}, _defaults, options);
      _grid = grid;
      _handler
        .subscribe(_grid.onHeaderCellRendered, handleHeaderCellRendered)
        .subscribe(_grid.onBeforeHeaderCellDestroy, handleBeforeHeaderCellDestroy);

      // Force the grid to re-render the header now that the events are hooked up.
      _grid.setColumns(_grid.getColumns());

      // Hide the menu on outside click.
      $(document.body).bind("mousedown", handleBodyMouseDown);
    }


    function destroy() {
      _handler.unsubscribeAll();
      $(document.body).unbind("mousedown", handleBodyMouseDown);
    }


    function handleBodyMouseDown(e) {
      if ($menu && $menu[0] != e.target && !$.contains($menu[0], e.target)) {
        hideMenu();
      }
    }


    function hideMenu() {
      if ($menu) {
        $menu.remove();
        $menu = null;
        $activeHeaderColumn
          .removeClass("slick-header-column-active");
      }
    }

    function handleHeaderCellRendered(e, args) {
      var column = args.column;
      var menu = column.header && column.header.menu;

      if (menu) {
        var $el = $("<div></div>")
          .addClass("slick-header-menubutton")
          .data("column", column)
          .data("menu", menu);

        if (options.buttonCssClass) {
          $el.addClass(options.buttonCssClass);
        }

        if (options.buttonImage) {
          $el.css("background-image", "url(" + options.buttonImage + ")");
        }

        if (menu.tooltip) {
          $el.attr("title", menu.tooltip);
        }

        $el
          .bind("click", showMenu)
          .appendTo(args.node);
      }
    }


    function handleBeforeHeaderCellDestroy(e, args) {
      var column = args.column;

      if (column.header && column.header.menu) {
        $(args.node).find(".slick-header-menubutton").remove();
      }
    }


    function showMenu(e) {
      var $menuButton = $(this);
      var menu = $menuButton.data("menu");
      var columnDef = $menuButton.data("column");

      // Let the user modify the menu or cancel altogether,
      // or provide alternative menu implementation.
      if (_self.onBeforeMenuShow.notify({
          "grid": _grid,
          "column": columnDef,
          "menu": menu
        }, e, _self) == false) {
        return;
      }


      if (!$menu) {
        $menu = $("<div class='slick-header-menu'></div>")
          .appendTo(_grid.getContainerNode());
      }
      $menu.empty();


      // Construct the menu items.
      for (var i = 0; i < menu.items.length; i++) {
        var item = menu.items[i];

        var $li = $("<div class='slick-header-menuitem'></div>")
          .data("command", item.command || '')
          .data("column", columnDef)
          .data("item", item)
          .bind("click", handleMenuItemClick)
          .appendTo($menu);

        if (item.disabled) {
          $li.addClass("slick-header-menuitem-disabled");
        }

        if (item.tooltip) {
          $li.attr("title", item.tooltip);
        }

        var $icon = $("<div class='slick-header-menuicon'></div>")
          .appendTo($li);

        if (item.iconCssClass) {
          $icon.addClass(item.iconCssClass);
        }

        if (item.iconImage) {
          $icon.css("background-image", "url(" + item.iconImage + ")");
        }

        $("<span class='slick-header-menucontent'></span>")
          .text(item.title)
          .appendTo($li);
      }


     
      //RJ: Added the conditional setting for offset of $menu to make this appear
      var gridWidth = $menu.parent().width();
      var menuWidth = $(this).offset().left + $menu.width();
      
      if(menuWidth < gridWidth){
          // Position the menu.
          $menu
            .offset({ top: $(this).offset().top + $(this).height(), left: $(this).offset().left });
      }else{
          // Position the menu.
          $menu
            .offset({ top: $(this).offset().top + $(this).height(), left: ($(this).offset().left + $(this).width()) - $menu.width() });
      }
      
      // Code in Past; Modified above 8 - 10 lines 
      //$menu.offset({ top: $(this).offset().top + $(this).height(), left: $(this).offset().left });

      // Mark the header as active to keep the highlighting.
      $activeHeaderColumn = $menuButton.closest(".slick-header-column");
      $activeHeaderColumn
        .addClass("slick-header-column-active");

      // Stop propagation so that it doesn't register as a header click event.
      e.preventDefault();
      e.stopPropagation();
    }


    function handleMenuItemClick(e) {
      var command = $(this).data("command");
      var columnDef = $(this).data("column");
      var item = $(this).data("item");

      if (item.disabled) {
        return;
      }

      hideMenu();

      if (command != null && command != '') {
        _self.onCommand.notify({
            "grid": _grid,
            "column": columnDef,
            "command": command,
            "item": item
          }, e, _self);
      }

      // Stop propagation so that it doesn't register as a header click event.
      e.preventDefault();
      e.stopPropagation();
    }

    $.extend(this, {
      "init": init,
      "destroy": destroy,

      "onBeforeMenuShow": new Slick.Event(),
      "onCommand": new Slick.Event()
    });
  }
})(jQuery);


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

var addNewColumn = function(columnDefinition) {
    var columns = grid.getColumns();
    columns.push(columnDefinition);
    grid.setColumns(columns);
    // when columns are now in; go for grid init
    grid.init();
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


var data = [];
var columns = [];
var loadingIndicator = null;
var grid;
var WEBSERVICE_NAME = "E2_MilestoneWS";


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




// On DOM Ready
$(function() {
    
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
    
    // bind the data picker controller with the input field for date.
    $("#datepicker").datepicker(datepickerOptions);
    $("#contextMenu").click(Milestone.contextMenuClickHandler);
    
    //to hide open contextmenus : Rohit
    $("body").click(function () {
        $("#contextMenu").hide();
    });
    
    reFreshGrid();
});


var reFreshGrid = function(){
    
    if(grid != null || typeof grid != 'undefined'){
        grid.destroy();
        grid = null;
    }
    gridMainInitiate();
    Milestone.init(estimateId);
    //Milestone.getEstimateRateCards(estimateId);
}


var gridMainInitiate = function(){
    //var dataProvider = new TotalsDataProvider(data, columns); 
    
    grid = new Slick.Grid("#myGrid", data, columns, Milestone.getGridOptions());
                                                    
     // set keyboard focus on the grid 
    //grid.getCanvasNode().focus(); // commented to get default page focus on load : I-232604
    
    grid.registerPlugin( new Slick.AutoColumnSize());
    // add header menu plugin
    var headerMenuPlugin = new Slick.Plugins.HeaderMenu({});
    // bind on command event
    headerMenuPlugin.onCommand.subscribe(Milestone.onHeaderMenuCommandHandler);
    // register the plugin
    grid.registerPlugin(headerMenuPlugin);

    grid.setSelectionModel(new Slick.CellSelectionModel());
    
    
    
    /** COPY MANAGER PLUGIN **/
    //var copyManager = new Slick.CellCopyManager();
    var copyManager = new Slick.CellExternalCopyManager();
    grid.registerPlugin(copyManager);
    //copyManager.onPasteCells.subscribe(Milestone.onPasteCellsHandlerOld);
    copyManager.onPasteCells.subscribe(Milestone.onPasteCellsHandler); 


    

    /***  ROW - REORDERING ***/
    var moveRowsPlugin = new Slick.RowMoveManager();
    moveRowsPlugin.onBeforeMoveRows.subscribe(Milestone.onBeforeMoveRowsHandler);
    moveRowsPlugin.onMoveRows.subscribe(Milestone.onMoveRowsHandler);
    grid.registerPlugin(moveRowsPlugin);

    
    /*** AUTO - TOOLTIP - Not Needed**/ 
    //grid.registerPlugin(new Slick.AutoTooltips());
    
    
    // bind cell change event
    grid.onCellChange.subscribe(Milestone.onCellChangeHandler);
   
    // bind addnew row event
    grid.onAddNewRow.subscribe(Milestone.onAddNewRowHandler);
    
    // bind edit cell event
    grid.onBeforeEditCell.subscribe(Milestone.onBeforeEditCellHandler);
    
    
    // bind context menu
    grid.onContextMenu.subscribe(Milestone.onContextMenuHandler);
    
    
    
    Milestone.renderGrid();
    
    
}






var datepickerOptions = {
    onSelect: function(dateText) {
        if(!$('#build_div').is(':visible')){
          Milestone.onStartDateSelectionChange(new Date(dateText).toYYYYMMDD());
        }
    },
    beforeShowDay: function(date) {
        return [date.getDay() == 1, ""]
    }
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




var Milestone = {
    fixedRows: 1,
    fixedColumns : 4,
    maxHours : 40,
    cellOldText : '',
    
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
       
       $('body').exportToExcel('Milestone Schedule - ' + estimate_name + ".xlsx", 'Milestone Schedule', gridData, null, function (response) {
            //console.log(response);
            // use vanilla way of calling click action on anchor tag
            // jquery click doesn't work on anchor tags
            //document.getElementById("downloadLink").click();
            
            if (navigator.msSaveBlob) { // IE 10+ 
                //alert('in IE');
                response = response.replace('data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,', '');
                //console.log('NEWRESPONSE' + response);
                navigator.msSaveBlob(Milestone.b64toBlob(response, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'), 'Milestone Schedule - ' + estimate_name + '.xlsx'); 
            }else if(typeof sforce != 'undefined' && typeof sforce.one != 'undefined'){
                 
                 // Lightning experience show - working
                 window.top.location.href = document.getElementById("downloadLink").getAttribute("href");
                 
                
            } 
            else{
                //alert('in Firefox/Mozilla/Chrome');
                // use vanilla way of calling click action on anchor tag
                // jquery click doesn't work on anchor tags
                document.getElementById("downloadLink").click();
            }
            
            $('#myGrid').css({'width': '99%', height: '450px'});
            grid.resizeCanvas(); 
            //grid.destroy();
            //gridMainInitiate();
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
       //grid.destroy();
       //gridMainInitiate();
       loadSpinner.show();
       loader.show();
       // 3 seconds are benchmarks
       // Need to give 3 secs wait period to load the grid with 
       // all the asyncPostRender items and then start reading grid content
       
       setTimeout(function(){
           try{
              Milestone.registerExportToExcel();
           }catch(ex){
              //in case exception comes while generating the xlsx; do handle the exception 
              // and render the grid properly
              loadSpinner.hide();
              loader.hide();
           }
       }, 3000);
       
       return false;       
    },
    
    
    
    fixedRowsTypes : {
                      'weekname' : {
                          id : 'weekname',
                          defaultValue : '',
                          valuefield: 'order'
                          , rowLabel: 'WEEK'
                          , enableColorCodeContextMenu : false
                      }
        
    },
    
    colorcodePostFixStr : '_textcolorcode',                                                      
    
    calcuation_cols_css : {'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff', 'font-weight' : 'bold'},
    
    onContextMenuHandler: function (e) {
      e.preventDefault();
      var cell = grid.getCellFromEvent(e);
      //console.log('cell:' + cell);
      //console.log(cell);
      $("#contextMenu").hide();
      
      if(cell.cell < Milestone.fixedColumns){
          return; // allow context menul only for non fixed columns
      }
      
      if(typeof data[cell.row] == 'undefined'){
          return; // allow only for data related rows
      }
      
      if(typeof columns[cell.cell] != 'undefined' && typeof columns[cell.cell].usedForCalculation == 'undefined'){
          return; // only run for usedforCalculation column
      }
      //console.log(cell);
      $("#contextMenu")
          .data("data", { range : grid.getSelectionModel().getSelectedRanges(), row : cell.row, cell : cell.cell})
          .css("top", e.pageY)
          .css("left", e.pageX)
          .show();

      //$("body").one("click", function () {
        //$("#contextMenu").hide();
      //});
    },
    
    contextMenuClickHandler:function (e) {
        //alert($(e.target).is("button"));
                 if (!$(e.target).is("li") && !$(e.target).is("button")) {
                     return;
                 }
                
                 if (!grid.getEditorLock().commitCurrentEdit()) { 
                     return;
                 }
                
                
                 if ($(e.target).is("li")) {
                     var context_data = $(this).data("data");
                     var val = typeof $(e.target).attr("data") == 'undefined' ? '' : $(e.target).attr("data");
                
                     if (context_data.range.length > 0) {
                         var from = context_data.range[0];
                
                
                         var nodes_order_json = '[';
                
                         for (var i = 0; i <= from.toRow - from.fromRow; i++) {
                             //console.log('from:' + from); 
                             for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                                 if (typeof columns[from.fromCell + j].usedForCalculation != 'undefined' && columns[from.fromCell + j].usedForCalculation == true) {
                                     var rowId = data[from.fromRow + i].id;
                                     var field = columns[from.fromCell + j].field;
                                     //console.log(rowId + '---' + field + '---' + val);
                                     data[from.fromRow + i][columns[from.fromCell + j].field + Milestone.colorcodePostFixStr] = val;
                                     nodes_order_json += '{"weekId":"' + field + '", "rowId":"' + rowId + '", "value":"' + val.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"},';
                                     grid.invalidateRow(from.fromRow + i);
                                 }
                             }
                
                         }
                         // do a database update for color code update
                         if (nodes_order_json != '[') {
                             nodes_order_json = nodes_order_json.slice(0, -1);
                             nodes_order_json += ']';
                             Milestone.updateColorCode(nodes_order_json);
                             //console.log(nodes_order_json);
                         }
                
                     } else {
                         var rowId = data[context_data.row].id;
                         var field = columns[context_data.cell].field;
                
                         // RS : update color in merge cells
                         var nodes_order_json = '[';
                         var cellText = data[context_data.row][columns[context_data.cell].field];
                         for(var cellValue = context_data.cell; cellValue <= columns.length - 1; cellValue++) {
                            var cellText1 = data[context_data.row][columns[cellValue].field];
                            if(cellText1 != '' && cellText == cellText1) {
                                data[context_data.row][columns[cellValue].field + Milestone.colorcodePostFixStr] = val;
                                nodes_order_json += '{"weekId":"' + columns[cellValue].field + '", "rowId":"' + rowId + '", "value":"' + val.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"},';
                            } else {
                                break;
                            }
                         }
                            
                        grid.invalidateRow(context_data.row);
                        // do a database update for color code update
                         if (nodes_order_json != '[') {
                             nodes_order_json = nodes_order_json.slice(0, -1);
                             nodes_order_json += ']';
                             Milestone.updateColorCode(nodes_order_json);
                             //console.log(nodes_order_json);
                         }
                     }
                     grid.getSelectionModel().setSelectedRanges([]);
                     grid.setData(data);
                     Milestone.renderGrid();
                     
                 }else if ($(e.target).is("button")) {
                     var context_data = $(this).data("data");
                     var val = typeof $(e.target).attr("data") == 'undefined' ? '' : $(e.target).attr("data");
                
                     if (context_data.range.length > 0) {
                         var from = context_data.range[0];
                         if (val.toLowerCase() == 'merge') {
                             var nodes_order_json = '[';
                             
                             var cellValue_register = [];
                             var cellColor_register = [];
                             for(var i = 0; i <= from.toRow - from.fromRow; i++) {
                                 var cellValue = '';
                                 var cellColor = '';
                                 for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                                     if(data[from.fromRow + i][columns[from.fromCell + j].field] != 'undefined' 
                                     && data[from.fromRow + i][columns[from.fromCell + j].field] != '') {
                                         cellValue = data[from.fromRow + i][columns[from.fromCell + j].field];
                                         cellColor = data[from.fromRow + i][columns[from.fromCell + j].field + Milestone.colorcodePostFixStr];
                                         break;
                                     }
                                 }
                                 cellValue_register.push(cellValue);
                                 cellColor_register.push(cellColor);
                             }
                
                             for (var i = 0; i <= from.toRow - from.fromRow; i++) {
                                 var cellValue = cellValue_register[i];//data[from.fromRow + i][columns[from.fromCell].field];
                
                                 cellValue = (typeof cellValue == 'undefined' ? '' : cellValue);
                                 cellColor = (typeof cellColor == 'undefined' ? '' : cellColor);
                                 
                                 for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                                     if (typeof columns[from.fromCell + j].usedForCalculation != 'undefined' && columns[from.fromCell + j].usedForCalculation == true) {
                
                                         var rowId = data[from.fromRow + i].id;
                                         var field = columns[from.fromCell + j].field;
                                         data[from.fromRow + i][columns[from.fromCell + j].field] = cellValue;
                                         data[from.fromRow + i][columns[from.fromCell + j].field + Milestone.colorcodePostFixStr] = cellColor;
                                         nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"' + cellValue.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '", "textcolorcode":"' + cellColor + '"},';
                                         grid.invalidateRow(from.fromRow + i);
                
                                     }
                                 }
                
                             }
                             
                             // do a database update for milestone and phase color code update
                             if (nodes_order_json != '[') {
                                 nodes_order_json = nodes_order_json.slice(0, -1);
                                 nodes_order_json += ']';
                                 Milestone.mergeUnmerge(nodes_order_json);
                                 //console.log(nodes_order_json);
                             }
                             
                             grid.getSelectionModel().setSelectedRanges([]);
                             grid.setData(data);
                             Milestone.renderGrid();
                             
                         }else if (val.toLowerCase() == 'unmerge') {
                             var nodes_order_json = '[';
                             for (var i = 0; i <= from.toRow - from.fromRow; i++) {
                                 var cellValue = data[from.fromRow + i][columns[from.fromCell].field];
                                 for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                                     if (typeof columns[from.fromCell + j].usedForCalculation != 'undefined' && columns[from.fromCell + j].usedForCalculation == true) {
                                         var rowId = data[from.fromRow + i].id;
                                         var field = columns[from.fromCell + j].field;
                                         var value = data[from.fromRow + i][columns[from.fromCell + j].field];
                    
                                         if (columns[from.fromCell].field != columns[from.fromCell + j].field && value == cellValue) {
                                             data[from.fromRow + i][columns[from.fromCell + j].field] = '';
                                             data[from.fromRow + i][columns[from.fromCell + j].field + Milestone.colorcodePostFixStr] = '';
                                             nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"", "textcolorcode":""},';
                                         }
                                         
                                         grid.invalidateRow(from.fromRow + i);
                                     }
                                 }
                    
                             }
                             // do a database update for milestone and phase color code update
                             if (nodes_order_json != '[') {
                                 nodes_order_json = nodes_order_json.slice(0, -1);
                                 nodes_order_json += ']';
                                 Milestone.mergeUnmerge(nodes_order_json);
                                 //console.log(nodes_order_json);
                             }
                             grid.getSelectionModel().setSelectedRanges([]);
                             grid.setData(data);
                             Milestone.renderGrid();
                    
                         }else if(val.toLowerCase() == 'clear'){
                             var nodes_order_json = '[';
                             for (var i = 0; i <= from.toRow - from.fromRow; i++) {
                                 for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                                     if (typeof columns[from.fromCell + j].usedForCalculation != 'undefined' && columns[from.fromCell + j].usedForCalculation == true) {
                                         var rowId = data[from.fromRow + i].id;
                                         var field = columns[from.fromCell + j].field;
                                         //var value = data[from.fromRow + i][columns[from.fromCell + j].field];
                    
                                         
                                             data[from.fromRow + i][columns[from.fromCell + j].field] = '';
                                             data[from.fromRow + i][columns[from.fromCell + j].field + Milestone.colorcodePostFixStr] = '';
                                             nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"", "textcolorcode":""},';
                                         
                                         
                                         grid.invalidateRow(from.fromRow + i);
                                     }
                                 }
                    
                             }
                             // do a database update for milestone and phase color code update
                             if (nodes_order_json != '[') {
                                 nodes_order_json = nodes_order_json.slice(0, -1);
                                 nodes_order_json += ']';
                                 Milestone.mergeUnmerge(nodes_order_json);
                                 //console.log(nodes_order_json);
                             }
                             grid.getSelectionModel().setSelectedRanges([]);
                             grid.setData(data);
                             Milestone.renderGrid();
                         }
 
                    }// end of context length check
                    else if(val.toLowerCase() == 'clear' || val.toLowerCase() == 'unmerge') {
                         var nodes_order_json = '[';
                         if(val.toLowerCase() == 'clear') {
                             var rowId = data[context_data.row].id;
                             var field = columns[context_data.cell].field;
                             data[context_data.row][columns[context_data.cell].field] = '';
                             data[context_data.row][columns[context_data.cell].field + Milestone.colorcodePostFixStr] = '';
                             nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"", "textcolorcode":""},';
                             grid.invalidateRow(context_data.row);
                         } else if(val.toLowerCase() == 'unmerge') {
                             var cellText = data[context_data.row][columns[context_data.cell].field];
                             var rowId = data[context_data.row].id;
                             for(var cellValue = context_data.cell+1; cellValue <= columns.length - 1; cellValue++) {
                                 var cellText1 = data[context_data.row][columns[cellValue].field];
                                 if(cellText1 != '' && cellText == cellText1) {
                                     var field = columns[cellValue].field;
                                     data[context_data.row][field] = '';
                                     data[context_data.row][field + Milestone.colorcodePostFixStr] = '';
                                    nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"", "textcolorcode":""},';
                                 } else {
                                     break;
                                 }
                             }
                             grid.invalidateRow(context_data.row);
                         } 
                         // do a database update for milestone and phase color code update
                        if (nodes_order_json != '[') {
                            nodes_order_json = nodes_order_json.slice(0, -1);
                            nodes_order_json += ']';
                            console.log(nodes_order_json);
                            Milestone.mergeUnmerge(nodes_order_json);
                            
                        }
                        grid.setData(data);
                        Milestone.renderGrid();
                
                     }
                 }//end of is button check   
        
        
    },
    
    
    triggerUpdateCell: function(field, rowId, val, row, cell){
        if(field.toLowerCase() == 'milestone1'){
          Milestone.updateMilestone1(rowId, val);  
        }else if(field.toLowerCase() == 'milestone2'){
          Milestone.updateMilestone2(rowId, val);  
        }else{
          Milestone.updateText(field, rowId, val);
        }
    },
    
    
    renderGrid: function(){
         
        grid.render();
        
    },
    getGridOptions: function(){
      return {
                                                        explicitInitialization : true,
                                                        editable: true,
                                                        enableAddRow: true,
                                                        enableCellNavigation: true,
                                                        asyncEditorLoading: true,
                                                        autoEdit: true,
                                                        enableColumnReorder: false
                                                        ,forceFitColumns : false
                                                        ,headerRowHeight : 30
                                                        ,enableAsyncPostRender: true
                                                        ,asyncPostRenderDelay : 50 // default 50
                                                        ,leaveSpaceForNewRows : true
                                                        ,rowHeight : 40
                                                        ,frozenColumn : 3   
                                                        ,frozenRow : 1
                                                        //,autoHeight: true
                                                        //,fullWidthRows: true
                                                        //,frozenBottom: true
                                                    };  
        
    },
    
    onAddNewRowHandler: function(e, args) {
        //console.log(args);
        var item = args.item;
        var column = args.column;
        if(column.field == 'milestone1' || column.field == 'milestone2'){
            
            var order = 1; //this is just dummy setting here; actually set before calling ajax to server
            Milestone.addRow(estimateId, order, 
                              (typeof item.milestone1 == 'undefined' ? '' : item.milestone1), 
                              (typeof item.milestone2 == 'undefined' ? '' : item.milestone2));
            
            grid.invalidateRow(data.length);
            data.push(item);
            grid.updateRowCount();
            Milestone.renderGrid();
                              
        }
    },
    
    onHeaderMenuCommandHandler: function(e, args) {

        if (args.command === 'insert_1_right') {
            Milestone.addMoreColumnsOnRight(args.column.id, 1);
        }
        if (args.command === 'insert_2_right') {
            Milestone.addMoreColumnsOnRight(args.column.id, 2);
        }

        if (args.command === 'insert_1_left') {
            Milestone.addMoreColumnsOnLeft(args.column.id, 1);
        }

        if (args.command === 'insert_2_left') {
            Milestone.addMoreColumnsOnLeft(args.column.id, 2);
        }

        if (args.command === 'delete_column') {
            var respond = confirm("Deleting a column will delete all the data for this week/column!!! \nAre you sure you want to delete?");
            if(respond == true) Milestone.deleteColumn(args.column.id);
        }

    },
    
    
    
    onPasteCellsHandler: function(e, args) {
        //if (args.from.length !== 1 || args.to.length !== 1) {
        //    throw "This implementation only supports single range copy and paste operations";
        //}
        //alert('in');
        
        //var from = args.from[0];
        //var to = args.to[0];
        
        var from = args.ranges[0];
        var to = args.ranges[0];
        
        var val;
       
        var nodes_order_json = '[';
        for (var i = 0; i <= from.toRow - from.fromRow; i++) {
            for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                if (i <= to.toRow - to.fromRow && j <= to.toCell - to.fromCell) {

/**
                    if(typeof columns[to.fromCell + j].usedForCalculation != 'undefined' && columns[to.fromCell + j].usedForCalculation == true){ 
                        val = data[from.fromRow + i][columns[from.fromCell + j].field];
                        
                        val = (typeof val == 'undefined' ? '' : val);
**/
                     if(typeof columns[to.fromCell + j] && typeof data[(to.fromRow + i)] != 'undefined' && 
                              //typeof columns[to.fromCell + j].usedForCalculation != 'undefined' && 
                              //columns[to.fromCell + j].usedForCalculation == true &&
                              typeof data[to.fromRow + i].id != 'undefined' && 
                              typeof columns[to.fromCell + j].field != 'undefined'){ 
                        
                        if(args.oneCellToMultiple){
                            val = args.clippedRange[0][0];
                        }
                        else{
                            val = args.clippedRange[i][j];
                        } 
                        
                        val = (typeof val == 'undefined' ? '' : val);
                        data[to.fromRow + i][columns[to.fromCell + j].field] = val;
                        
                        var rowId = data[to.fromRow + i].id;
                        var field = columns[to.fromCell + j].field;
                        
                        var cCode = "";
                        
                        if(typeof args.copiedRanges != 'undefined' && sessionStorage.getItem("isSameMilestoneText") == 'true'){
                            
                            cCode = args.copiedRanges[i][j]; //data[args.copiedRanges[0].fromRow + i][columns[args.copiedRanges[0].fromCell + j].field + Milestone.colorcodePostFixStr]
                            
                            if(typeof cCode != 'undefined' && cCode != null && cCode != ""){
                                data[to.fromRow + i][columns[to.fromCell + j].field + Milestone.colorcodePostFixStr] = cCode;
                            }else {
                                data[to.fromRow + i][columns[to.fromCell + j].field + Milestone.colorcodePostFixStr] = "";
                            }
                        }
                        
                        if(rowId && field) nodes_order_json += '{"milestoneId":"' + rowId + '", "weekId":"' + field + '", "text":"' + val.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '", "textcolorcode":"' + cCode + '"},';
                        
                        grid.invalidateRow(to.fromRow + i);
                    }
                }
            }
        }
        
        // do a database update for color code update
        if (nodes_order_json != '[') {
             nodes_order_json = nodes_order_json.slice(0, -1);
             nodes_order_json += ']';
             Milestone.updateBulkText(nodes_order_json);
             //console.log(nodes_order_json); 
        }
        
        grid.setData(data);
        Milestone.renderGrid();

    },
    
    onBeforeMoveRowsHandler: function(e, data) {
        for (var i = 0; i < data.rows.length; i++) {
            // no point in moving before or after itself
            if (data.rows[i] == data.insertBefore || data.rows[i] == data.insertBefore - 1) {
                e.stopPropagation();
                return false;
            }
        }
        return true;
    },
    
    onMoveRowsHandler : function(e, args) {
        // stop the row movement of first fixed Rows
        if(args.insertBefore < Milestone.fixedRows || args.rows < Milestone.fixedRows){
            e.stopPropagation();
            return false;
        }
        var extractedRows = [],
            left, right;
        var rows = args.rows;
        var insertBefore = args.insertBefore;
        left = data.slice(0, insertBefore);
        right = data.slice(insertBefore, data.length);

        rows.sort(function(a, b) {
            return a - b;
        });

        for (var i = 0; i < rows.length; i++) {
            extractedRows.push(data[rows[i]]);
        }

        rows.reverse();

        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (row < insertBefore) {
                left.splice(row, 1);
            } else {
                right.splice(row - insertBefore, 1);
            }
        }

        data = left.concat(extractedRows.concat(right));

        var selectedRows = [];
        for (var i = 0; i < rows.length; i++)
            selectedRows.push(left.length + i);

        grid.resetActiveCell();
        Milestone.bindMetadata();
        grid.setData(data);
        grid.setSelectedRows(selectedRows);
        Milestone.renderGrid();
        Milestone.reOrderRows(data);
    },
    
    onBeforeEditCellHandler: function(e, args) {
        // make row un-editable [rows such as weekname, total]
          
      if (typeof data[args.row] != 'undefined' && typeof data[args.row].id != 'undefined' && (data[args.row].id === Milestone.fixedRowsTypes.weekname.id)) {
          return false;
      }else if(typeof data[args.row] != 'undefined' && 
           typeof data[args.row].id != 'undefined' && typeof grid.getColumns()[args.cell].field != 'undefined'
            && typeof data[args.row][grid.getColumns()[args.cell].field] != 'undefined'){
               
            Milestone.cellOldText = data[args.row][grid.getColumns()[args.cell].field];
      }
    },
    
    onCellChangeHandler: function(e, args){
        var field = grid.getColumns()[args.cell].field;
        //console.log(field + '---');
        
        var item = args.item;
        var column = args.cell;
        var row = args.row;
        var value = data[args.row][grid.getColumns()[args.cell].field];
        var rowId = item.id;
        //console.log(rowId + '---' + field);
        
        if(field != 'milestone1' && field != 'milestone2'){
            var cCode = '';
            
            if(typeof data[args.row][columns[column].field + Milestone.colorcodePostFixStr] != 'undefined'){
               cCode = data[args.row][columns[column].field + Milestone.colorcodePostFixStr];
            }
            
            var nodes_order_json = '[';
            nodes_order_json += '{"weekId":"' + field + '", "milestoneId":"' + rowId + '", "text":"' + value.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '", "textcolorcode":"' + cCode + '"},';        
            for (var cellValue = column + 1; cellValue <= columns.length - 1; cellValue++) {
                
                var cellText = data[args.row][columns[cellValue].field];
                
                if(typeof cellText != 'undefined' && cellText != '' && cellText == Milestone.cellOldText) {
                    data[args.row][columns[cellValue].field] = value;
                    nodes_order_json += '{"weekId":"' + columns[cellValue].field + '", "milestoneId":"' + rowId + '", "text":"' + value.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '", "textcolorcode":"' + cCode + '"},';
                } else {
                    break;
                }
            }
                                 
            // do a database update for milestone and phase color code update
            if (nodes_order_json != '[') {
                nodes_order_json = nodes_order_json.slice(0, -1);
                nodes_order_json += ']';
                Milestone.mergeUnmerge(nodes_order_json);
                //console.log(nodes_order_json);
            }    
            grid.invalidateRow(args.row);
        }else if (rowId && field) {
            Milestone.triggerUpdateCell(field, rowId, value, row, column);   
        }
        //console.log('cellchange');
        grid.setData(data);
        Milestone.renderGrid();
        
    },
    
    
    numFieldValidator : function(value) {
        if (value == null || value == undefined || !value.length || !(/\D/.test(value))) {
          if((value != null || value != undefined || value.length) && value > Milestone.maxHours){
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
        //if(dataContext.id == 'phase' || dataContext.id == 'milestone' || dataContext.id == 'weekname' || dataContext.id == 'total'){ 
        //    return '';
        //}
        if(typeof Milestone.fixedRowsTypes[dataContext.id.toLowerCase()] != 'undefined') return '';
        
        return 'wait..';
    },
    

   

    getDefaultColumns: function() {
        return [{
            id: "move",
            name: "",
            field: "move",
            width: 20,
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
        }, {
            id: "id",
            name: "",
            field: "id",
            width: 20,
            behavior: "",
            selectable: false,
            resizable: false,
            focusable : false,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null,
            formatter: function(row, cell, value, columnDef, dataContext) {
                //return "<a style='color:#4996D0; text-decoration:none;cursor:pointer' rowId='" + dataContext.id + "' onclick='Milestone.deleteRow(this);'>Del</a>";
                return "<a href='javascript:void(0);' title='Delete' class='delete_button' style='color:#4996D0; text-decoration:none;cursor:pointer' rowId='" + dataContext.id + "' onclick='Milestone.deleteRow(this);'>&nbsp;</a>";
            }
            ,notUsedForCalculation : true

        }, {
            id: "milestone1",
            field: "milestone1",
            name: "",
            behavior: "",
            width: 80,
            selectable: false,
            resizable: true,
            focusable : true,
            editor: Slick.Editors.Text,
            cssClass: "milestone1",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
            ,asyncPostRender : function(cellNode, row, dataContext, colDef) {
                // set the title
                $(cellNode).attr('title', $(cellNode).text());
                //$(cellNode).css('text-align', 'center');
            }
            
        },{
            id: "milestone2",
            field: "milestone2",
            name: "",
            behavior: "",
            width: 345,
            selectable: false,
            resizable: true,
            focusable : true,
            editor: Slick.Editors.Text,
            cssClass: "milestone2",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
            ,asyncPostRender : function(cellNode, row, dataContext, colDef) {
                //console.log($(cellNode).text());
                // set the title
                $(cellNode).attr('title', $(cellNode).text());
                //$(cellNode).css('text-align', 'right');
            }
        }];
    },
    
    bindMetadata: function(){
        // set the grid's data as new rows
        data.getItemMetadata = function (row) {
                  
                   var metadata =  {
                      selectable: false,
                      cssClasses: "custom-fix-row",
                      "columns": {
                                        "id": {
                                                  formatter: function(row, cell, value, columnDef, dataContext) {
                                                        return "";
                                                  },
                                                  focusable : false,
                                                  editor: ""
                                                }    
                      }
                    };
                
                if(typeof data[row] != 'undefined' && typeof Milestone.fixedRowsTypes[data[row].id] != 'undefined'){
                    return metadata;
                }else if(typeof data[row] != 'undefined'){
                    var currentRow = data[row];
                    var metadata_new =  {
                      
                      "columns": {
                           
                      }
                    };
                    
                     $.each(columns, function(indx1, colItem) {
                         
                        if(indx1 >= Milestone.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                             //added code for colspan
                             //metadata_new.selectable = false;
                             var val = currentRow[columns[indx1].field];
                             var nextCellIndex = indx1 + 1;
                             var colspan = 1;
                             while(nextCellIndex < columns.length){
                                 //console.log('val:' + val);
                                 var nextCellVal = currentRow[columns[nextCellIndex].field];
                                 if(val == nextCellVal && (typeof val != 'undefined' && val != null && val != '' && typeof nextCellVal != 'undefined' && nextCellVal != null && nextCellVal != '')){ 
                                   colspan++;  
                                 }else {
                                     break;
                                 } 
                                 nextCellIndex += 1;
                             }
                             // end of colspan calcuation
                             metadata_new.columns[colItem.field] = {};
                             metadata_new.columns[colItem.field].editor = Slick.Editors.Text;
                             metadata_new.columns[colItem.field].selectable = true;
                             metadata_new.columns[colItem.field].colspan = colspan; // added for colspan
                        }
                    });
                    
                    return metadata_new;
                }
                
           }
        
        
    },
    rt_json : [],
    
    init: function(estimateId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
            estimateId: estimateId
        }, Milestone.initCallback);
    },
    initCallback: {
        onSuccess: function(result) {
            //result = (result.length > 0 ? result[0] : result); 
            columns = Milestone.getDefaultColumns();
            
            if(result.length == 0) $('#build_div').show();
            
            $.each(result, function(indx, column) {
                columns.push(Milestone.defineAddPropForColumn(column));
                if (indx === 0) {
                    $("#datepicker").datepicker('setDate', new Date(column.sDate));
                    $('#build_div').hide();
                };
            });
            
            
            // clear the initital array
            result = [];
            
            
            // set the grid's columns as the new columns
            grid.setColumns(columns);
            
            // when columns are now in; go for grid init
            grid.init();
            
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
                estimateId: estimateId
            }, Milestone.getRows_CallBack);
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }

    },
    
    hexdec : function(hex_string) {   
        hex_string = (hex_string + '').replace(/[^a-f0-9]/gi, '');
        return parseInt(hex_string, 16);
    },

    getContrast50: function($hexcolor){ 
        return (Milestone.hexdec($hexcolor) > 0xffffff/2) ? '#000':'#fff'; 
    },
    
    
    defineAddPropForColumn : function(column){
        column.header = JSON.parse(column.header);
        column.editor = Slick.Editors.Text;
        column.width = parseInt(column.width);
        column.order = parseInt(column.order);
        column["usedForCalculation"] = true;
        column["headerCssClass"] = "Fixed-Header-Style";
        column["cssClass"] = "custom-cell";
        column["validator"] = Milestone.textFieldValidator;
        column.asyncPostRender = function(cellNode, row, dataContext, colDef) {
                //console.log('row > Milestone.fixedRows:' + row + '>' + Milestone.fixedRows);
                //console.log($(cellNode).text());
                if(row >= Milestone.fixedRows){
                       var backgroundColor = data[row][colDef.id + Milestone.colorcodePostFixStr]; 
                       //console.log('backgroundColor:' + backgroundColor);
                       $(cellNode).css({'background-color': '', 'color' : '#000000'}); 
                       // set the tooltip tile on cell
                       $(cellNode).attr("title", $(cellNode).text());
                       //console.log('color:' + backgroundColor);
                       //console.log('background:' + backgroundColor);
                       if(typeof backgroundColor != 'undefined'){ 
                           $(cellNode).css({'background-color': '' + backgroundColor + '', 'color' : backgroundColor == '' ? '#000000' : Milestone.getContrast50(backgroundColor)});
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
            columns = Milestone.getDefaultColumns();
            
            if(result.length == 0) $('#build_div').show();
            
            $.each(result, function(indx, column) {
                columns.push(Milestone.defineAddPropForColumn(column));
                if (indx === 0) {
                    $("#datepicker").datepicker('setDate', new Date(column.sDate));
                    $('#build_div').hide();
                };
            });
            // clear the initital array
            result = [];
            
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
        sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
            estimateId: estimateId
        }, Milestone.getRows_CallBack);
    },
    
    
    
    getRows_CallBack: {
        onSuccess: function(result) {
            data = [];
            
            
            for(var _a in Milestone.fixedRowsTypes){
                var row = {
                    id : _a
                }; 
                
                $.each(columns, function(indx1, colRow) {
                    if(indx1 >= Milestone.fixedColumns){
                        
                      var meta_info = Milestone.fixedRowsTypes[row.id];
                      if(typeof meta_info != 'undefined'){
                          row[colRow.id] = meta_info.defaultValue;
                          var valueField = meta_info.valuefield;
                          
                          
                          if(typeof valueField != 'undefined'){
                            row[colRow.id] = (typeof colRow[valueField] == 'undefined' || colRow[valueField] == null ? '' : colRow[valueField]);  
                          } 
                          
                          
                      }
                    }        
                });
                data.push(row);
                
            }
            
           
            $.each(result, function(indx, row) {
                if (typeof row.colRows != 'undefined') {
                    if (row.colRows.constructor === Array) {
                        $.each(row.colRows, function(indx1, colRow) {
                            row[colRow.columnId] = colRow.text;
                            row[colRow.columnId + Milestone.colorcodePostFixStr] = colRow.textcolorcode;
                        });
                    } else {
                        row[row.colRows.columnId] = row.colRows.text;
                        row[row.colRows.columnId + Milestone.colorcodePostFixStr] = row.colRows.textcolorcode;
                    }
                }
                
                data.push(row);
            });

            // clear the initital array
            result = [];
             
            Milestone.bindMetadata();                      
            grid.setData(data);
            Milestone.renderGrid();
            //grid.init();
            loader.hide();
            loadSpinner.hide();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
            loadSpinner.hide();
        }

    },
    
    onStartDateSelectionChange: function(sDate) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "onStartDateSelectionChange", {
            estimateId: estimateId,
            sDate: sDate,
            order: 1,
            name: 'Week1'
        }, Milestone.onStartDateSelectionChange_Callback);
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
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.getColumns_Callback);

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
        }, Milestone.addMoreColumnsOnRight_Callback);
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
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);

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
        }, Milestone.addMoreColumnsOnLeft_Callback);
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
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);

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
        }, Milestone.deleteColumn_Callback);
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
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    deleteRow: function(link) {
        var result = confirm("Are you sure you want to permenantly delete this row!");
        if (result == true) {
            var rowId = ($(link).attr('rowId'));
            loader.show();
            sforce.apex.execute(WEBSERVICE_NAME, "deleteRow", {
                rowId: rowId
            }, Milestone.deleteRow_Callback);
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
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
                estimateId: estimateId
            }, Milestone.getRows_CallBack);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    addRow: function(estimateId, order, milestone1, milestone2) {
        loader.show();
        loadSpinner.show();
        sforce.apex.execute(WEBSERVICE_NAME, "addRow", {
            estimateId: estimateId,
            order: ((data.length - Milestone.fixedRows) + 1),
            milestone1: milestone1,
            milestone2: milestone2
        }, Milestone.addRow_Callback);
       
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
                loadSpinner.hide();
                return;
            }
            
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    reOrderRows: function(data) {
        if (data.length > 0) {
            loader.show();
            var nodes_order_json = '[';
            
            $.each(data, function(indx, row) {
                // bypass fixedRows count
                if(indx >= Milestone.fixedRows) nodes_order_json += '{"milestoneId":"' + row.id + '", "displayOrder":"' + ((indx + 1) - Milestone.fixedRows) + '"},';
            });
            nodes_order_json = nodes_order_json.slice(0, -1);
            nodes_order_json += ']';

            sforce.apex.execute(WEBSERVICE_NAME, "reOrderRows", {
                jsonstr: nodes_order_json
            }, Milestone.reOrderRows_Callback);
        }
    },
    reOrderRows_Callback: {
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
            Milestone.renderGrid();
            //sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
            //    estimateId: estimateId
            //}, Milestone.getRows_CallBack);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    updateText_call_register: {},
    updateText: function(weekId, milestoneId, text) {
        loader.show();
        Milestone.updateText_call_register[weekId + '-' + milestoneId] = 'hrs';  
        sforce.apex.execute(WEBSERVICE_NAME, "updateText", {
            weekId: weekId,
            milestoneId: milestoneId,
            text: text
        }, Milestone.updateText_Callback);
        
    },
    updateText_Callback: {
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
            if (Milestone.updateText_call_register && Milestone.updateText_call_register[result]){ delete Milestone.updateText_call_register[result];}
            if (Milestone.updateText_call_register && JSON.stringify(Milestone.updateText_call_register) == '{}') {
                loader.hide();
               
                //sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
                //    estimateId: estimateId
                //}, Milestone.getRows_CallBack);
            } 
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    updateBulkText: function(jsonstr) {
        loader.show();
          
        sforce.apex.execute(WEBSERVICE_NAME, "updateBulkText", {
            jsonstr: jsonstr
        }, Milestone.updateBulkText_Callback);
        
    },
    
    updateBulkText_Callback: {
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
           
            //sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
            //    estimateId: estimateId
            //}, Milestone.getRows_CallBack);
            
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    
    updateMilestone1: function(resourceId, milestone1) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestone1", {
            estimateId: estimateId,
            milestoneId: resourceId,
            milestone1: milestone1
        }, Milestone.updateMilestone_Callback);
        
    },
    
    updateMilestone2: function(resourceId, milestone2) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "updateMilestone2", {
            estimateId: estimateId,
            milestoneId: resourceId,
            milestone2: milestone2
        }, Milestone.updateMilestone_Callback);
        
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
           
            loader.hide();
                
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    mergeUnmerge: function(jsonstr) {
        loader.show();
        
        sforce.apex.execute(WEBSERVICE_NAME, "mergeUnmerge", {
            jsonstr: jsonstr
        }, Milestone.mergeUnmerge_Callback);
        
    },
    
    mergeUnmerge_Callback: {
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
            //sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
            //    estimateId: estimateId
            //}, Milestone.getRows_CallBack);
            //Milestone.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
   
    updateColorCode: function(jsonstr) {
        loader.show();
        
        sforce.apex.execute(WEBSERVICE_NAME, "updateColorCode", {
            jsonstr: jsonstr
        }, Milestone.updateColorCode_Callback);
        
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
            //sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneRows", {
            //    estimateId: estimateId
            //}, Milestone.getRows_CallBack);
            //Milestone.renderGrid();
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    
    
    build: function(){
        $('#datepicker').parent().removeClass('slds-has-error');
        var dateText = $("#datepicker").datepicker('getDate');
        // check that date is supplied before build progress
        if(dateText == null){
            $('#datepicker').parent().addClass('slds-has-error');
            return false;
        }
        
        var sDate = new Date(dateText).toYYYYMMDD();
        var noOfColumnsToAdd = $('#no_of_weeks').val();
        
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "onBuild", {
            estimateId: estimateId,
            sDate: sDate,
            noOfColumnsToAdd: noOfColumnsToAdd
        }, Milestone.onbuild_Callback);
        
        return false;
        //onBuild(string estimateId, string sDate, integer noOfColumnsToAdd)
    },
    onbuild_Callback: {
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
            
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    },
    
    addFromTemplate: function(type){
        //console.log('type'+type);
        
         if(type == ''){
             return false;
         }
         
         var iConfirm = true;
         //console.log(data.length + '>' +  Milestone.fixedRows);
         if(data.length > Milestone.fixedRows){
             iConfirm = confirm('You seem to have data in your existing milestone schedule!!!\nAdding from template will override existing schedule!!!\nARE YOU SURE TO GO AHEAD?');
         }
        
         if(iConfirm){
             loader.show();
             loadSpinner.show();
            sforce.apex.execute(WEBSERVICE_NAME, "addFromTemplate", {
                type: type,
                estimateId : estimateId
            }, Milestone.addFromTemplate_Callback);
         }
         return false;
    },
    
    addFromTemplate_Callback: {
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
            loadSpinner.hide();
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);
            
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
            loadSpinner.hide();
        }
        
    },
    
    deleteAllRows: function(){
        
         var iConfirm = confirm('Are you sure to delete all the rows?');
         
        
         if(iConfirm){
             loader.show();
             loadSpinner.show();
            sforce.apex.execute(WEBSERVICE_NAME, "deleteAllRows", {
                estimateId : estimateId
            }, Milestone.deleteAllRows_Callback);
         }
         return false;
    },
    
    deleteAllRows_Callback: {
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
            loadSpinner.hide();
            // process success
            sforce.apex.execute(WEBSERVICE_NAME, "getMilestoneColumns", {
                estimateId: estimateId
            }, Milestone.initCallback);
            
        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
            loadSpinner.hide();
        }
        
    }
    
}
