(function($) {

    var slidesDissolve = {
        type: 'slidesFlow',
        name: 'dissolve',
        settings: {
            switchDuration: 500
        },
        beforeInit: function() {
            this.getAllSlides().hide();
        },
        showFrame: function(frameIndex) {
            var options = this.getFlowOptions('slides');
            this.getSlide(this.currentIndex).fadeOut(options.switchDuration);
            this.getSlide(frameIndex).fadeIn(options.switchDuration);
        }
    };

    $.fn.flexiCarousel('registerFlow', slidesDissolve);

}(jQuery));