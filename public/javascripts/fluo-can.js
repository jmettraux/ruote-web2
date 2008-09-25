
/*
 *  OpenWFEru - open source ruby workflow and bpm engine
 *  (c) 2007-2008 OpenWFE.org
 *
 *  OpenWFEru is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 *
 *  John Mettraux
 *  Juan-Pedro Paredes
 */

//function dinspect (o) {
//  var s = "[\n";
//  for (var k in o) {
//    s += ("" + k + ": " + o[k]);
//    s += ",\n";
//  }
//  s += "]";
//  return s;
//}

var FluoCanvas = function() {
  
  //
  // draws centered text
  //
  function drawText (c, text, bwidth, bheight) {

    c.save();
    if (c.canvas.horizontal == true) {
      c.translate(bwidth/2, bheight/2);
      c.rotate(Math.PI/2);
    }
    var width = c.mozMeasureText(text);
    c.translate(-(width/2), 17);
    c.mozDrawText(text);
    c.translate(+(width/2), -17);
    c.restore();
  }

  function drawArrow (c, length) {
    var w = 3;
    c.beginPath();
    c.moveTo(0, 0);
    c.lineTo(0, length);
    c.stroke();
    c.beginPath();
    c.moveTo(0, length);
    c.lineTo(-w, length-w*2);
    c.lineTo(w, length-w*2);
    c.lineTo(0, length);
    c.fill();
  }

  function drawVerticalLine (c, x, height) {
    c.beginPath();
    c.moveTo(x, 0);
    c.lineTo(x, height);
    c.stroke();
  }

  function drawRoundedRect (c, width, height, radius) {
    var w2 = width / 2;
    c.beginPath();
    c.moveTo(0, 0);
    c.lineTo(w2 - radius, 0);
    c.quadraticCurveTo(w2, 0, w2, radius);
    c.lineTo(w2, height - radius);
    c.quadraticCurveTo(w2, height, w2 - radius, height);
    c.lineTo(-w2 + radius, height);
    c.quadraticCurveTo(-w2, height, -w2, height - radius);
    c.lineTo(-w2, radius);
    c.quadraticCurveTo(-w2, 0, -w2 + radius, 0);
    c.lineTo(0, 0);
    c.stroke();
  }

  function drawQuadraticPath (c, x, y, radius) {
    var xradius = radius;
    if (x < 0) xradius = -radius;
    var yradius = radius;
    if (y < 0) yradius = -radius;
    c.beginPath();
    c.moveTo(0, 0);
    c.lineTo(x - xradius, 0);
    c.quadraticCurveTo(x, 0, x, yradius);
    c.lineTo(x, y);
    c.stroke();
  }

  function drawDiamond (c, height) {
    var h = height / 2;
    for (var i = 0; i < 2; i++) {
      c.beginPath();
      c.moveTo(0, 0);
      c.lineTo(h, h);
      c.lineTo(0, height);
      c.lineTo(-h, h);
      c.lineTo(0, 0);
      if (i == 0) {
        c.save();
        c.fillStyle = 'rgb(255, 255, 255)';
        c.fill();
        c.restore();
      }
      else {
        c.stroke();
      }
    }
  }

  function drawParaDiamond (c, height) {
    drawDiamond(c, height);
    c.save();
    c.lineWidth = 2.5;
    var l = height / 4;
    c.beginPath();
    c.moveTo(0, l); c.lineTo(0, l * 3);
    c.stroke();
    c.beginPath();
    c.moveTo(-l, l * 2); c.lineTo(l, l * 2);
    c.stroke();
    c.restore();
  }

  return {
    drawText: drawText,
    drawArrow: drawArrow,
    drawVerticalLine: drawVerticalLine,
    drawRoundedRect: drawRoundedRect,
    drawQuadraticPath: drawQuadraticPath,
    drawDiamond: drawDiamond,
    drawParaDiamond: drawParaDiamond
  };
}();

