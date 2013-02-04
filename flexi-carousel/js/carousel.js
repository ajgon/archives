(function($) {
    var FlexiCarousel = function(items, options) {
        this.settings = $.extend(FlexiCarousel.DEFAULTS, options);
        this.settings.slidesFlowOptions = $.extend(this.settings.slidesFlows[this.settings.slideFlow].settings, options.slidesFlowOptions);
        this.items = items;
        this.clickEvent = 'click';

        this.fireCallback('beforeInit');

        this.currentIndex = this.settings.startIndex;
        this.getAllThumbnails().removeClass(this.settings.elem.thumbnailCurrent);
        this.switchFrame();
        this.initEvents();

        this.fireCallback('afterInit');

    };

    FlexiCarousel.prototype = {
        initEvents: function() {
            var $fc = this;
            this.getNavItem('slidesNext').on(this.clickEvent, function(e) {
                e.preventDefault();
                $fc.showFrame('next');
            });
            this.getNavItem('slidesPrevious').on(this.clickEvent, function(e) {
                e.preventDefault();
                $fc.showFrame('previous');
            });
            this.getNavItem('thumbnail').on(this.clickEvent, function(e) {
                var $this = $(this);
                e.preventDefault();
                $fc.showFrame($this.closest('.' + $fc.settings.elem.thumbnails).find('.' + $fc.settings.elem.thumbnail).index($this));
            });
        },

        fireCallback: function() {
            var name = arguments[0],
                params = Array.prototype.slice.call(arguments, 1),
                successful = {
                successfulSlide: false,
                successfulThumbnail: false
            };
            if(FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slideFlow] && FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slideFlow][name]) {
                FlexiCarousel.DEFAULTS.slidesFlows[this.settings.slideFlow][name].apply(this, params);
                successful.successfulSlide = true;
            }
            if(FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailFlow] && FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailFlow][name]) {
                FlexiCarousel.DEFAULTS.thumbnailsFlows[this.settings.thumbnailFlow][name].apply(this, params);
                successful.successfulThumbnail = true;
            }
            return successful;
        },
        determineFrameIndex: function(frameIndicator) {
            var slidesSize = this.getAllSlides().size(),
                frameIndex = this.currentIndex;
            switch(frameIndicator) {
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
            if(frameIndex < 0) {
                frameIndex = this.settings.loop ? slidesSize - 1 : 0;
            }
            if(frameIndex > slidesSize - 1) {
                frameIndex = this.settings.loop ? 0 : slidesSize - 1;
            }
            return frameIndex;
        },

        switchSlide: function(slideIndex) {
            this.getAllSlides().hide();
            this.getSlide(slideIndex).show();
        },
        switchThumbnail: function(thumbnailIndex) {
            this.getAllThumbnails().removeClass(this.settings.elem.thumbnailCurrent);
            this.getThumbnail(thumbnailIndex).addClass(this.settings.elem.thumbnailCurrent);
        },
        switchFrame: function(frameIndicator) {
            frameIndex = this.determineFrameIndex(frameIndicator);
            this.switchSlide(frameIndex);
            this.switchThumbnail(frameIndex);
        },

        showFrame: function(frameIndicator) {
            var successful,
                frameIndex = this.determineFrameIndex(frameIndicator);
            if(frameIndex != this.currentIndex) {
                successful = this.fireCallback('showFrame', frameIndex);
                if(!successful.successfulSlide) {
                    this.switchSlide(frameIndex);
                }
                if(!successful.successfulThumbnail) {
                    this.switchThumbnail(frameIndex);
                }
                this.currentIndex = frameIndex;
            }
        },

        getAllSlides: function() {
            return this.items.find('.' + this.settings.elem.slides + ' > .' + this.settings.elem.slide);
        },
        getSlide: function(slideIndex) {
            slideIndex = slideIndex === undefined ? this.currentIndex : slideIndex;
            return this.getAllSlides().filter(':eq(' + slideIndex + ')');
        },
        getAllThumbnails: function() {
            return this.items.find('.' + this.settings.elem.thumbnails + ' > .' + this.settings.elem.thumbnail);
        },
        getThumbnail: function(thumbnailIndex) {
            thumbnailIndex = thumbnailIndex === undefined ? this.currentIndex : thumbnailIndex;
            return this.getAllThumbnails().filter(':eq(' + thumbnailIndex + ')');
        },
        getNavItem: function(name) {
            return this.items.find('.' + this.settings.elem[name]);
        },
        getFlowOptions: function(flowName) {
            // FIXME determine slides/thumbnail flow in a better way
            return this.settings[flowName + 'FlowOptions'];
        }

    };

    FlexiCarousel.DEFAULTS = {
        startIndex: 0,
        slideFlow: 'none',
        thumbnailFlow: 'none',
        loop: true,
        slidesFlowOptions: {},
        thumbnailsFlowOptions: {},
        slidesFlows: {},
        thumbnailsFlows: {},
        elem: {
            slidesContainer: 'flexicarousel-slides-container',
            slides: 'flexicarousel-slides',
            slide: 'flexicarousel-slide',
            slidesPrevious: 'flexicarousel-slides-previous',
            slidesNext: 'flexicarousel-slides-next',
            thumbnailsContainer: 'flexicarousel-thumbnails-container',
            thumbnails: 'flexicarousel-thumbnails',
            thumbnail: 'flexicarousel-thumbnail',
            thumbnailsPrevious: 'flexicarousel-thumbnails-previous',
            thumbnailsNext: 'flexicarousel-thumbnails-next',
            thumbnailCurrent: 'flexicarousel-thumbnail-current'
        }
    };

    window.FlexiCarousel = FlexiCarousel; // FIXME: DEBUG


    $.fn.flexiCarousel = function( method ) {
        var methods = {
            init: function(options) {
                return this.each(function() {
                    var $this = $(this),
                        flexiCarousel = new FlexiCarousel($this, options);

                    $this.data('flexiCarousel', flexiCarousel);
                });
            },
            registerFlow: function(flow) {
                flow.type = flow.type === 'thumbnailsFlow' ? 'thumbnailsFlows' : 'slidesFlows';
                FlexiCarousel.DEFAULTS[flow.type][flow.name] = flow;
            }
        };

        if ( methods[method] ) {
            return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on jQuery.flexiCarousel' );
        }

    };
})(jQuery);