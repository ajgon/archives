//= require jquery
//= require jquery_ujs
//= require cocoon
//= require libraries/jquery.dataTables
//= require libraries/jquery.numeric
//= require libraries/jquery-ui.min
//= require libraries/jquery-ui.timepicker
//= require libraries/bootstrap
//= require libraries/prettify
//= require libraries/resourceManager

// AJAX handlers

var showFlash = function(code, message) {
    var alertBar = $('<div class="alert alert-' + code.toLowerCase() + ' fade in" data-dismiss="alert">' +
        message + '</div>');
    $('#flash').append(alertBar);
    alertBar.delay(3000).fadeOut(function() { $(this).remove(); });
};

var cleanForms = function(parent, main) {
    main = typeof(main) == 'undefined' ? true : main;
    $('.control-group, .controls', parent).addClass('row-fluid');
    $('.control-label', parent).addClass('span2');
    $('.controls', parent).addClass(main ? 'span10' : 'span9');
    $('.controls > input, .controls > textarea', parent).addClass('span12');
    $('[type="number"]', parent).numeric();

    $('input.date', parent).datepicker({
        dateFormat: 'yy-mm-dd'
    });
    $('input.time', parent).timepicker({});
};

ResourceManager.register(function() {
    $('#flash').ajaxSuccess(function(e, xhr, settings) {
        try {
            var response = $.parseJSON(xhr.responseText);
            if(response.code && response.message) {
                showFlash(response.code, response.message);
            }
        } catch(exception) {}
    }).ajaxError(function() {
            showFlash('ERROR', 'An error has occurred! Please, try again later.');
        });
});


// Show tooltips
ResourceManager.register({only: ['index']}, function() {
    $('a[rel="tooltip"]').tooltip();
});

// Fetch dataTables
ResourceManager.register({only: ['index']}, function() {
    if($('#dashboard').size() > 0) {
        return;
    }
    var datatables_actions = '',
        disabled_actions;

    $.extend( $.fn.dataTableExt.oStdClasses, {
        "sWrapper": "dataTables_wrapper form-inline"
    } );

    $('.table-data').dataTable( {
        "bProcessing": true,
        "bServerSide": true,
        "sDom": "<'row-fluid'<'span2'l><'DataTables_actions span4'><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
        "sAjaxSource": window.location.pathname.replace(/\/$/, '') + '.json',
        "sPaginationType": "bootstrap",
        'iDisplayLength': 20,
        "aLengthMenu": [[10, 20, 50, -1], [10, 20, 50, "All"]],
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, "aTargets": [-1] },
            { "fnRender" : function(o, val) { return '<div>' + val + '</div>'; }, "aTargets": ['_all'] }
        ]
    }).dataTableCRUD({
            "fnRowHighlighted": function(iRowsNum) {
                $('.DataTables_remove').toggleClass('disabled', iRowsNum <= 0);
            }
        });

    disabled_actions = $('.dataTables_wrapper').find('.table').data('disabled-actions').split(' ');
    if($.inArray('new', disabled_actions) < 0) {
        datatables_actions += '<a href=' + window.location.pathname + "/new "  +  'class="btn btn-primary btn-mini DataTables_add">' +
            'Add new ' + $('.dataTables_wrapper').find('.table').data('name').replace(/([a-z])([A-Z])/g, "$1 $2").toLowerCase() + '</a>';
    }
    if($.inArray('destroy', disabled_actions) < 0) {
        datatables_actions += ' <a href="#" class="btn btn-danger btn-mini disabled DataTables_remove">Delete selected rows</a>';
    }

    $('.DataTables_actions').html(datatables_actions);

    $('.DataTables_remove').click(function(e) {
        e.preventDefault();
        if(!$(this).hasClass('disabled')) {
            var dataTable = $(this).closest('.dataTables_wrapper').find('.table');
            $.ajax({
                url: window.location.pathname + '/' + $.map(dataTable.find('tr.highlight'), function(i) {
                    return $(i).attr('id');
                }).join(',') +'.json',
                type: "DELETE",
                dataType: 'json',
                success: function() {
                    dataTable.dataTable().fnReloadAjax();
                }
            });
        }
    });

    //$('.DataTables_action').

});

// Enable google prettify
ResourceManager.register({only: ['show']}, function() {
    prettyPrint();
    $('.wysiwyg .code').hide();
    if($('.wysiwyg .raw a').size()) {
        $('.wysiwyg a').click(function(e) {
            e.preventDefault();
            $(this).closest('.wysiwyg').find('.code, .raw').toggle();
        });
    }
});

// Validate forms
ResourceManager.register({except: ['index', 'show']}, function() {
    var fieldsTimer, nestedFieldsSize = 0;

    cleanForms($('.editform'));
    $('.editform').delegate('.add_fields', 'click', function(e) {
        var self = $(this);
        fieldsTimer = setInterval(function() {
            if(nestedFieldsSize != self.parent().prevAll('.nested-fields').size()) {
                clearInterval(fieldsTimer);
                cleanForms(self.parent().prev(), false);
                nestedFieldsSize = self.parent().prevAll('.nested-fields').size();
            }
        }, 10);
    });
});

// Dashboard stuff
ResourceManager.register({only: ['index']}, function() {
    if($('#dashboard').size()) {
        $('tbody tr').click(function(e) {
            if($(this).data('url')) {
                window.location.href = $(this).data('url');
            }
        });
    }
});


$(document).ready(function() {
    ResourceManager.launch(RESOURCE);
});