var FluoCan = function() {

  //
  // MISC METHODS

  function childrenMax (c, exp, funcname) {
    var children = getChildren(c, exp);
    var max = 0;
    for (var i = 0; i < children.length; i++) {
      var val = FluoCan[funcname](c, children[i]);
      if (val > max) max = val;
    }
    return max;
  }

  function childrenSum (c, exp, funcname) {
    var children = getChildren(c, exp);
    var sum = 0;
    for (var i = 0; i < children.length; i++) {
      sum += FluoCan[funcname](c, children[i]);
    }
    return sum;
  }

  function attributeMaxWidth (c, exp, title) {
    var max = 0;
    if (title) max = c.mozMeasureText(title);
    for (var attname in exp[1]) {
      var text = ""+attname+": "+fluoToJson(exp[1][attname], false);
      var l = c.mozMeasureText(text);
      if (l > max) max = l;
    }
    return max;
  }

  //
  // returns the list of attribute names (sorted)
  //
  function attributeNames (exp) {
    var an = [];
    for (attname in exp[1]) an.push(attname);
    return an.sort();
  }

  function attributeCount (exp) {
    var count = 0;
    for (var k in exp[1]) { count++; }
    return count;
  }

  function drawAttributes (c, exp, expname, width, height) {
    if (expname) {
      FluoCanvas.drawText(c, exp[0], width, height);
      if (c.canvas.horizontal == true) c.translate(-20, 0);
      else c.translate(0, 20);
    }
    //for (var attname in exp[1]) {
    var attname;
    var attnames = attributeNames(exp);
    while (attname = attnames.shift()) {
      FluoCanvas.drawText(
        c, attname + ": " + fluoToJson(exp[1][attname], false), width, height);
      if (c.canvas.horizontal == true) c.translate(-20, 0);
      else c.translate(0, 20);
    }
  }

  //
  // the methods (and fields) shared by all handler are here
  //
  var Handler = {};
  Handler.getHeight = function (c, exp) {
    if (c.canvas.horizontal == true) return this.getRealWidth(c, exp);
    return this.getRealHeight(c, exp);
  };
  Handler.getWidth = function (c, exp) {
    if (c.canvas.horizontal == true) return this.getRealHeight(c, exp);
    return this.getRealWidth(c, exp);
  };

  //
  // creates a new Handler (a copy of Handler), if the parentHandler is
  // given, will spawn a copy of it instead of a copy of Handler.
  // (dead simple inheritance).
  //
  function newHandler (parentHandler) {
    if ( ! parentHandler) parentHandler = Handler;
    var result = {};
    for (var k in parentHandler) result[k] = parentHandler[k];
    return result;
  }

  function getChildren (c, exp) {
    var cs = exp[2];
    if ( ! c.canvas.hideMinor) return cs;
    if (exp.majorChildren) return exp.majorChildren;
    var r = [];
    for (var i = 0; i < cs.length; i++) {
      var c = cs[i];
      if (MINORS.indexOf(c[0]) < 0) r.push(c);
    }
    exp.majorChildren = r; // caching the result
    return r;
  }

  //
  // EXPRESSION HANDLERS

  var GenericHandler = newHandler();
  GenericHandler.adjust = function (exp) {
    if (exp[2].length == 1 && ((typeof exp[2][0]) == 'string')) {
      exp[0] = exp[0] + ' ' + exp[2][0];
    }
  }
  GenericHandler.render = function (c, exp) {
    var width = this.getWidth(c, exp);
    var height = this.getHeight(c, exp);
    FluoCanvas.drawRoundedRect(c, width, height, 8);
    c.save();
    drawAttributes(c, exp, true, width, height);
    c.restore();
  };
  GenericHandler.getRealHeight = function (c, exp) {
    return 7 + (1 + attributeCount(exp)) * 20;
  };
  GenericHandler.getRealWidth = function (c, exp) {
    return 10 + attributeMaxWidth(c, exp, exp[0]);
  };

  var SubprocessHandler = newHandler(GenericHandler);
  SubprocessHandler.adjust = function (exp) {
    if (exp[2].length == 1) exp[1]['ref'] = exp[2][0];
  }
  SubprocessHandler.render = function (c, exp) {

    var width = this.getWidth(c, exp);
    var height = this.getHeight(c, exp);
    FluoCanvas.drawRoundedRect(c, width, height, 8);
    c.save();
    drawAttributes(c, exp, true, width, height);
    c.restore();

    c.save(); // drawing a cross in a box
    c.beginPath();
    c.moveTo(-6, height);
    c.lineTo(-6, height - 12);
    c.lineTo(6, height - 12);
    c.lineTo(6, height);
    c.stroke();
    c.beginPath();
    c.moveTo(0, height - 10);
    c.lineTo(0, height - 2);
    c.stroke();
    c.beginPath();
    c.moveTo(-4, height - 6);
    c.lineTo(4, height - 6);
    c.stroke();
    c.restore();
  };
  SubprocessHandler.getRealHeight = function (c, exp) {
    return 12 + 7 + (1 + attributeCount(exp)) * 20;
  };

  // TODO : fix rotated mode
  //
  var GenericWithChildrenHandler = newHandler();
  GenericWithChildrenHandler.render = function (c, exp) {
    var width = this.getWidth(c, exp);
    var height = this.getHeight(c, exp);
    var attWidth = attributeMaxWidth(c, exp, exp[0]) + 7;
    var attHeight = attributeCount(exp) * 20;
    var children = getChildren(c, exp);
    if (c.canvas.horizontal == true) {
      var w = attWidth;
      attWidth = attHeight;
      attHeight = w;
    }
    FluoCanvas.drawRoundedRect(c, width, height, 8);
    c.save();
    c.translate(-width/2 + attWidth/2 + 5 , 7);
    if (c.canvas.horizontal == true) c.translate(attHeight/2, 0);
    drawAttributes(c, exp, true, attWidth, attHeight);
    c.restore();
    c.save();
    c.translate(width/2 - childrenMax(c, exp, 'getWidth')/2 - 7, 8);
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      renderExp(c, child);
      c.translate(0, 7 + FluoCan.getHeight(c, child));
    }
    c.restore();
  };
  GenericWithChildrenHandler.getHeight = function (c, exp) {
    var rightHeight = 
      (getChildren(c, exp).length + 1) * 7 + childrenSum(c, exp, 'getHeight');
    var leftHeight = 
      GenericHandler.getHeight(c, exp);
    return (rightHeight > leftHeight) ? rightHeight : leftHeight;
  };
  GenericWithChildrenHandler.getWidth = function (c, exp) {
    return(
      attributeMaxWidth(c, exp, exp[0]) + 
      28 + 
      childrenMax(c, exp, 'getWidth'));
  };

  var TextHandler = newHandler();
  TextHandler.render = function (c, exp) {
    var h = getHeight(c, exp);
    var w = getWidth(c, exp);
    FluoCanvas.drawText(c, this.getText(exp), h, w);
  };
  TextHandler.getText = function (exp) {
    var t = exp[0];
    for (var attname in exp[1]) {
      t += (' ' + attname + ': "' + exp[1][attname] + '"');
    }
    return t;
  };
  TextHandler.getRealHeight = function (c, exp) {
    return 20;
  };
  TextHandler.getRealWidth = function (c, exp) {
    return c.mozMeasureText(this.getText(exp));
  };

  var StringHandler = newHandler(TextHandler);
  StringHandler.getText = function (exp) {
    return exp;
  };

  var VerticalHandler = newHandler();
  VerticalHandler.render = function (c, exp) {
    c.save();
    var children = getChildren(c, exp);
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      renderExp(c, child);
      c.translate(0, FluoCan.getHeight(c, child));
      if (i < children.length - 1) {
        FluoCanvas.drawArrow(c, 14);
        c.translate(0, 14);
      }
    }
    c.restore();
  };
  VerticalHandler.getHeight = function (c, exp) {
    return (getChildren(c, exp).length - 1) * 14 + childrenSum(c, exp, 'getHeight');
  };
  VerticalHandler.getWidth = function (c, exp) {
    return childrenMax(c, exp, 'getWidth');
  };

  var HorizontalHandler = newHandler();
  HorizontalHandler.render = function (c, exp) {
    var children = getChildren(c, exp);
    var dist = this.computeDistribution(c, exp);
    var childrenHeight = this.getChildrenHeight(c, exp);
    this.renderHeader(c, exp, dist);
    c.save();
    c.translate(0, this.getHeaderHeight(c, exp));
    for (var i=0; i < children.length; i++) {
      var child = children[i];
      c.save();
      c.translate(dist[i], 0);
      this.renderChild(c, child, childrenHeight);
      c.restore();
    }
    c.restore();
    this.renderFooter(c, exp, dist, childrenHeight);
  };
  HorizontalHandler.getHeaderHeight = function (c, exp) {
    if (c.canvas.horizontal == true) return 23 + attributeMaxWidth(c, exp);
    return 23 + attributeCount(exp) * 20;
  };
  HorizontalHandler.getChildrenHeight = function (c, exp) {
    return childrenMax(c, exp, 'getHeight');
  };
  HorizontalHandler.getHeight = function (c, exp) {
    return this.getHeaderHeight(c, exp) + this.getChildrenHeight(c, exp) + 10;
  };
  HorizontalHandler.getWidth = function (c, exp) {
    return (getChildren(c, exp).length - 1) * 3 + childrenSum(c, exp, 'getWidth');
  };
  HorizontalHandler.computeDistribution = function (c, exp) {
    var children = getChildren(c, exp);
    var totalWidth = this.getWidth(c, exp);
    var offset = -totalWidth/2;
    var dist = new Array(children.length);
    for (var i = 0; i < children.length; i++) {
      var cWidth = FluoCan.getWidth(c, children[i]);
      dist[i] = offset + cWidth / 2;
      offset += (cWidth + 3);
    }
    return dist;
  };
  HorizontalHandler.renderHeader = function (c, exp, distribution) {
    var hheight = this.getHeaderHeight(c, exp) - 10;
    c.save();
    c.translate(0, 10);
    FluoCanvas.drawQuadraticPath(
      c, distribution[0], hheight, 8);
    FluoCanvas.drawQuadraticPath(
      c, distribution[distribution.length-1], hheight, 8);
    for (var i = 1; i < distribution.length - 1; i++) {
      FluoCanvas.drawVerticalLine(c, distribution[i], hheight);
    }
    c.restore();
    this.renderHeaderSymbol(c);
    this.renderHeaderLabel(c, exp);
  };
  HorizontalHandler.renderHeaderSymbol = function (c) {
    FluoCanvas.drawDiamond(c, 20);
  };
  HorizontalHandler.renderHeaderLabel = function (c, exp) {
    var width = attributeMaxWidth(c, exp);
    var height = attributeCount(exp) * 20;
    if (c.canvas.horizontal == true) {
      var w = width;
      width = height;
      height = w;
    }
    c.save();
    c.translate(0, 20);
    c.save(); 
    c.fillStyle = 'rgb(255, 255, 255)';
    c.fillRect(-width/2, 0, width, height);
    c.restore();
    drawAttributes(c, exp, false, width, height);
    c.restore();
  };
  HorizontalHandler.renderChild = function (c, exp, childrenHeight) {
    var cheight = FluoCan.getHeight(c, exp);
    renderExp(c, exp);
    c.beginPath();
    c.moveTo(0, cheight); c.lineTo(0, childrenHeight);
    c.stroke();
  };
  HorizontalHandler.renderFooter = function (c, exp, distribution) {
    var childrenHeight = this.getChildrenHeight(c, exp);
    c.save();
    c.translate(
      0, this.getHeaderHeight(c, exp) + this.getChildrenHeight(c, exp) + 10);
    if (distribution.length == 1) {
      FluoCanvas.drawVerticalLine(c, distribution[0], -10);
    }
    else {
      FluoCanvas.drawQuadraticPath(
        c, distribution[0], -10, 8);
      FluoCanvas.drawQuadraticPath(
        c, distribution[distribution.length-1], -10, 8);
      for (var i = 1; i < distribution.length - 1; i++) {
        FluoCanvas.drawVerticalLine(c, distribution[i], -10);
      }
    }
    c.restore();
  };
  HorizontalHandler.renderFooterDiamond = function (c) {
  };

  var ConcurrenceHandler = newHandler(HorizontalHandler);
  ConcurrenceHandler.renderHeaderSymbol = function (c) {
    FluoCanvas.drawParaDiamond(c, 20);
  };

  var IfHandler = newHandler(HorizontalHandler);
  IfHandler.adjust = function (exp) {
    //
    // all the crazy legwork to adapt to the 'if' expression
    //
    if ( ! (exp[1]['test'] || exp[1]['not'])) {
      // ok, steal first exp
      var cond = exp[2].shift();
      if (cond) {
        exp[1] = cond[1];
        exp[1]['condition'] = cond[0];
      }
    }
    for (var i = 0; i < 2 - exp[2].length; i++) exp[2].push([ '_', {}, [] ]);
      // adding ghost expressions
  };

  //
  // used for empty else clause
  //
  var GhostHandler = newHandler();
  GhostHandler.render = function (c, exp) {
  };
  GhostHandler.getHeight = function (c, exp) {
    return 0;
  };
  GhostHandler.getWidth = function (c, exp) {
    return 35;
  };

  var HANDLERS = {
    //'participant': ParticipantHandler
    'sequence': VerticalHandler,
    'concurrence': ConcurrenceHandler,
    'if': IfHandler,
    'set': TextHandler,
    'unset': TextHandler,
    'sleep': TextHandler,
    'subprocess': SubprocessHandler,
    '_': GhostHandler
  };

  var MINORS = [
    'set', 'set-fields', 'unset', 'description'
  ];

  var DEFINERS = [ 
    'process-definition', 'workflow-definition', 'define'
  ];

  function identifyExpressions (exp, expid) {
    if (exp.expid) return; // identify only once
    if ( ! expid) expid = '0';
    exp.expid = expid;
    if ((typeof exp) == 'string') return;
    for (var i = 0; i < exp[2].length; i++) {
      identifyExpressions(exp[2][i], expid + '.' + i);
    }
  }

  function setOption (context, options, optname, defval) {
    var v = options[optname];
    if (v) {
      context.canvas[optname] = v;
    }
    else if (optname in options) { // v is null
      context.canvas[optname] = null;
    }
    else if (defval && ! (context.canvas[optname])) {
      context.canvas[optname] = defval;
    }
  }

  //function renderFlow (context, flow, workitems, highlight) {
  function renderFlow (context, flow, options) {

    if ( ! options) options = {};

    identifyExpressions(flow);

    context = resolveContext(context);
    neutralizeContext(context);

    context.canvas.flow = flow;

    setOption(context, options, 'workitems', []);
    setOption(context, options, 'highlight');
    setOption(context, options, 'hideMinor');
    setOption(context, options, 'horizontal');

    context.save();

    if (context.canvas.horizontal == true) {
      context.translate(0, flow.width + 2);
      context.rotate(-Math.PI/2);
    }

    context.mozTextStyle = "12px Helvetica";

    var fs = context.fillStyle;
    context.fillStyle = 'rgb(255, 255, 255)';
    context.fillRect(0, 0, context.canvas.width, context.canvas.height);
    context.fillStyle = fs;

    //context.translate(context.canvas.width/2, 0);
    var w = getWidth(context, flow);
    context.translate(w/2 + 1, 1); // aligning left

    renderExp(context, flow);

    context.restore();

    //flow.width = getWidth(context, flow);
    //flow.height = getHeight(context, flow);
    getWidth(context, flow);
    getHeight(context, flow);
  }

  function highlight (c, highlight) {
    canvas = resolveCanvas(c);
    //clear(canvas);
    //renderFlow(canvas, canvas.flow, canvas.workitems, highlight);
    renderFlow(canvas, canvas.flow, {'highlight': highlight});
  }

  function drawWorkitem (c, exp) {
    var ww = c.mozMeasureText('wi');
    c.save();
    if (c.canvas.horizontal == true) {
      c.rotate(Math.PI/2);
      c.translate(5, -14);
    }
    else {
      c.translate(20, -7);
    }
    c.fillStyle = '#F4D850';
    c.moveTo(0, 0);
    c.beginPath();
    c.arc(0, 0, 10, Math.PI, 0, false);
    c.lineTo(0, 20);
    c.lineTo(-10, 0);
    c.fill();
    c.fillStyle = 'black';
    c.moveTo(0, 0);
    c.beginPath();
    c.arc(0, 0, 10, Math.PI, 0, false);
    c.lineTo(0, 20);
    c.lineTo(-10, 0);
    c.stroke();
    c.translate(-ww/2, 3);
    c.mozDrawText('wi');
    c.restore();
  }

  function renderExp (c, exp) {

    var handler = getHandler(c, exp);

    if (handler.adjust && ! exp.adjusted) { 
      handler.adjust(exp);
      exp.adjusted = true;
    }

    if (c.canvas.highlight && exp.expid == c.canvas.highlight) { // highlight
      var w = getWidth(c, exp); 
      var h = getHeight(c, exp);
      var t = 7;
      c.save();
      c.fillStyle = 'rgb(220, 220, 220)';
      c.fillRect(-w/2, 0, w, h);
      c.fillStyle = 'rgb(255, 255, 255)';
      c.fillRect(-w/2 + t, 0 + t , w - 2 * t, h - 2 * t);
      c.restore();
    }

    handler.render(c, exp);

    if (c.canvas.workitems.indexOf(exp.expid) > -1) { // workitem
      drawWorkitem(c, exp);
    }
  }

  /*
  function clear (c) {
    c = resolveContext(c);
    c.clearRect(0, 0, c.canvas.width, c.canvas.height);
  }
  */

  function resolveCanvas (c) {
    if (c.getContext != null) return c;
    if (c.canvas != null) return c.canvas;
    return document.getElementById(c);
  }

  function resolveContext (c) {
    if (c.translate != null) return c;
    return resolveCanvas(c).getContext('2d');
  }

  //
  // replaces the canvas element with a new, cropped, one
  //
  function crop (canvas) {

    canvas = resolveCanvas(canvas);
    var nc = document.createElement("canvas");

    nc.id = canvas.id;

    var w = canvas.flow.width + 2;
    var h = canvas.flow.height + 2;

    if (canvas.horizontal == true) {
      var x = w; w = h; h = x; 
    }

    nc.setAttribute('width', w);
    nc.setAttribute('height', h);

    nc.hideMinor = canvas.hideMinor;
    nc.horizontal = canvas.horizontal;
    nc.workitems = canvas.workitems;

    //renderFlow(nc, canvas.flow, canvas.workitems, canvas.highlight);
    renderFlow(nc, canvas.flow);
    canvas.parentNode.replaceChild(nc, canvas);
  }

  function neutralizeContext (c) {
    if (window.navigator.userAgent.match(/Firefox/)) return;
    c.mozDrawText = function (t) {
      // do nothing
    };
    c.mozMeasureText = function (t) {
      return t.length * 5;
    };
  }

  function isSubprocessName (exp, name) {
    if ((typeof exp) == 'string') return false;
    if (DEFINERS.indexOf(exp[0]) > -1 && exp[1]['name'] == name) return true;
    for (var i = 0; i < exp[2].length; i++) {
      if (isSubprocessName(exp[2][i], name)) return true;
    }
    return false;
  }

  //
  // returns the raw height of an expression (caches it too)
  //
  function getHeight (c, exp) {
    if ((typeof exp) == 'string') return getHandler(c, exp).getHeight(c, exp);
    if (exp.height) return exp.height;
    var h = getHandler(c, exp);
    if (h.adjust && ! exp.adjusted) { h.adjust(exp); exp.adjusted = true; }
    exp.height = h.getHeight(c, exp);
    return exp.height;
  }

  //
  // return the raw width of an expression
  //
  function getWidth (c, exp) {
    if ((typeof exp) == 'string') return getHandler(c, exp).getWidth(c, exp);
    if (exp.width) return exp.width;
    var h = getHandler(c, exp);
    if (h.adjust && ! exp.adjusted) { h.adjust(exp); exp.adjusted = true; }
    exp.width = h.getWidth(c, exp);
    return exp.width;
  }

  function getHandler (c, exp) {
    if ((typeof exp) == 'string') return StringHandler;
    var h = HANDLERS[exp[0]];
    if (h) return h;
    if (exp[2].length == 1 && ((typeof exp[2][0]) == 'string')) return GenericHandler;
    if (exp[2].length > 0) return GenericWithChildrenHandler;
    if (isSubprocessName(c.canvas.flow, exp[0])) return SubprocessHandler;
    return GenericHandler;
  }

  function clearDimCache (exp) {
    if ((typeof exp) == 'string') return;
    exp.width = null;
    exp.height = null;
    for (var i = 0; i < exp[2].length; i++) clearDimCache(exp[2][i]);
  }

  function toggleMinor (canvas) {
    canvas = resolveCanvas(canvas);
    canvas.hideMinor = ! canvas.hideMinor;
    clearDimCache(canvas.flow);
    renderFlow(canvas, canvas.flow);
  }

  function toggleVertical (canvas) {
    canvas = resolveCanvas(canvas);
    canvas.horizontal = ! canvas.horizontal;
    clearDimCache(canvas.flow);
    renderFlow(canvas, canvas.flow);
  }

  return {
    HANDLERS: HANDLERS,
    MINORS: MINORS,
    renderFlow: renderFlow,
    highlight: highlight,
    getHeight: getHeight,
    getWidth: getWidth,
    crop: crop,
    toggleMinor: toggleMinor,
    toggleVertical: toggleVertical
  };
}();
