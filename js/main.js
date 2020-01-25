new WOW().init();
var mySwiper = new Swiper('.swiper-container', {
    speed: 600,
    spaceBetween: 100,
    pagination: {
    el: '.project-pagination',
    type: 'bullets',
    clickable: true,
},
	autoplay: {
	delay: 5000,
   },
});
