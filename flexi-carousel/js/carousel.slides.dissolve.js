/*global jQuery */
/*properties
 beforeInit, carousel, currentIndex, fadeIn, fadeOut, flexiCarousel, fn,
 getAllSlides, getFlowOptions, getSlide, hide, name, settings, showFrame,
 switchDuration, type
 */

(function ($) {

    "use strict";

    var slidesDissolve = {
        type: 'slidesFlow',
        name: 'dissolve',
        settings: {
            switchDuration: 500
        },
        beforeInit: function () {
            this.carousel.getAllSlides().hide();
        },
        showFrame: function (frameIndex) {
            var options = this.carousel.getFlowOptions('slides');
            this.carousel.getSlide(this.currentIndex).fadeOut(options.switchDuration);
            this.carousel.getSlide(frameIndex).fadeIn(options.switchDuration);
        }
    };

    $.fn.flexiCarousel('registerFlow', slidesDissolve);

}(jQuery));