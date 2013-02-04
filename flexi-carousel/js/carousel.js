/*global jQuery*/
/*properties
 DEFAULTS, addClass, append, apply, call, clickEvent, closest, currentIndex,
 data, determineFrameIndex, each, elem, empty, error, extend, filter, find,
 fireCallback, flexiCarousel, fn, getAllSlides, getAllThumbnails,
 getFlowOptions, getNavItem, getSlide, getThumbnail, hasOwnProperty, hide,
 index, init, initEvents, items, length, loadModuleOptions, loop, match, name,
 on, populate, preventDefault, prototype, registerFlow, removeClass, replace,
 settings, show, showFrame, size, slice, slide, slides, slidesContainer,
 slidesFlow, slidesFlowOptions, slidesFlows, slidesNext, slidesPrevious,
 slidesTagName, source, sourceFlow, sourceFlowOptions, sourceFlows,
 startIndex, successfulSlide, successfulSource, successfulThumbnail,
 switchFrame, switchSlide, switchThumbnail, thumbnail, thumbnailCurrent,
 thumbnails, thumbnailsContainer, thumbnailsFlow, thumbnailsFlowOptions,
 thumbnailsFlows, thumbnailsNext, thumbnailsPrevious, thumbnailsTagName, type
 */

(function ($) {
    "use strict";

    var FlexiCarousel = function (items, options) {
        this.settings = $.extend(FlexiCarousel.DEFAULTS, options);
        this.loadModuleOptions(options);
        this.clickEvent = 'click';
        this.items = items;

        this.fireCallback('beforeInit');

        this.currentIndex = this.settings.startIndex;
        this.getAllThumbnails().removeClass(this.settings.elem.thumbnailCurrent);
        this.switchFrame();
        this.initEvents();

        this.fireCallback('afterInit');

    };

    FlexiCarousel.prototype = {
        loadModuleOptions: function (options) {
            var f, fName;
            for (f in FlexiCarousel.DEFAULTS) {
                if (FlexiCarousel.DEFAULTS.hasOwnProperty(f) && f.match(/FlowOptions$/)) {
                    fName = f.replace(/Options$/, '');
                    if (this.settings[fName + 's'][this.settings[fName]]) {
                        this.settings[f] = $.extend(this.settings[fName + 's'][this.settings[fName]].settings, options[f]);
                    }
                }
            }
        },
        initEvents: function () {
            var $fc = this;
            this.getNavItem('slidesNext').on(this.clickEvent, function (e) {
                e.preventDefault();
                $fc.showFrame('next');
            });
            this.getNavItem('slidesPrevious').on(this.clickEvent, function (e) {
                e.preventDefault();
                $fc.showFrame('previous');
            });
            this.getNavItem('thumbnails').on(this.clickEvent, '.' + this.settings.elem.thumbnail, function (e) {
                var $this = $(this);
                e.preventDefault();
                $fc.showFrame($this.closest('.' + $fc.settings.elem.thumbnails).find('.' + $fc.settings.elem.thumbnail).index($this));
            });
        },

        fireCallback: function (name) {
            var params = Array.prototype.slice.call(arguments, 1),
                successful = {
                    successfulSlide: false,
                    successfulThumbnail: false,
                    successfulSource: true
                };
            if (FlexiCarousel.DEFAULTS.sourceFlows[this.settings.sourceFlow] && FlexiCarousel.DEFAULTS.sourceFlows[this.settings.sourceFlow][name]) {
                FlexiCarousel.DEFAULTS.sourceFlows[this.settings.sourceFlow][name].apply(this, params);
            }
            if (FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slidesFlow] && FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slidesFlow][name]) {
                FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slidesFlow][name].apply(this, params);
                successful.successfulSlide = true;
            }
            if (FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailsFlow] && FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailsFlow][name]) {
                FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailsFlow][name].apply(this, params);
                successful.successfulThumbnail = true;
            }
            return successful;
        },
        determineFrameIndex: function (frameIndicator) {
            var slidesSize = this.getAllSlides().size(),
                frameIndex = this.currentIndex;
            switch (frameIndicator) {
            case 'next':
                frameIndex += 1;
                break;
            case 'previous':
                frameIndex -= 1;
                break;
            case undefined:
                break;
            default:
                frameIndex = parseInt(frameIndicator, 10);
            }
            if (frameIndex < 0) {
                frameIndex = this.settings.loop ? slidesSize - 1 : 0;
            }
            if (frameIndex > slidesSize - 1) {
                frameIndex = this.settings.loop ? 0 : slidesSize - 1;
            }
            return frameIndex;
        },
        populate: function (jsonData) {
            var slidesContainer = this.items.find('.' + this.settings.elem.slides),
                thumbnailsContainer = this.items.find('.' + this.settings.elem.thumbnails),
                jd,
                jdLen = jsonData.length;
            slidesContainer.empty();
            thumbnailsContainer.empty();
            for (jd = 0; jd < jdLen; jd += 1) {
                slidesContainer.append($('<' + this.settings.elem.slidesTagName + ' class="' + this.settings.elem.slide + '">' + jsonData[jd].slide + '</' + this.settings.elem.slidesTagName + '>'));
                if (jsonData[jd].thumbnail) {
                    thumbnailsContainer.append($('<' + this.settings.elem.thumbnailsTagName + ' class="' + this.settings.elem.thumbnail + '">' + jsonData[jd].thumbnail + '</' + this.settings.elem.thumbnailsTagName + '>'));
                }
            }
            this.switchFrame();
        },

        switchSlide: function (slideIndex) {
            this.getAllSlides().hide();
            this.getSlide(slideIndex).show();
        },
        switchThumbnail: function (thumbnailIndex) {
            this.getAllThumbnails().removeClass(this.settings.elem.thumbnailCurrent);
            this.getThumbnail(thumbnailIndex).addClass(this.settings.elem.thumbnailCurrent);
        },
        switchFrame: function (frameIndicator) {
            var frameIndex = this.determineFrameIndex(frameIndicator);
            this.switchSlide(frameIndex);
            this.switchThumbnail(frameIndex);
        },

        showFrame: function (frameIndicator) {
            var successful,
                frameIndex = this.determineFrameIndex(frameIndicator);
            if (frameIndex !== this.currentIndex) {
                successful = this.fireCallback('showFrame', frameIndex);
                if (!successful.successfulSlide) {
                    this.switchSlide(frameIndex);
                }
                if (!successful.successfulThumbnail) {
                    this.switchThumbnail(frameIndex);
                }
                this.currentIndex = frameIndex;
            }
        },

        getAllSlides: function () {
            return this.items.find('.' + this.settings.elem.slides + ' > .' + this.settings.elem.slide);
        },
        getSlide: function (slideIndex) {
            slideIndex = slideIndex === undefined ? this.currentIndex : slideIndex;
            return this.getAllSlides().filter(':eq(' + slideIndex + ')');
        },
        getAllThumbnails: function () {
            return this.items.find('.' + this.settings.elem.thumbnails + ' > .' + this.settings.elem.thumbnail);
        },
        getThumbnail: function (thumbnailIndex) {
            thumbnailIndex = thumbnailIndex === undefined ? this.currentIndex : thumbnailIndex;
            return this.getAllThumbnails().filter(':eq(' + thumbnailIndex + ')');
        },
        getNavItem: function (name) {
            return this.items.find('.' + this.settings.elem[name]);
        },
        getFlowOptions: function (flowName) {
            // FIXME determine slides/thumbnail flow in a better way
            return this.settings[flowName + 'FlowOptions'];
        }

    };

    FlexiCarousel.DEFAULTS = {
        startIndex: 0,
        sourceFlow: 'default',
        slidesFlow: 'none',
        thumbnailsFlow: 'none',
        loop: true,
        source: 'local',  // local, ajax, jsonp
        sourceFlowOptions: {},
        slidesFlowOptions: {},
        thumbnailsFlowOptions: {},
        sourceFlows: {},
        slidesFlows: {},
        thumbnailsFlows: {},
        elem: {
            slidesContainer: 'flexicarousel-slides-container',
            slides: 'flexicarousel-slides',
            slide: 'flexicarousel-slide',
            slidesPrevious: 'flexicarousel-slides-previous',
            slidesNext: 'flexicarousel-slides-next',
            slidesTagName: 'li',
            thumbnailsContainer: 'flexicarousel-thumbnails-container',
            thumbnails: 'flexicarousel-thumbnails',
            thumbnail: 'flexicarousel-thumbnail',
            thumbnailsPrevious: 'flexicarousel-thumbnails-previous',
            thumbnailsNext: 'flexicarousel-thumbnails-next',
            thumbnailsTagName: 'li',
            thumbnailCurrent: 'flexicarousel-thumbnail-current'
        }
    };

    $.fn.flexiCarousel = function (method) {
        var methods = {
            init: function (options) {
                return this.each(function () {
                    var $this = $(this),
                        flexiCarousel = new FlexiCarousel($this, options);

                    $this.data('flexiCarousel', flexiCarousel);
                });
            },
            registerFlow: function (flow) {
                switch (flow.type) {
                case 'thumbnailsFlow':
                case 'sourceFlow':
                    break;
                default:
                    flow.type = 'slidesFlow';
                }
                flow.type = flow.type + 's';
                FlexiCarousel.DEFAULTS[flow.type][flow.name] = flow;
            }
        };

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        }
        if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        }
        $.error('Method ' +  method + ' does not exist on jQuery.flexiCarousel');

    };
}(jQuery));