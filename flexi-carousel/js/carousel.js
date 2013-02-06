/*global jQuery*/
/*jslint browser: true */
/*properties
 DEFAULTS, addClass, append, apply, call, carousel, clickEvent, closest,
 currentIndex, data, determineFrameIndex, each, elem, empty, error, extend,
 filter, find, fireCallback, flexiCarousel, fn, getAllSlides,
 getAllThumbnails, getFlowOptions, getNavItem, getSlide, getThumbnail,
 hasOwnProperty, hide, index, init, initTypes, interval, items, length, loop,
 match, name, on, populate, preventDefault, prototype, push, registerFlow,
 reload, reloadEvents, reloadTimer, removeClass, replace, settings, show,
 showFrame, size, slice, slide, slides, slidesContainer, slidesFlow,
 slidesFlowOptions, slidesFlows, slidesNext, slidesPrevious, slidesSuccessful,
 slidesTagName, source, sourceFlow, sourceFlowOptions, sourceFlows,
 sourceSuccessful, startIndex, switchFrame, switchSlide, switchThumbnail,
 thumbnail, thumbnailCurrent, thumbnails, thumbnailsContainer, thumbnailsFlow,
 thumbnailsFlowOptions, thumbnailsFlows, thumbnailsNext, thumbnailsPrevious,
 thumbnailsSuccessful, thumbnailsTagName, timer, type, types, typesLen,
 unbind, updateOptions
 */

(function ($) {
    "use strict";

    var FlexiCarousel = function (items, options) {
        this.settings = FlexiCarousel.DEFAULTS;
        this.types = [];
        this.typesLen = 0;
        this.initTypes();
        this.updateOptions(options);
        this.clickEvent = 'click';
        this.items = items;
        this.timer = false;

        this.fireCallback('beforeInit');

        this.reload(true);

        this.fireCallback('afterInit');

    };

    FlexiCarousel.prototype = {
        updateOptions: function (options) {
            var t;
            this.settings = $.extend(this.settings, options);
            for (t = 0; t < this.typesLen; t += 1) {
                if (this.settings[this.types[t] + 'Flows'][this.settings[this.types[t] + 'Flow']]) {
                    this.settings[this.types[t] + 'FlowOptions'] = $.extend(this.settings[this.types[t] + 'Flows'][this.settings[this.types[t] + 'Flow']].settings, options[this.types[t] + 'FlowOptions']);
                }
            }

        },
        initTypes: function () {
            var f;
            for (f in FlexiCarousel.DEFAULTS) {
                if (FlexiCarousel.DEFAULTS.hasOwnProperty(f) && f.match(/FlowOptions$/)) {
                    this.types.push(f.replace(/FlowOptions$/, ''));
                }
            }
            this.typesLen = this.types.length;
        },
        reloadEvents: function () {
            var $fc = this;
            this.getNavItem('slidesNext').unbind('.flexiCarousel').on(this.clickEvent + '.flexiCarousel', function (e) {
                e.preventDefault();
                $fc.showFrame('next');
            });
            this.getNavItem('slidesPrevious').unbind('.flexiCarousel').on(this.clickEvent + '.flexiCarousel', function (e) {
                e.preventDefault();
                $fc.showFrame('previous');
            });
            this.getNavItem('thumbnails').unbind('.flexiCarousel').on(this.clickEvent + '.flexiCarousel', '.' + this.settings.elem.thumbnail, function (e) {
                var $this = $(this);
                e.preventDefault();
                $fc.showFrame($this.closest('.' + $fc.settings.elem.thumbnails).find('.' + $fc.settings.elem.thumbnail).index($this));
            });
        },
        reloadTimer: function () {
            var $fc = this;
            if (this.settings.interval) {
                if (this.timer !== false) {
                    clearInterval(this.timer);
                }
                this.timer = setInterval(function () {
                    $fc.showFrame('next');
                }, this.settings.interval);
            }
        },

        fireCallback: function (name) {
            var params = Array.prototype.slice.call(arguments, 1),
                successful = {
                    sourceSuccessful: true
                },
                pluginObject,
                t;
            for (t = 0; t < this.typesLen; t += 1) {
                if (!successful[this.types[t] + 'Successful']) {
                    successful[this.types[t] + 'Successful'] = false;
                }
                pluginObject = FlexiCarousel.DEFAULTS[this.types[t] + 'Flows'][this.settings[this.types[t] + 'Flow']];
                if (pluginObject && pluginObject[name]) {
                    pluginObject.carousel = this;
                    pluginObject[name].apply(pluginObject, params);
                    successful[this.types[t] + 'Successful'] = true;
                }
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
                if (!successful.slidesSuccessful) {
                    this.switchSlide(frameIndex);
                }
                if (!successful.thumbnailsSuccessful) {
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
        },

        reload: function (full) {
            full = full === undefined ? false : full;
            if (full) {
                this.currentIndex = this.settings.startIndex;
                this.getAllThumbnails().removeClass(this.settings.elem.thumbnailCurrent);
                this.switchFrame();
            }
            this.reloadEvents();
            this.reloadTimer();

        }

    };

    FlexiCarousel.DEFAULTS = {
        startIndex: 0,
        sourceFlow: 'default',
        slidesFlow: 'none',
        thumbnailsFlow: 'none',
        loop: true,
        interval: false,
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