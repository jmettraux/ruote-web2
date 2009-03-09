
//
// $(whatever) style
//
function byId (i) { return document.getElementById(i); } 
  // I know, but let's get js framework independent

//
// links to a CSS file (in the document <HEAD/>)
//
function linkToCss (href) {

  var e = document.createElement('link');
  e.setAttribute('href', '/stylesheets/' + href + '.css');
  e.setAttribute('media', 'screen');
  e.setAttribute('rel', 'stylesheet');
  e.setAttribute('type', 'text/css');
  var h = document.getElementsByTagName('head')[0];

  h.appendChild(e);

  h.insertBefore(e, h.firstChild);
    // making sure that controller-related css are placed last
}

//
// when 'enter' is hit, will call 'func'
//
function onEnter (field, evt, func) {
  var e = evt || window.event;
  var c = e.charCode || e.keyCode;
  if (c == 13) func();
  return false;
}
