ResourceManager.register({only: ['edit']}, function() {
    $('input.paperclip').each(function() {
        var img_src = $(this).data('value').replace(/original/, 'admin_bootstrap'),
            self = this;
        $.ajax({
            url: img_src,
            type: 'HEAD',
            success: function(){
                var new_img = $('<img src="' + img_src + '" alt="" class="paperclip" />');
                $(self).before(new_img);
                new_img.css('padding-left', (79 - new_img.width()) / 2).css('padding-right', (79 - new_img.width()) / 2).css('padding-top', (79 - new_img.height()) / 2).css('padding-bottom', (79 - new_img.height()) / 2);
                new_img.popover({
                    content: '<img src="' + $(self).parent().find('input.paperclip').data('value') + '" />',
                    placement: 'left'
                });
            }
        });
    });

});