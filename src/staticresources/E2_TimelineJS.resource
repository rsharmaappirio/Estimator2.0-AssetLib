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
             * Кey codes
             * 37 left
             * 38 up
             * 39 right
             * 40 down                     
             */
            var ranges, last;
            var active = _grid.getActiveCell();

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
        var _canvas;
        var _dragging;
        var _decorator;
        var _self = this;
        var _handler = new Slick.EventHandler();
        var _defaults = {
            selectionCss: {
                "border": "2px dashed blue"
            }
        };


        function init(grid) {
            options = $.extend(true, {}, _defaults, options);
            _decorator = new Slick.CellRangeDecorator(grid, options);
            _grid = grid;
            _canvas = _grid.getCanvasNode();
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

            var start = _grid.getCellFromPoint(
                dd.startX - $(_canvas).offset().left,
                dd.startY - $(_canvas).offset().top);

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
                e.pageX - $(_canvas).offset().left,
                e.pageY - $(_canvas).offset().top);

            if (!_grid.canCellBeSelected(end.row, end.cell)) {
                return;
            }

            dd.range.end = end;
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
      
      // return when the row is phase or milestone
      if(typeof args.item.id == 'undefined' || args.item.id == 'phase' || args.item.id == 'milestone') return;
      
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

function PhaseSelectionEditor(args) {
    var $input, $picker;
    var defaultValue;
    var scope = this;

    this.init = function () {
      $input = $("<INPUT type=text class='editor-percentcomplete' />");
      $input.width($(args.container).innerWidth() - 25);
      $input.appendTo(args.container);

      $picker = $("<div class='editor-percentcomplete-picker' />").appendTo(args.container);
      $picker.append("<div class='editor-percentcomplete-helper'><div class='editor-percentcomplete-wrapper'><div class='editor-percentcomplete-buttons' /></div></div>");

      for(var _a in renderOptions_Phases){
          $picker.find(".editor-percentcomplete-buttons").append($('<button val="' + _a + '">' + _a + '</button>'));
          $picker.find(".editor-percentcomplete-buttons").append($('<br/>'));
      }       

      $input.focus().select();

      $picker.find(".editor-percentcomplete-buttons button").bind("click", function (e) {
        $input.val($(this).attr("val"));
        e.stopPropagation();
        $input.focus().select();
        return false;
      })
    };

    this.destroy = function () {
      $input.remove();
      $picker.remove();
    };

    this.focus = function () {
      $input.focus();
    };

    this.loadValue = function (item) {
      $input.val(defaultValue = item[args.column.field]);
      $input.select();
    };

    this.serializeValue = function () {
      return $input.val();
    };

    this.applyValue = function (item, state) {
      item[args.column.field] = state;
    };

    this.isValueChanged = function () {
      return ($input.val() != defaultValue);
    };

    this.validate = function () {
      if ($input.val() != '' && typeof renderOptions_Phases[$input.val()] == 'undefined') {
        return {
          valid: false,
          msg: "Please enter a valid phase"
        };
      }

      return {
        valid: true,
        msg: null
      };
    };

    this.init();
}

