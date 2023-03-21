// Бургер-меню (начало)
document.querySelector('.burger').addEventListener('click', function () {
				this.classList.toggle('active');
				document.querySelector('.nav').classList.toggle('open');
			})
// Бургер-меню (окончание)

// Кнопка вверх страницы (начало)
const btnUp = {
  el: document.querySelector('.btn-up'),
  show() {
    // удалим у кнопки класс btn-up_hide
    this.el.classList.remove('btn-up_hide');
  },
  hide() {
    // добавим к кнопке класс btn-up_hide
    this.el.classList.add('btn-up_hide');
  },
  addEventListener() {
    // при прокрутке содержимого страницы
    window.addEventListener('scroll', () => {
      // определяем величину прокрутки
      const scrollY = window.scrollY || document.documentElement.scrollTop;
      // если страница прокручена больше чем на 400px, то делаем кнопку видимой, иначе скрываем
      scrollY > 400 ? this.show() : this.hide();
    });
    // при нажатии на кнопку .btn-up
    document.querySelector('.btn-up').onclick = () => {
      // переместим в начало страницы
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: 'smooth'
      });
    }
  }
}

btnUp.addEventListener();
// Кнопка вверх страницы (окончание)

// Полоса Timeline (начало)
(function ($) {
  $(function () {


    $(window).on('scroll', function () {
      fnOnScroll();
    });

    $(window).on('resize', function () {
      fnOnResize();
    });


    var agTimeline = $('.js-timeline'),
      agTimelineLine = $('.js-timeline_line'),
      agTimelineLineProgress = $('.js-timeline_line-progress'),
      agTimelinePoint = $('.js-timeline-card_point-box'),
      agTimelineItem = $('.js-timeline_item'),
      agOuterHeight = $(window).outerHeight(),
      agHeight = $(window).height(),
      f = -1,
      agFlag = false;

    function fnOnScroll() {
      agPosY = $(window).scrollTop();

      fnUpdateFrame();
    }

    function fnOnResize() {
      agPosY = $(window).scrollTop();
      agHeight = $(window).height();

      fnUpdateFrame();
    }

    function fnUpdateWindow() {
      agFlag = false;

      agTimelineLine.css({
        top: agTimelineItem.first().find(agTimelinePoint).offset().top - agTimelineItem.first().offset().top,
        bottom: agTimeline.offset().top + agTimeline.outerHeight() - agTimelineItem.last().find(agTimelinePoint).offset().top
      });

      f !== agPosY && (f = agPosY, agHeight, fnUpdateProgress());
    }

    function fnUpdateProgress() {
      var agTop = agTimelineItem.last().find(agTimelinePoint).offset().top;

      i = agTop + agPosY - $(window).scrollTop();
      a = agTimelineLineProgress.offset().top + agPosY - $(window).scrollTop();
      n = agPosY - a + agOuterHeight / 2;
      i <= agPosY + agOuterHeight / 2 && (n = i - a);
      agTimelineLineProgress.css({height: n + "px"});

      agTimelineItem.each(function () {
        var agTop = $(this).find(agTimelinePoint).offset().top;

        (agTop + agPosY - $(window).scrollTop()) < agPosY + .5 * agOuterHeight ? $(this).addClass('js-ag-active') : $(this).removeClass('js-ag-active');
      })
    }

    function fnUpdateFrame() {
      agFlag || requestAnimationFrame(fnUpdateWindow);
      agFlag = true;
    }


  });
})(jQuery);
// Полоса Timeline (окончание)






var total_pics_num = 4; // колличество изображений
  var interval = 5000; // задержка между изображениями
  var time_out = 1; // задержка смены изображений
  var i = 0;
  var timeout;
  var opacity = 100;
  function fade_to_next() {
    opacity--;
    var k = i + 1;
    var image_now = 'image_' + i;
    if (i == total_pics_num) k = 1;
    var image_next = 'image_' + k;
    document.getElementById(image_now).style.opacity = opacity/100;
    document.getElementById(image_now).style.filter = 'alpha(opacity='+ opacity +')';
    document.getElementById(image_next).style.opacity = (100-opacity)/100;
    document.getElementById(image_next).style.filter = 'alpha(opacity='+ (100-opacity) +')';
    timeout = setTimeout("fade_to_next()",time_out);
    if (opacity==1) {
      opacity = 100;
      clearTimeout(timeout);
    }
  }
  setInterval (
    function() {
      i++;
      if (i > total_pics_num) i=1;
      fade_to_next();
    }, interval
  );