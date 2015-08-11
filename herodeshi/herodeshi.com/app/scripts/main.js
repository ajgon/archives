/* jshint devel:true */
(function ($) {
  'use strict';

  var HERODESHI = {
    mobileMenuClone: $('#menu').clone().attr('id', 'navigation-mobile').attr('class', 'navigation-mobile'),
    mobileNav: function mobileNav() {
      var windowWidth = $(window).width();
      var $mobileNav = $('#mobile-nav');

      if (windowWidth <= 979) {
        if ($mobileNav.length > 0) {
          console.log(this.mobileMenuClone);
          this.mobileMenuClone.insertAfter('#menu');
          this.mobileMenuClone.find('#menu-nav').attr('id', 'menu-nav-mobile').addClass('menu-nav-mobile');
        }
      } else {
        $('#navigation-mobile').css('display', 'none');
        if ($mobileNav.hasClass('open')) {
          $mobileNav.removeClass('open');
        }
      }
    },
    menuListener: function menuListener() {
      var $mobileNav = $('#mobile-nav');

      $mobileNav.on('click', function (e) {
        $(this).toggleClass('open');

        if ($mobileNav.hasClass('open')) {
          console.log($('#navigation-mobile').slideDown);
          $('#navigation-mobile').slideDown(500);
        } else {
          $('#navigation-mobile').slideUp(500);
        }
        e.preventDefault();
      });

      $('#menu-nav-mobile a').on('click', function () {
        $mobileNav.removeClass('open');
        $('#navigation-mobile').slideUp(350);
      });
    },
    tabListener: function tabListener() {
      $(document).on('click', '[data-toggle="tab"]', function (e) {
        e.preventDefault();
        var $this = $(this);
        var $tabs = $this.closest('.nav-tabs').find('[data-toggle="tab"]');
        var $panes = $($tabs.map(function () {
          return $($(this).attr('href'))[0];
        }));
        $tabs.parent().removeClass('active');
        $this.parent().addClass('active');
        $panes.removeClass('in');
        setTimeout(function () {
          $panes.removeClass('active');
          $($this.attr('href')).addClass('in').addClass('active').addClass('in');
        }, 150);

      });
    },
    init: function init() {
      this.mobileNav();
      this.menuListener();
      this.tabListener();
    }
  };

  $(document).ready(function () {
    HERODESHI.init();
  });

  $(window).resize(function () {
    HERODESHI.mobileNav();
  });
}(jQuery));