function AutoCompleteEditor(args) {
    var $input;
    var defaultValue = '';
    var scope = this;
    
    this.init = function () {
      $input = $("<INPUT id='" + (typeof args.item.id == 'undefined' ? 'new' : args.item.id) + "' type=text class='editor-text' />");
      
      $input.appendTo(args.container)
            .keydown(function(e){
                if(e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40 || e.which == 13){
                    // Don't propogate the event to the document
                    if (e.stopPropagation) {
                        e.stopPropagation();   // W3C model
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
                Timeline.onResourceSelectionChange(event, ui, $input.attr('id'));
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

function PickListEditor(args) {
    var $select;
    var defaultValue;
    var scope = this;

    this.init = function() {
        $select = $("<SELECT id='" + (typeof args.item.id == 'undefined' ? 'new' : args.item.id) + "' tabIndex='0' class='editor-yesno'></SELECT>");
        $(Timeline.rt_json).each(function(index, element) {
            //var val = element.region + ' - ' + element.role;
            var option = '<OPTION value="' + element.resource + '">' + element.resource + '</OPTION>';
            var $opt = $(option);
            $opt.attr('suggestedRate', element.suggestedRate);
            $opt.attr('discountedRate', element.discountedRate);
            $opt.attr('cost', element.cost);
            $opt.attr('resource', element.resource);
            //console.log('estimateRateCardId:'+ element.id);
            $opt.attr('estimateRateCardId', typeof element.id == 'undefined' ? '' : element.id);
            $select.append($opt);
        });

        $select.appendTo(args.container);
        $select.on('change', Timeline.onResourcePickListChange);
        $select.focus();
    };

    this.destroy = function() {
        $select.remove();
    };

    this.focus = function() {
        $select.focus();
    };

    this.loadValue = function(item) {
        $select.val((defaultValue = item[args.column.field]));
        $select.select();
    };

    this.serializeValue = function() {
        return $select.val();
    };

    this.applyValue = function(item, state) {
        item[args.column.field] = state;
    };

    this.isValueChanged = function() {
        return ($select.val() != defaultValue);
    };

    this.validate = function() {
        return {
            valid: true,
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
      if(typeof args.item.id == 'undefined' || args.item.id == 'phase' || args.item.id == 'milestone') return;
      
      
      //$picker.width($(args.container).innerWidth());
      $picker.appendTo(args.container);
      
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
                var el = $('<label>' + opt[i] + '</label>').css('left', ((opt[i]/40)*100)+'%');
        
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



var data = [];
var columns = [];
var loadingIndicator = null;
var grid;
var WEBSERVICE_NAME = "E2_TimelineWS";


var loadSpinner = {
    client_id : '#loadingSpinner',
    
    show: function(){
        $(loadSpinner.client_id).show().css('height', $(document).outerHeight());
    },
    
    hide: function(){
        $(loadSpinner.client_id).hide();
    }
}


var _renderOptions = {
    "lastRendering": 0,
    "isNextMerged": 0,
    "changedCells": {}
};


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







var renderOptions_Phases = {
        "Strategy": 'strategy_phase_cell',
        "Plan": 'plan_phase_cell',
        "Architect": 'architect_phase_cell',
        "Build": 'build_phase_cell',
        "Test": 'test_phase_cell',
        "Deploy & Thrive": 'deploy_thrive_phase_cell',
    };


// On DOM Ready
$(function() {
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
    $("#datepicker").datepicker(datepickerOptions);
    reFreshGrid();
    
    
    /** TODO - REMOVE THE CODE LATER
    $("#contextMenu").click(function (e) {
        if (!$(e.target).is("li")) {
          return;
        }
        if (!grid.getEditorLock().commitCurrentEdit()) {
          return;
        }
        var range = $(this).data("data");
        console.log(range);
    });
    **/
    
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
    grid.getCanvasNode().focus();
    
    grid.registerPlugin( new Slick.AutoColumnSize());
    // add header menu plugin
    var headerMenuPlugin = new Slick.Plugins.HeaderMenu({});
    // bind on command event
    headerMenuPlugin.onCommand.subscribe(Timeline.onHeaderMenuCommandHandler);
    // register the plugin
    grid.registerPlugin(headerMenuPlugin);

    
    grid.setSelectionModel(new Slick.CellSelectionModel());
    
    
    /** COPY MANAGER PLUGIN **/
    var copyManager = new Slick.CellCopyManager();
    grid.registerPlugin(copyManager);
    copyManager.onPasteCells.subscribe(Timeline.onPasteCellsHandler);
     

    /***  ROW - REORDERING ***/
    var moveRowsPlugin = new Slick.RowMoveManager();
    moveRowsPlugin.onBeforeMoveRows.subscribe(Timeline.onBeforeMoveRowsHandler);
    moveRowsPlugin.onMoveRows.subscribe(Timeline.onMoveRowsHandler);
    grid.registerPlugin(moveRowsPlugin);

    
    /*** AUTO - TOOLTIP **/
    grid.registerPlugin(new Slick.AutoTooltips());
    
    
    // bind cell change event
    grid.onCellChange.subscribe(Timeline.onCellChangeHandler);
   
    // bind addnew row event
    grid.onAddNewRow.subscribe(Timeline.onAddNewRowHandler);
    
    // beind edit cell event
    grid.onBeforeEditCell.subscribe(Timeline.onBeforeEditCellHandler);
    
    
    /** NOT NEEDED NOW - TO DO REMOVE
    grid.onContextMenu.subscribe(function (e) {
      e.preventDefault();
      var cell = grid.getCellFromEvent(e);
      
      if(cell.row != Timeline.phaseRow){
          return;
      }
      
      $("#contextMenu")
          .data("data", { range : grid.getSelectionModel().getSelectedRanges(), row : cell.row})
          .css("top", e.pageY)
          .css("left", e.pageX)
          .show();

      $("body").one("click", function () {
        $("#contextMenu").hide();
      });
    });
    **/
    
    
    Timeline.renderGrid();
    
    
}






var datepickerOptions = {
    onSelect: function(dateText) {
        if(!$('#build_div').is(':visible')){
          Timeline.onStartDateSelectionChange(new Date(dateText).toYYYYMMDD());
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
        if(typeof refreshOverviewPanel === 'function') refreshOverviewPanel();
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
    fixedRows: 4,
    fixedColumns : 5,
    weekNameRow : 0,
    totalRow : 3,
    phaseRow : 1,
    milestoneRow: 2,
    maxHours : 40,
    calcuation_cols_css : {'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff', 'font-weight' : 'bold'},
    
    triggerUpdateCell: function(field, rowId, val){
        if(rowId.toLowerCase() == 'phase'){
            Timeline.updatePhase(field, val);
        }else if(rowId.toLowerCase() == 'milestone'){
            Timeline.updateMilestone(field, val);
        }else if(field.toLowerCase() == 'skill'){
            Timeline.updateSkill(rowId, val);    
        }else{
           Timeline.updateHours(field, rowId, val);
        }
    },
    
    
    renderGrid: function(){
         
        grid.render();
        
        /** FOLLOWING CODE IS WORKING CODE FOR APPLYING ADDITIONAL CSS STYLE FOR CELLS **/
        /**
        if(Timeline.phaseRow < data.length){
            // phase data
            var currentdata = data[Timeline.phaseRow];
            var options = window._renderOptions;
            var colsLength = columns.length;
            
            $.each(columns, function(indx1, colItem) {
                if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                    var value = currentdata[columns[indx1].field];
                    var nextCellIndex = indx1 + 1;
                    if (nextCellIndex < colsLength){    
                        var nextValue = currentdata[columns[nextCellIndex].field];
                        if (value == nextValue) {
                            if (!options.changedCells[Timeline.phaseRow]) {
                                options.changedCells[Timeline.phaseRow] = {};
                            }
                            options.changedCells[Timeline.phaseRow][columns[indx1].field] = "noneline-bottom";
                        }
                    }    
                }
             });
             console.log(options.changedCells);
             grid.setCellCssStyles('cell-noneline-bottom', options.changedCells);
        }
        **/
         
        
        
    },
    getGridOptions: function(){
      return {
                                                        explicitInitialization : false,
                                                        editable: true,
                                                        enableAddRow: true,
                                                        enableCellNavigation: true,
                                                        asyncEditorLoading: false,
                                                        autoEdit: true,
                                                        enableColumnReorder: false
                                                        ,forceFitColumns : false
                                                        ,headerRowHeight : 30
                                                        ,enableAsyncPostRender: true
                                                        ,asyncPostRenderDelay : 50 // default 50
                                                        ,leaveSpaceForNewRows : true
                                                        //,frozenColumn : 2
                                                        //,frozenRow : 3
                                                        //,autoHeight: true
                                                        //,fullWidthRows: true
                                                        //,frozenBottom: true
                                                    };  
        
    },
    
    onAddNewRowHandler: function(e, args) {
        //var item = args.item;
        //var column = args.column;
        //grid.invalidateRow(data.length);
        //data.push(item);
        //grid.updateRowCount();
        //Timeline.renderGrid();
    },
    
    onHeaderMenuCommandHandler: function(e, args) {

        if (args.command === 'insert_1_right') {
            Timeline.addMoreColumnsOnRight(args.column.id, 1);
        }
        if (args.command === 'insert_2_right') {
            Timeline.addMoreColumnsOnRight(args.column.id, 2);
        }

        if (args.command === 'insert_1_left') {
            Timeline.addMoreColumnsOnLeft(args.column.id, 1);
        }

        if (args.command === 'insert_2_left') {
            Timeline.addMoreColumnsOnLeft(args.column.id, 2);
        }

        if (args.command === 'delete_column') {
            var respond = confirm("Deleting a column will delete all the data for this week/column!!! \nAre you sure you want to delete?");
            if(respond == true) Timeline.deleteColumn(args.column.id);
        }

    },
    
    
    onPasteCellsHandler: function(e, args) {
        if (args.from.length !== 1 || args.to.length !== 1) {
            throw "This implementation only supports single range copy and paste operations";
        }
        //alert('in');
        
        var from = args.from[0];
        var to = args.to[0];
        var val;
        // stop user by copying from phase and pasting it to the number formated calculated or other rows
        // stop user by copying from calculated and pasting it to the phase row
        if(from.fromRow == Timeline.phaseRow && to.fromRow != from.fromRow){
            Timeline.renderGrid();
            return;
        }else if(to.fromRow == Timeline.phaseRow && from.fromRow != to.fromRow){
            Timeline.renderGrid();    
            return;
        }
        
        for (var i = 0; i <= from.toRow - from.fromRow; i++) {
            for (var j = 0; j <= from.toCell - from.fromCell; j++) {
                if (i <= to.toRow - to.fromRow && j <= to.toCell - to.fromCell) {

                    if(typeof columns[to.fromCell + j].usedForCalculation != 'undefined' && columns[to.fromCell + j].usedForCalculation == true){ 
                        val = data[from.fromRow + i][columns[from.fromCell + j].field];
                        //console.log(data[to.fromRow + i].id + ':' + columns[to.fromCell + j].field + ':' + val);
                        
                        data[to.fromRow + i][columns[to.fromCell + j].field] = val;
                        var rowId = data[to.fromRow + i].id;
                        var field = columns[to.fromCell + j].field;
                        
                        Timeline.triggerUpdateCell(field, rowId, val);
                        
                        grid.invalidateRow(to.fromRow + i);
                    }
                }
            }
        }
        grid.setData(data);
        Timeline.renderGrid();

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
        if(args.insertBefore < Timeline.fixedRows || args.rows < Timeline.fixedRows){
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
        Timeline.bindMetadata();
        grid.setData(data);
        grid.setSelectedRows(selectedRows);
        Timeline.renderGrid();
        Timeline.reOrderResources(data);
    },
    
    onBeforeEditCellHandler: function(e, args) {
        // make row un-editable [rows such as weekname, total]
      if (args.row === Timeline.weekNameRow || args.row === Timeline.totalRow) {
        return false;
      }
    },
    
    onCellChangeHandler: function(e, args){
        var field = grid.getColumns()[args.cell].field;
        
        if (field != 'resource' && field != 'autofill') {
            var item = args.item;
            var column = args.cell;
            var row = args.row;
            var value = data[args.row][grid.getColumns()[args.cell].field];
            var rowId = item.id;
            if (rowId && field) {
                Timeline.triggerUpdateCell(field, rowId, value);   
            }
        }
        
        //console.log('cellchange');
        grid.setData(data);
        Timeline.renderGrid();
        
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
        if(dataContext.id == 'phase' || dataContext.id == 'milestone' || dataContext.id == 'weekname' || dataContext.id == 'total'){ 
            return '';
        }
        return 'wait..';
    },
    onResourcePickListChange: function(e) {

        var optionSelected = $("option:selected", this);
        var cost = parseInt(optionSelected.attr('cost'));
        var rate = parseInt(optionSelected.attr('discountedRate'));
        var role = optionSelected.attr('resource');
        var estimateRateCardId = optionSelected.attr('estimateRateCardId');
        
        var order = 1; //this is just dummy setting here; actually set before calling ajax to server
        var skill = '';
        var id = $(this).attr('id');
        if (id.toLowerCase().indexOf('new') != -1) {
            Timeline.addRow(estimateId, order, cost, rate, role, skill, estimateRateCardId);
        } else {
            Timeline.updateRow(estimateId, id, role, skill, cost, rate,  estimateRateCardId);
        }

    },

   onResourceSelectionChange: function(event, ui, id) {
        
    	var cost = parseInt(ui.item.cost);
    	var rate = parseInt(ui.item.discountedRate);
    	var role = ui.item.resource;
    	var estimateRateCardId = ui.item.id == 'undefined' ? '' : ui.item.id; 
    	
    	var order = 1; //this is just dummy setting here; actually set before calling ajax to server
    	var skill = '';
       
    	
    	if (id.toLowerCase().indexOf('new') != -1) {
    		Timeline.addRow(estimateId, order, cost, rate, role, skill, estimateRateCardId);
    	} else {
    		Timeline.updateRow(estimateId, id, role, skill, cost, rate,  estimateRateCardId);
    	}
    
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
                return "<a style='color:#4996D0; text-decoration:none;cursor:pointer' rowId='" + dataContext.id + "' onclick='Timeline.deleteRow(this);'>Del</a>";
            }
            ,notUsedForCalculation : true

        }, {
            id: "selector1",
            field: "resource",
            name: "Resource",
            behavior: "",
            width: 350,
            selectable: false,
            resizable: false,
            focusable : true,
            //editor: PickListEditor,
            editor: AutoCompleteEditor,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
        },{
            id: "skill",
            field: "skill",
            name: "Skill",
            width: 50,
            selectable: false,
            resizable: false,
            focusable : true,
            editor: SkillEditor,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
        }, {
            id: "autofill",
            field: "autofill",
            name: "",
            behavior: "",
            width: 45,
            selectable: false,
            resizable: false,
            focusable : true,
            cssClass: "",
            groupName: " ",
            header: {},
            headerCssClass: "Fixed-Header-Style",
            order: null
            ,notUsedForCalculation : true
            ,formatter: function(row, cell, value, columnDef, dataContext) {
                    if(row < Timeline.fixedRows || dataContext.id == ''){
                      return "";
                    }
                    return "<button style='color:#4996D0; height: 16px;line-height: 16px;' rowId='" + dataContext.id + "' onclick='return false;'>Auto</button>";
              }
              ,editor: AutoFillEditor
        }];
    },
    getHoursSum: function(cellNode, row, dataContext, colDef){
            var rowData = data[row];
            var sum = 0;
            $.each(columns, function(indx1, colItem) {
                if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                    sum += parseInt(isNaN(rowData[colItem.field]) ? 0 : rowData[colItem.field]);
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
               if(!colItem.notUsedForCalculation) sum += (typeof rowItem[colItem.id] == 'undefined' || rowItem[colItem.id] == ''? 0 : parseInt(rowItem[colItem.id]));
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
                            if(row == Timeline.totalRow){
                                 //$(cellNode).empty().html(Timeline.getSumOfHoursForRows()).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                                 $(cellNode).empty().html(Timeline.getSumOfHoursForAllRows(cellNode, row, dataContext, colDef)).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }else{
                          $(cellNode).empty().html(Timeline.getHoursSum(cellNode, row, dataContext, colDef)).css({'text-align':'center'});
                        }
                    }
                }, {
                    id: "rate",
                    name: "Rate",
                    field: "rate",
                    //width: 50,
                    selectable: false,
                    resizable: true,
                    focusable : false,
                    order: null
                    ,cssClass : "slds-calculated-cell"
                    ,headerCssClass: "Fixed-Header-Style"
                    ,notUsedForCalculation : true
                    ,formatter: function(row, cell, value, columnDef, dataContext) {
                        if(row < Timeline.fixedRows){
                            return '';
                        }
                        return value == '' ? '' : currency_code + " "  + parseFloat(value).toFixed(2);
                        
                    },asyncPostRender: function(cellNode, row, dataContext, colDef) {
                        //console.log('postrender');
                        if(row < Timeline.fixedRows){
                            if(row == Timeline.totalRow){
                                 //$(cellNode).empty().html(Timeline.getSumOfBelowRows()).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                                 var rate = Timeline.getAvgOfBelowRows(cellNode, row, dataContext, colDef);
                                 $(cellNode).empty().html(currency_code + " "  + parseFloat(isNaN(rate) ? 0 : rate).toFixed(2)).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }
                    }
                }, {
                    id: "cost",
                    name: "Cost",
                    field: "cost",
                    //width: 50,
                    selectable: false,
                    resizable: true,
                    focusable : false,
                    order: null
                    ,cssClass : "slds-calculated-cell"
                    ,headerCssClass: "Fixed-Header-Style"
                    ,notUsedForCalculation : true
                    ,formatter: function(row, cell, value, columnDef, dataContext) {
                        if(row < Timeline.fixedRows){
                            return '';
                        }
                        return value == '' ? '' : currency_code + " "  + parseFloat(value).toFixed(2);
                        
                    },asyncPostRender: function(cellNode, row, dataContext, colDef) {
                        //console.log('postrender');
                        if(row < Timeline.fixedRows){
                            if(row == Timeline.totalRow){
                                 //$(cellNode).empty().html(Timeline.getSumOfBelowRows()).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                                 var cost = Timeline.getAvgOfBelowRows(cellNode, row, dataContext, colDef);
                                 $(cellNode).empty().html(currency_code + " "  + parseFloat(isNaN(cost) ? 0 : cost).toFixed(2)).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }
                    }
                },{
                    id: "cost_price",
                    name: "Total Cost",
                    field: "cost_price",
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
                        if(row < Timeline.fixedRows){
                            if(row == Timeline.totalRow){
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
                                    sum += parseInt(row_sum) * parseInt(rowItem.cost);
                                    //console.log('----------' + sum + '-------------' + rowItem.id);
                                 });
                                 
                                 var total_cost = parseFloat(sum).toFixed(2);
                                 $(cellNode).empty().html(currency_code + " "  + total_cost).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }
                        $(cellNode).empty().html(currency_code + " "  + parseFloat(Timeline.getHoursSum(cellNode, row, dataContext, colDef) * dataContext.cost).toFixed(2));
                    }
                },{
                    id: "selling_price",
                    name: "Total Price",
                    field: "selling_price",
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
                        if(row < Timeline.fixedRows){
                            if(row == Timeline.totalRow){
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
                                 $(cellNode).empty().html(currency_code + " "  + total_price).css(Timeline.calcuation_cols_css);
                            }
                            return;
                        }
                        $(cellNode).empty().html(currency_code + " "  + parseFloat(Timeline.getHoursSum(cellNode, row, dataContext, colDef) * dataContext.rate).toFixed(2));
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
                                                },
                                        "selector1" : {
                                                  formatter: function(row, cell, value, columnDef, dataContext) {
                                                        if(row == Timeline.phaseRow){
                                                          return "<div style='width:100%;text-align:right;font-weight: bold;'>PHASE</div>";
                                                        }else if(row == Timeline.weekNameRow){
                                                          return "<div style='width:100%;text-align:right;font-weight: bold;'>WEEK</div>";    
                                                        }else if(row == Timeline.milestoneRow){
                                                          return "<div style='width:100%;text-align:right;font-weight: bold;'>MILESTONE</div>";  
                                                        }else if(row == Timeline.totalRow){
                                                          return "<div style='width:100%;text-align:right;font-weight: bold;'>TOTAL HRS</div>";    
                                                        }
                                                        return value;
                                                  },
                                                  focusable : false,
                                                  editor: ""
                                        }       
                      }
                    };
                    
                if(row == Timeline.weekNameRow || row == Timeline.totalRow){
                  return metadata;    
                }else if(row == Timeline.milestoneRow){
                     $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                             metadata.columns[colItem.field] = {};
                             metadata.columns[colItem.field].editor = MilestoneEditor;
                        }
                    });
                    return metadata;
                }else if(row == Timeline.phaseRow){
                    
                    var currentRow = data[row];
                             
                    $.each(columns, function(indx1, colItem) {
                        if(indx1 >= Timeline.fixedColumns && typeof colItem.usedForCalculation != 'undefined' && colItem.usedForCalculation){
                             metadata.selectable = true;
                             var val = currentRow[columns[indx1].field];
                             var nextCellIndex = indx1 + 1;
                             var colspan = 1;
                             while(nextCellIndex < columns.length){
                                 //console.log('----' + val + '==' + currentRow[columns[nextCellIndex].field] + '----');
                                 if(val == currentRow[columns[nextCellIndex].field] && val != ''){ 
                                   colspan++;  
                                 }else {
                                     break;
                                 } 
                                 nextCellIndex += 1;
                             }
                             //console.log('----' + colspan + '----');
                             metadata.columns[colItem.field] = {};
                             metadata.columns[colItem.field].editor = MilestoneEditor;
                             //metadata.columns[colItem.field].editor = PhaseSelectionEditor;
                             metadata.columns[colItem.field].colspan = colspan;
                        }
                    });
                    return metadata;
                }
           }
        
        
    },
    rt_json : [],
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
                var resource = row.Region__c + ' - ' + row.Resource_Role__c;
                var json_obj = {};
                json_obj['id'] = row.Id;
                json_obj['region'] = row.Region__c;
                json_obj['role'] = row.Resource_Role__c;
                // rate card rate
                json_obj['suggestedRate'] = row.Bill_Rate__c;
                // custom/editable bill rate
                json_obj['discountedRate'] = row.Discounted_Rate__c;
                // resource cost
                json_obj['cost'] = row.Resource_Cost__c;
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
                if (indx === 0) {
                    $("#datepicker").datepicker('setDate', new Date(column.sDate));
                    $('#build_div').hide();
                };
            });
            
            
            // clear the initital array
            result = [];
            
            columns = columns.concat(Timeline.getEndColumns());
            // set the grid's columns as the new columns
            grid.setColumns(columns);
            
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
        column["validator"] = Timeline.numFieldValidator;
        column.asyncPostRender = function(cellNode, row, dataContext, colDef) {
                //console.log('postrender');
                if(row < Timeline.fixedRows){
                     if(row == Timeline.totalRow){
                        var sum = 0;
                        var rowData = data.slice(row + 1);
                         $.each(rowData, function(indx, rowItem) {
                            sum += (typeof rowItem[colDef.id] == 'undefined' || rowItem[colDef.id] == ''? 0 : parseInt(rowItem[colDef.id]));
                         });
                         $(cellNode).empty().html(sum).css({'text-align' : 'center', 'background-color': '#666666', 'color' : '#fff'});
                     }
                     
                     if(row == Timeline.phaseRow){
                        //var sum = 0;
                        var rowData = data[row][colDef.id];
                        
                        // remove all custom css classes first and apply than the new one next;
                        for(var _a in renderOptions_Phases){
                            var cls = renderOptions_Phases[_a];
                            if(typeof cls == 'String') $(cellNode).removeClass(cls);
                        }
                        // apply the new ones 
                        if(typeof renderOptions_Phases[rowData] != 'undefined'){
                            var cls = renderOptions_Phases[rowData];
                            $(cellNode).addClass(cls);
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
                if (indx === 0) {
                    $("#datepicker").datepicker('setDate', new Date(column.sDate));
                    $('#build_div').hide();
                };
            });
            // clear the initital array
            result = [];
            // set the grid's columns as the new columns
            columns = columns.concat(Timeline.getEndColumns());
            grid.setColumns(columns);
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
            // TODO: DO THE REORDERING AND ALL WITH THIS; AFTER PHASE IMPLEMENT
            for(var indx = 0; indx < Timeline.fixedRows; indx++){
                var row = {
                    id : indx == 0 ? 'weekname' : (indx == 1 ? 'phase' : (indx == 2 ? 'milestone' : 'total'))
                };
                
                $.each(columns, function(indx1, colRow) {
                    if(indx1 >= Timeline.fixedColumns){
                      //console.log('phase' + indx1 + ':' + (typeof colRow.phase == 'undefined' || colRow.phase == null ? '' : colRow.phase));    
                      if(row.id == 'phase') row[colRow.id] = (typeof colRow.phase == 'undefined' || colRow.phase == null ? '' : colRow.phase);
                      if(row.id == 'milestone') row[colRow.id] = (typeof colRow.milestone == 'undefined' || colRow.milestone == null ? '' : colRow.milestone);
                      if(row.id == 'weekname') row[colRow.id] = (typeof colRow.order == 'undefined' || colRow.order == null ? '' : colRow.order);
                      if(row.id == 'total') row[colRow.id] = 0;
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
            loader.hide();
        },
        onFailure: function(error) {
            alert(error);
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
            }, Timeline.getColumns_Callback);

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
        cost, rate, role,
        skill, estimateRateCardId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "addRow", {
            estimateId: estimateId,
            order: ((data.length - Timeline.fixedRows) + 1),
            cost: cost,
            rate: rate,
            role: role,
            skill: skill,
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
        role,
        skill,cost,rate,estimateRateCardId) {
        loader.show();
        sforce.apex.execute(WEBSERVICE_NAME, "updateRow", {
            estimateId: estimateId,
            rowId: rowId,
            role: role,
            skill: skill,
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
    
    
    updatePhase_call_register: {},
    updatePhase: function(weekId, phase) {
        loader.show();
        Timeline.updatePhase_call_register[weekId] = 'phase';  
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
    updateMilestone_call_register: {},
    updateMilestone: function(weekId, milestone) {
        loader.show();
        Timeline.updateMilestone_call_register[weekId] = 'phase'; 
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
        CustomAlert.show('Rate card has been successfully updated!!!');
        tabpanel.showTimelineTab();
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
        CustomAlert.show('Rate card has been successfully refreshed!!!');
        tabpanel.showTimelineTab();
        reFreshGrid();
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
        }, Timeline.onbuild_Callback);
        
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
            sforce.apex.execute(WEBSERVICE_NAME, "getTimelineColumns", {
                estimateId: estimateId
            }, Timeline.initCallback);

        },
        onFailure: function(error) {
            alert(error);
            loader.hide();
        }
    }
    
}
