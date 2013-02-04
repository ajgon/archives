/*global jQuery */
/*properties
 beforeInit, currentIndex, fadeIn, fadeOut, flexiCarousel, fn, getAllSlides,
 getFlowOptions, getSlide, hide, name, settings, showFrame, switchDuration,
 type
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
            this.getAllSlides().hide();
        },
        showFrame: function (frameIndex) {
            var options = this.getFlowOptions('slides');
            this.getSlide(this.currentIndex).fadeOut(options.switchDuration);
            this.getSlide(frameIndex).fadeIn(options.switchDuration);
        }
    };

    $.fn.flexiCarousel('registerFlow', slidesDissolve);

}(jQuery));