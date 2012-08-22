(function($) {
    $.fn.dataTableCRUD = function(options) {

        var oTable = this;

        var defaults = {
            "fnRowHighlighted": function(iNumRows) {}
        };

        var ctrlKeyPressed = false;
        var properties = $.extend(defaults, options);
        var oSettings = oTable.fnSettings();

        // Disable selection
        var _fnToggleSelection = function(enable) {
            enable = typeof(enable) == 'undefined' ? true : enable;
            enable = enable ? 'text' : 'none';
            if($.browser.msie) {
                if(enable == 'text') {
                    this.onselectstart = null;
                    this.unselectable = "off";
                } else {
                    this.onselectstart = function() { return false; };
                    this.unselectable = "on";
                }
            }
            $(oTable).css('user-select', enable);
            $(oTable).css('-o-user-select', enable);
            $(oTable).css('-moz-user-select', enable);
            $(oTable).css('-khtml-user-select', enable);
            $(oTable).css('-webkit-user-select', enable);
        };

        // Multiple row select
        var _fnMultipleRowSelect = function(oSettings) {
            $(this).each(_fnToggleSelection);
            $(this).find('tbody tr').click(function(e) {
                if(e.target.nodeName.toUpperCase() == 'A' || $(this).find('.dataTables_empty').size()) {
                    return;
                }
                if(!ctrlKeyPressed) {
                    $(this).parent().find('tr').not($(this)).removeClass('highlight');
                }
                $(this).toggleClass('highlight');
                properties.fnRowHighlighted($(this).parent().find('tr.highlight').size());
            });
        };

        // Handle ctrl
        $(document).bind('keydown keyup', function(e) {
            ctrlKeyPressed = e.ctrlKey || (e.type == 'keydown' && (e.keyCode == 224 || e.charCode == 224));
            _fnToggleSelection(!ctrlKeyPressed);
        });

        return this.each(function() {

            oTable.fnSettings().aoDrawCallback.push({
                "sName": "multiple_row_select",
                "fn": _fnMultipleRowSelect
            });

        });

    };
}(jQuery));