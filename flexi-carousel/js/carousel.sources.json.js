/*global jQuery */
/*properties
 ajax, ajaxOptions, beforeInit, carousel, crossDomain, dataType,
 flexiCarousel, fn, getFlowOptions, json, name, noop, populate, settings,
 source, success, type, url
 */

(function ($) {

    "use strict";

    var sourcesJson = {
        type: 'sourceFlow',
        name: 'json',
        settings: {
            url: false,
            ajaxOptions: {},
            json: []
        },
        beforeInit: function () {
            var options = this.carousel.getFlowOptions('source'),
                json = options.json,
                jsonp = false,
                local = true,
                successCallback = options.ajaxOptions.success === undefined ? $.noop : options.ajaxOptions.success,
                $carousel = this.carousel;
            switch (this.carousel.settings.source) {
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
            if (!local) {
                if (!options.ajaxOptions.url) {
                    options.ajaxOptions.url = options.url;
                }
                options.ajaxOptions.dataType = (jsonp ? 'jsonp' : 'json');
                options.ajaxOptions.crossDomain = jsonp;
                options.ajaxOptions.success = function (data, textStatus, jqXHR) {
                    $carousel.populate(data);
                    successCallback(data, textStatus, jqXHR);
                };
                $.ajax(options.ajaxOptions);
            } else {
                $carousel.populate(json);
            }

        }
    };

    $.fn.flexiCarousel('registerFlow', sourcesJson);

}(jQuery));