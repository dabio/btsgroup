// hide url in webkit/iphone
/iPhone/i.test(navigator.userAgent) && !pageYOffset && !location.hash && setTimeout(function(){window.scrollTo(0, 1);}, 100);

// Enable HTML 5 elements for styling in IE. 
if (window.attachEvent && (function(){var elem=doc.createElement("div");elem.innerHTML="<elem></elem>";return elem.childNodes.length !== 1; })()) {
(function(f,l){var j="abbr|article|aside|audio|canvas|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",n=j.split("|"),k=n.length,g=new RegExp("<(/*)("+j+")","gi"),h=new RegExp("\\b("+j+")\\b(?!.*[;}])","gi"),m=l.createDocumentFragment(),d=l.documentElement,i=d.firstChild,b=l.createElement("style"),e=l.createElement("body");b.media="all";function c(p){var o=-1;while(++o<k){p.createElement(n[o])}}c(l);c(m);function a(t,s){var r=t.length,q=-1,o,p=[];while(++q<r){o=t[q];s=o.media||s;p.push(a(o.imports,s));p.push(o.cssText)}return p.join("")}f.attachEvent("onbeforeprint",function(){var r=-1;while(++r<k){var o=l.getElementsByTagName(n[r]),q=o.length,p=-1;while(++p<q){if(o[p].className.indexOf("iepp_")<0){o[p].className+=" iepp_"+n[r]}}}i.insertBefore(b,i.firstChild);b.styleSheet.cssText=a(l.styleSheets,"all").replace(h,".iepp_$1");m.appendChild(l.body);d.appendChild(e);e.innerHTML=m.firstChild.innerHTML.replace(g,"<$1bdo")});f.attachEvent("onafterprint",function(){e.innerHTML="";d.removeChild(e);i.removeChild(b);d.appendChild(m.firstChild)})})(this,document);
}

// toggle settings
$('#settings_button').live('click',function(){$('#settings').animate({opacity:'toggle'},100)});
// hide #flash information
setTimeout(function(){$('#flash').fadeTo(false,0).slideUp();},3000);
// disable buttons if once clicked
$('form').live('submit', function(){$('button').attr('disabled', 'disabled')});


// Google Analytics
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-67221-5']);
_gaq.push(['_trackPageview']);
(function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
