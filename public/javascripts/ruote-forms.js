
/*
 *  ruote-forms
 *  (c) 2008-2009 OpenWFE.org
 *
 *  Ruote (OpenWFEru) is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 *
 *  John Mettraux
 */


var RuoteForms = function() {

  // TODO
  //
  // - [cut/]paste
  // - rform_number validate onblur

  var CONFIG = {
    'img_moveup': '/images/btn-moveup.gif',
    'img_movedown': '/images/btn-movedown.gif',
    'img_cut': '/images/btn-cut.gif',
    'img_change': '/images/btn-change.gif',
    'img_add': '/images/btn-add.gif'
  }

  //
  // misc

  function escapeHtml (s) {
    return s
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/'/g, '&#39;')
      .replace(/"/g, '&quot;');
  }

  function toArray (a) {
    var aa = [];
    if (a.length) { for (var i = 0; i < a.length; i++) { aa.push(a[i]); } }
    else { for (var i in a) { aa.push(a[i]); } }
    return aa;
  }

  function dwrite () {
    var s = '';
    document.write('. ' + toArray(arguments).join(', ') + '<br/>');
  }

  function hclone (h) {
    var n = {};
    for (var k in h) { n[k] = h[k]; }
    return n;
  }

  function byId (id) {
    return ((typeof id) == 'string') ? document.getElementById(id) : id;
  }

  function clean (elt) {
    while (elt.firstChild != null) elt.removeChild(elt.firstChild);
  }

  function create (container, tag, attributes, content) {
    if ( ! attributes) attributes = {};
    var e = document.createElement(tag);
    if (content) e.innerHTML = content;
    for (var k in attributes) e.setAttribute(k, attributes[k]);
    if (container) container.appendChild(e);
    return e;
  }

  //
  // edition

  function moveUp () {
    this.stack();
    var ps = this.previousSibling;
    if ( ! ps) return;
    this.parentNode.insertBefore(this, ps);
  }
  function moveDown () {
    this.stack();
    var ns = this.nextSibling;
    if ( ! ns) return;
    var nns = ns.nextSibling;
    if (nns) this.parentNode.insertBefore(this, nns);
    else this.parentNode.appendChild(this);
  }

  function cut () {
    this.stack();
    this.parentNode.removeChild(this);
  }

  //
  // toObject()

  // like the ruby inject, but 'return target' is implied
  //
  function inject (target, func) {
    for (var i in this) {
      var e = this[i];
      if ((typeof e) == 'function') continue;
      func(target, this[i]);
    }
    return target;
  }

  function childrenOfClass (container, className) {
    var a = [];
    for (var i in container.childNodes) {
      var n = container.childNodes[i];
      if ( ! n) continue;
      if (n.nodeType != 1) continue;
      if (n.className != className) continue;
      a.push(n);
    }
    a.inject = inject;
    return a;
    //return container.childNodes.filter(function (n) {
    //  return n.nodeType == 1 && n.className == className;
    //});
  }
  function childOfClass (container, className) {
    return childrenOfClass(container, className)[0];
  }
  function rformChild (container) {
    for (var i in container.childNodes) {
      var n = container.childNodes[i];
      if (n.nodeType != 1) continue;
      if (n.className.match(/rform\_/)) return n;
    }
    return null;
  }

  function toObject () {
    var type = this.className.match(/rform\_([^ ]*)/)[1];
    if (type == 'array') {
      return childrenOfClass(this, 'rform_item').inject([], function(a, i) {
        var v = i.toObject();
        if (v != EmptyItem) a.push(v);
      });
    }
    if (type == 'item' || type == 'key' || type == 'value') {
      var c = rformChild(this);
      return c ? c.toObject() : null;
    }
    if (type == 'hash') {
      var h = {};
      childrenOfClass(this, 'rform_entry').map(function(e) {
        var entry = e.toObject();
        var k = entry[0];
        var v = entry[1];
        if (v != EmptyItem) h[k] = v;
      });
      return h;
    }
    if (type == 'entry') {
      return [
        childOfClass(this, 'rform_key').toObject(),
        childOfClass(this, 'rform_value').toObject()
      ];
    }
    if (type == 'string') {
      return this.firstChild.value;
    }
    if (type == 'number') {
      return (new Number(this.firstChild.value)).valueOf();
    }
    if (type == 'boolean') {
      return this.firstChild.checked;
    }
    if (type == 'new') {
      return EmptyItem;
    }
    alert("unknown type '" + type + "'");
  }

  function rcreate (container, tag, attributes, content) {
    var e = create(container, tag, attributes, content);
    e.toObject = toObject;
    e.stack = stack;
    e.moveUp = moveUp;
    e.moveDown = moveDown;
    e.cut = cut;
    return e;
  }

  //
  // undo / copy / paste / reset

  function findRoot (elt) {
    if (elt.className.match(/rform_root/)) return elt;
    return findRoot(elt.parentNode);
  }

  function stack () {
    var root = findRoot(this);
    root.stack.push(root.firstChild.toObject());
    //dwrite(root.stack.length, fluoToJson(root.stack[root.stack.length - 1]));
  }

  function resetForm (container) {
    var root = byId(container);
    clean(root);
    render(root, root.originalData, root.originalOptions);
  }

  function undo (container) {
    var root = byId(container);
    clean(root);
    var data = root.stack.pop() || root.originalData;
    render(root, data, root.originalOptions);
  }

  //
  // focuses in the first input thing found in this element
  //
  function focusIn (elt) {
    if (elt.nodeName.toLowerCase() == 'input') {
      elt.focus();
      return true;
    }
    for (var i in elt.childNodes) {
      var n = elt.childNodes[i];
      if (n.nodeType != 1) continue;
      if (focusIn(n)) return true;
    }
    return false;
  }

  //
  // render()

  function EmptyItem () {} // a kind of 'marker'

  function createChangeFunction (render_method) {
    return function () {
      var target = this.parentNode.parentNode;
      var n = render_method.call(null, target, EmptyItem, {});
      target.replaceChild(n, this);
      return false;
    };
  }

  function addItemButtons (elt) {
    var e = create(elt, 'div', { 'class': 'rform_buttons', });
    create(e, 'img', {
      'src': CONFIG.img_moveup,
      'onclick': 'this.parentNode.parentNode.moveUp(); return false;'
    });
    create(e, 'img', {
      'src': CONFIG.img_movedown,
      'onclick': 'this.parentNode.parentNode.moveDown(); return false;'
    });
    create(e, 'img', {
      'src': CONFIG.img_cut,
      'onclick': 'this.parentNode.parentNode.cut(); return false;'
    });
    var ec = create(e, 'img', { 'src': CONFIG.img_change });
    ec.onclick = function () {
      var target = this.parentNode.parentNode;
      var n = render_item(target.parentNode, EmptyItem, {});
      target.parentNode.replaceChild(n, target);
      return false;
    }
  }

  function addToCollection (elt) {
    //elt.stack();
    var ecollection = elt.parentNode;
    ecollection.insertBefore(elt, elt.previousSibling);
    return false;
  }

  function addArrayButtons (elt) {
    var e = create(elt, 'div', { 'class': 'rform_buttons', });
    var ea = create(e, 'img', { 'src': CONFIG.img_add });
    ea.onclick = function () {
      return addToCollection(render_item(e.parentNode, EmptyItem, {}));
    }
  }

  function addEntryButtons (elt) {
    var e = create(elt, 'div', { 'class': 'rform_buttons', });
    create(e, 'img', {
      'src': CONFIG.img_cut,
      'onclick': 'this.parentNode.parentNode.cut(); return false;'
    });
    var ec = create(e, 'img', { 'src': CONFIG.img_change });
    ec.onclick = function () {
      var target = this.parentNode.parentNode;
      var k = target.firstChild.firstChild.firstChild.value;
      var n = render_entry(target.parentNode, [ k, EmptyItem ], {});
      target.parentNode.replaceChild(n, target);
      return false;
    }
  }

  function addHashButtons (elt) {
    var e = create(elt, 'div', { 'class': 'rform_buttons', });
    var ea = create(e, 'img', { 'src': CONFIG.img_add });
    ea.onclick = function () {
      var ne = render_entry(e.parentNode, [ '', EmptyItem ], {});
      var r = addToCollection(ne);
      focusIn(ne);
      return r;
    }
  }

  function render_item (elt, data, options) {
    var ei = rcreate(elt, 'div', { 'class': 'rform_item' });
    render(ei, data, options);
    addItemButtons(ei);
    return ei;
  }

  function render_array (elt, data, options) {
    var e = rcreate(elt, 'div', { 'class': 'rform_array' });
    for (var i = 0; i < data.length; i++) { render_item(e, data[i], options); }
    addArrayButtons(e);
    return e;
  }

  function render_entry (elt, data, options) {
    var e = rcreate(elt, 'div', { 'class': 'rform_entry' });
    var ek = rcreate(e, 'div', { 'class': 'rform_key' });
    var ev = rcreate(e, 'div', { 'class': 'rform_value' });
    addEntryButtons(e);
    render(ek, data[0], options);
    var evv = render(ev, data[1], options);
    return e;
  }

  function render_object (elt, data, options) {
    var e = rcreate(elt, 'div', { 'class': 'rform_hash' });
    //var ks = []; for (var kk in data) { ks.push(kk); }; ks = ks.sort();
    for (var k in data) { render_entry(e, [ k, data[k] ], options); }
    addHashButtons(e);
    return e;
  }

  function render_boolean (elt, data, options) {
    var n = Math.random().toString();
    var e = rcreate(elt, 'div', { 'class': 'rform_boolean' });
    var et = rcreate(e, 'input', { 'type': 'radio', 'name': n });
    var ett = rcreate(e, 'span', {}, 'true');
    var ef = rcreate(e, 'input', { 'type': 'radio', 'name': n });
    var eff = rcreate(e, 'span', {}, 'false');
    ett.onclick = function () { et.checked = true; }
    eff.onclick = function () { ef.checked = true; }
    if (data) et.checked = true;
    else ef.checked = true;
    return e;
  }

  function render_new_type (elt, label, initialValue) {
    var e = rcreate(elt, 'a', { 'class': 'rform_new_type', 'href': '' }, label);
    e.onclick = function () {
      var enew = this.parentNode;
      var enewp = enew.parentNode;
      var i = render(enewp, initialValue, {});
      enewp.replaceChild(i, enew);
      focusIn(i);
      return false;
    };
  }
  function render_new (elt, options) {
    var e = rcreate(elt, 'div', { 'class': 'rform_new' });
    render_new_type(e, 'string', '');
    render_new_type(e, 'number', 0);
    render_new_type(e, 'boolean', false);
    render_new_type(e, 'array', []);
    render_new_type(e, 'hash', {});
    return e;
  }

  function render_number (elt, data, options) {
    options = hclone(options);
    options['class'] = 'rform_number';
    return render_string(elt, data.toString(), options);
  }

  function render_string (elt, data, options) {
    var klass = options['class'] || 'rform_string';
    var e = rcreate(elt, 'span', { 'class': klass });
    if (options['read-only'])
      e.innerHTML = escapeHtml(data);
    else if (data.match(/\n/))
      create(e, 'textarea', { 'type': 'text' }, data);
    else
      create(e, 'input', { 'type': 'text', 'value': data });
    return e;
  }

  function render (elt, data, options) {
    if (data == EmptyItem || data == null) return render_new(elt, options);
    var t = data['__class'] || (typeof data);
    if (t == 'object') {
      var l = data.length; 
      if (l || l == 0) t = 'array';
    }
    var f = eval('render_' + t);
    return f.call(null, elt, data, options);
  }

  function renderForm (container, data, options) {

    container = byId(container);

    if ( ! container.className.match(/rform_root/))
      container.className = container.className + ' rform_root';
    if ( ! options)
      options = {};

    clean(container);

    container.originalData = data;
    container.originalOptions = options;
    container.stack = [];

    render(container, data, options);
  }

  function toJson (container) {
    container = byId(container);
    return fluoToJson(container.firstChild.toObject());
  }

  return {
    CONFIG: CONFIG,
    renderForm: renderForm,
    resetForm: resetForm,
    toJson: toJson,
    undo: undo
  };
}();

