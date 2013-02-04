(function($) {

    var sourcesJson = {
        type: 'sourceFlow',
        name: 'json',
        settings: {
            url: false,
            ajaxOptions: {},
            json: {}
        },
        beforeInit: function() {
            var options = this.getFlowOptions('source'),
                json = options.json,
                jsonp = false,
                local = true,
                successCallback = options.ajaxOptions.success === undefined ? $.noop : options.ajaxOptions.success,
                $this = this;
            switch(this.settings.source) {
                case 'ajax':
                    local = false;
                    break;
                case 'jsonp':
                    local = false;
                    jsonp = true;
                    break;
                default:
                    break;
            }
            if(!local) {
                if(!options.ajaxOptions.url) {
                    options.ajaxOptions.url = options.url;
                }
                options.ajaxOptions.dataType = (jsonp ? 'jsonp' : 'json');
                options.ajaxOptions.crossDomain = jsonp;
                options.ajaxOptions.success = function(data, textStatus, jqXHR) {
                    $this.populate(data);
                    successCallback(data, textStatus, jqXHR);
                };
                $.ajax(options.ajaxOptions);
            }

        }
    };

    $.fn.flexiCarousel('registerFlow', sourcesJson);

}(jQuery));