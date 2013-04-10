/*global jQuery */
/*jslint nomen: true */
/*properties
    _currentPage, animate, carousel, ceil, flexiCarousel, fn, getFlowOptions,
    getNavItem, getSlidesCount, height, name, settings,
    showFrameFromThumbnailsNext, showFrameFromThumbnailsPrevious, slideDuration,
    thumbsPerPage, top, type
*/

(function ($) {

    "use strict";

    var thumbnailsSlide = {
        type: 'thumbnailsFlow',
        name: 'slide',
        settings: {
            slideDuration: 500,
            thumbsPerPage: 1
        },
        _currentPage: 0,
        showFrameFromThumbnailsNext: function () {
            var options = this.carousel.getFlowOptions('thumbnails');
            if (this._currentPage < Math.ceil(this.carousel.getSlidesCount() / options.thumbsPerPage) - 1) {
                this.carousel.getNavItem('thumbnails').animate({
                    top: '-=' + this.carousel.getNavItem('thumbnailsContainer').height()
                }, options.slideDuration);
                this._currentPage += 1;
            }
        },
        showFrameFromThumbnailsPrevious: function () {
            var options = this.carousel.getFlowOptions('thumbnails');
            if (this._currentPage > 0) {
                this.carousel.getNavItem('thumbnails').animate({
                    top: '+=' + this.carousel.getNavItem('thumbnailsContainer').height()
                }, options.slideDuration);
                this._currentPage -= 1;
            }
        }
    };

    $.fn.flexiCarousel('registerFlow', thumbnailsSlide);

}(jQuery));