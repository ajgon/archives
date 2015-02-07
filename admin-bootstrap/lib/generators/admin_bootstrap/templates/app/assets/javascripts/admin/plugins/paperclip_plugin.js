ResourceManager.register({only: ['edit']}, function() {
    $('input.paperclip').each(function() {
        var img_src = $(this).data('value').replace(/original/, 'admin_bootstrap'),
            self = this;
        $.ajax({
            url: img_src,
            type: 'HEAD',
            success: function(){
                var new_img = $('<img src="' + img_src + '" alt="" class="paperclip" />');
                $(self).before($('<div class="image paperclip"><a href="#" class="btn btn-danger btn-mini offset2 remove_fields dynamic">Remove</a><span class="loading"></span></div>').prepend(new_img));
                new_img.css('padding-left', (79 - new_img.width()) / 2).css('padding-right', (79 - new_img.width()) / 2).css('padding-top', (79 - new_img.height()) / 2).css('padding-bottom', (79 - new_img.height()) / 2);
                new_img.popover({
                    content: '<img src="' + $(self).parent().find('input.paperclip').data('value') + '" />',
                    placement: 'left'
                });
            }
        });
    });

    $('input.paperclip').parent().delegate('a.btn', 'click', function(e) {
        e.preventDefault();
        var self = this;
        $(this).parent().find('.loading').show();
        $.ajax({
            url: '/admin/ajax/paperclip',
            data: { model: MODEL, id: ID, action: 'delete', column: $(this).parent().parent().find('input.paperclip').attr('name').replace(/.*\[/, '').replace(']', '') },
            success: function() {
                $(self).parent().find('.loading').hide();
                $(self).parent().fadeOut(function() {
                    $(this).remove();
                });
            }
        });
    });

});