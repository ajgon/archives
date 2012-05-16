//= require jquery
//= require jquery_ujs
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

ResourceManager.register('all', function() {
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
ResourceManager.register(['index'], function() {
    $('a[rel="tooltip"]').tooltip();
});

// Fetch dataTables
ResourceManager.register(['index'], function() {
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

    $('.DataTables_actions').each(function() {
        $(this).html(
            '<a href=' + window.location.pathname + "/new "  +  'class="btn btn-primary btn-mini DataTables_add">' +
             'Add new ' + $(this).closest('.dataTables_wrapper').find('.table').data('name').toLowerCase() + '</a>' +
             ' <a href="#" class="btn btn-danger btn-mini disabled DataTables_remove">Delete selected rows</a>');
    });

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
ResourceManager.register(['show'], function() {
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
ResourceManager.register(['new', 'edit'], function() {
    $('[type="number"]').numeric();

    $('input.date').datepicker({
        dateFormat: 'yy-mm-dd'
    });
    $('input.time').timepicker({});

    $('.control-group, .controls').addClass('row-fluid');
    $('.control-label').addClass('span2');
    $('.controls').addClass('span10');
    $('.controls > input, .controls > textarea').addClass('span12');
});


$(document).ready(function() {
    ResourceManager.launch(RESOURCE);
});