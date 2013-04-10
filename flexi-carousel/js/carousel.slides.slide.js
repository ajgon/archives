/*global jQuery */
/*jslint nomen: true, browser: true */
/*properties
    _calculateWay, _recalculateWidth, _truncateSlides, abs, afterInit,
    allSlides, animate, attr, carousel, ceil, clone, css, currentIndex, data,
    each, filter, find, flexiCarousel, floor, fn, getAllSlides, getFlowOptions,
    getNavItem, getSlidesCount, left, loop, name, not, outerWidth, remove,
    settings, show, showFrame, size, slice, slidesAmount, switchDuration,
    toString, type, width
*/


(function ($) {

    "use strict";

    var slidesSlide = {
        type: 'slidesFlow',
        name: 'slide',
        settings: {
            switchDuration: 500,
            slidesAmount: 1,
            loop: 'rewind' // rewind|infinity
        },
        afterInit: function () {
            var slides = this.carousel.getNavItem('slides'),
                options = this.carousel.getFlowOptions('slides');

            this.allSlides = this.carousel.getAllSlides().show();
            this.allSlides.each(function() {
                $(this).attr('data-width', $(this).outerWidth(true));
            });
            if (options.loop === 'infinity') {
                slides.find('li:gt(' + (options.slidesAmount - 1) + ')').remove();
            }

            this._truncateSlides(-1);
            this._recalculateWidth();
        },
        showFrame: function (frameIndex, originalCalee) {
            var self = this,
                options = this.carousel.getFlowOptions('slides'),
                way,
                s,
                c,
                slides = this.carousel.getNavItem('slides'),
                carousel = this.carousel,
                sign = (originalCalee === 'slidesNext' || (originalCalee === 'thumbnails' && frameIndex > carousel.currentIndex)) ? 1 : -1,
                slidesCount = this.carousel.getSlidesCount(),
                amountOfSlidesToPassThrough,
                targetSlide;


            targetSlide = (originalCalee === 'thumbnails' ? (Math.floor(frameIndex / options.slidesAmount) * options.slidesAmount) : carousel.currentIndex + options.slidesAmount * sign);
            if (options.loop !== 'infinity') {
                if (targetSlide >= slidesCount) {
                    targetSlide = 0;
                    sign = -1;
                }
                if (targetSlide < 0) {
                    targetSlide = Math.ceil(slidesCount / options.slidesAmount) * options.slidesAmount - options.slidesAmount;
                    sign = 1;
                }
            }
            amountOfSlidesToPassThrough = Math.abs(targetSlide - carousel.currentIndex);
            if (targetSlide >= slidesCount) {
                targetSlide -= slidesCount;
                amountOfSlidesToPassThrough = options.slidesAmount;
            }
            if (targetSlide < 0) {
                targetSlide += slidesCount;
                amountOfSlidesToPassThrough = options.slidesAmount;
            }
            c = sign === 1 ? (carousel.currentIndex + 1 >= slidesCount ? targetSlide : carousel.currentIndex + 1) : (carousel.currentIndex - 1 < 0 ? carousel.currentIndex - 1 + slidesCount : carousel.currentIndex - 1);
            for (s = 0; s < amountOfSlidesToPassThrough; s += 1) {
                slides[(sign === 1 ? 'append' : 'prepend')](this.allSlides.filter(':eq(' + c + ')').clone());
                if (sign === 1) {
                    c = c >= slidesCount - 1 ? 0 : c + 1;
                } else {
                    c = c <= 0 ? slidesCount - 1 : c - 1;
                }

            }
            if (sign === -1) {
                slides.css('left', this._calculateWay(carousel.currentIndex, targetSlide, sign).toString() + 'px');
            }
            this._recalculateWidth();

            way = this._calculateWay(carousel.currentIndex, targetSlide, sign);
            setTimeout(function() {
                carousel.currentIndex = targetSlide;
            }, 200);

            this.carousel.getNavItem('slides').animate({left: '-=' + way.toString()}, options.switchDuration, function() {
                self._truncateSlides(sign);
            });
        },
        _truncateSlides: function(sign) {
            var slides = this.carousel.getNavItem('slides'),
                options = this.carousel.getFlowOptions('slides');

            if (sign === 1) {
                slides.css('left', '0px').find('li').not(slides.find('li').slice(-options.slidesAmount)).remove();
            } else {
                slides.find('li:gt(' + (options.slidesAmount - 1).toString() + ')').remove();
            }
        },
        _recalculateWidth: function() {
            var slides = this.carousel.getNavItem('slides');
            slides.width(slides.find('li').outerWidth(true) * slides.find('li').size());
        },
        _calculateWay: function(startSlide, endSlide, direction) {
            var way = 0, s, c,
                slidesCount = this.carousel.getSlidesCount(),
                amount;
            if (direction === 1) {
                amount = endSlide >= startSlide ? (endSlide - startSlide) : (slidesCount - startSlide + endSlide);
            } else {
                amount = endSlide <= startSlide ? (startSlide - endSlide) : startSlide + slidesCount - endSlide;
            }
            c = startSlide;
            for (s = 0; s < amount; s += 1) {
                way += this.allSlides.filter(':eq(' + c + ')').data('width') * direction;
                if (direction === 1) {
                    c = c >= slidesCount - 1 ? 0 : c + 1;
                } else {
                    c = c <= 0 ? slidesCount - 1 : c - 1;
                }

            }
            return way;
        }
    };

    $.fn.flexiCarousel('registerFlow', slidesSlide);

}(jQuery));