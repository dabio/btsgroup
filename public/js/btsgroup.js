var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-67221-5']);
_gaq.push(['_trackPageview']);

(function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

/iPhone/i.test(navigator.userAgent) && !pageYOffset && !location.hash && setTimeout(function(){window.scrollTo(0, 1);}, 100);


$(function() {
    $('#settings_button').click(
        function () {
            $('#settings').animate({opacity: "toggle"}, 100);
        }
    );
    setTimeout(
        function() {
            $('#flash').fadeTo(false, 0).slideUp();
        }
    , 3000);
});

