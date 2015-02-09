
/*
  This file is part of Knockdown package.

  @author serafim <nesk@xakep.ru> (30.12.2014 1:24)
  @version: 1.2.0

  For the full copyright and license information, please view the LICENSE
  file that was distributed with this source code.
 */

(function() {
  var Knockdown,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Knockdown = (function() {
    var Attributes, Container;

    Knockdown.prototype.version = '1.2.0';


    /*
      Attributes
     */

    Attributes = (function() {
      var toObject;

      toObject = 'toObject';

      function Attributes() {
        this["with"] = __bind(this["with"], this);
        var binding, controller, node;
        this.prefix = 'nd-';
        controller = 'controller';
        node = 'node';
        Object.defineProperty(this, 'controller', {
          get: (function(_this) {
            return function() {
              return _this.prefix + controller;
            };
          })(this),
          set: (function(_this) {
            return function(val) {
              return controller = val;
            };
          })(this)
        });
        Object.defineProperty(this, 'node', {
          get: (function(_this) {
            return function() {
              return _this.prefix + node;
            };
          })(this),
          set: (function(_this) {
            return function(val) {
              return node = val;
            };
          })(this)
        });
        this.template = {};
        for (binding in ko.bindingHandlers) {
          this.template[binding] = binding;
        }
        this.transform = {
          attr: toObject,
          event: toObject,
          css: toObject,
          style: toObject,
          component: toObject,
          template: toObject
        };
      }

      Attributes.prototype["with"] = function(rule) {
        return this.prefix + rule;
      };

      return Attributes;

    })();


    /*
      Di Container
     */

    Container = (function() {
      function Container(items) {
        var key, value;
        if (items == null) {
          items = {};
        }
        this["with"] = __bind(this["with"], this);
        this.set = __bind(this.set, this);
        this.has = __bind(this.has, this);
        this.get = __bind(this.get, this);
        this.items = {
          window: window
        };
        for (key in items) {
          value = items[key];
          this[key] = value;
        }
      }

      Container.prototype.get = function(key) {
        return this.items[key];
      };

      Container.prototype.has = function(key) {
        return !!this.get(key);
      };

      Container.prototype.set = function(key, val) {
        this.items[key] = val;
        return this;
      };

      Container.prototype["with"] = function(items) {
        return new Container(items);
      };

      return Container;

    })();


    /*
      Initialize
     */

    function Knockdown() {
      this.onReady = __bind(this.onReady, this);
      this.applyBindings = __bind(this.applyBindings, this);
      this.instance = __bind(this.instance, this);
      this.invokeBindings = __bind(this.invokeBindings, this);
      this.controller = __bind(this.controller, this);
      this.attr = new Attributes;
      this.container = new Container;
      this.ready = false;
      this.onReady((function(_this) {
        return function() {
          return _this.applyBindings();
        };
      })(this));
    }


    /*
      Add to container
     */

    Knockdown.prototype.controller = function(name, controller) {
      var _ref;
      if ((controller == null) && name instanceof Function) {
        _ref = [name, name.name], controller = _ref[0], name = _ref[1];
      }
      return this.container.set(name, controller);
    };


    /*
      Replace bindings
     */

    Knockdown.prototype.invokeBindings = function(dom) {
      var node, parent, replace, rule, value, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
      parent = dom.parentNode;
      _ref = this.attr.template;
      for (rule in _ref) {
        replace = _ref[rule];
        _ref1 = parent.querySelectorAll("[" + (this.attr["with"](rule)) + "]");
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          node = _ref1[_i];
          node.bindings = node.bindings || [];
          value = node.getAttribute("" + (this.attr["with"](rule)));
          if (this.attr.transform[replace] != null) {
            if (this.attr.transform[replace] === 'toObject') {
              value = "{ " + value + " }";
            } else {
              throw new Error('Undefined keyword type');
            }
          }
          node.bindings.push("" + replace + ": " + value);
        }
      }
      _ref2 = this.attr.template;
      for (rule in _ref2) {
        replace = _ref2[rule];
        _ref3 = parent.querySelectorAll("[" + (this.attr["with"](rule)) + "]");
        for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
          node = _ref3[_j];
          node.setAttribute('data-bind', node.bindings.join(', '));
          node.removeAttribute("" + (this.attr["with"](rule)));
        }
      }
      return dom;
    };


    /*
      Create container for controller
     */

    Knockdown.prototype.instance = function(controller, dom) {
      if (controller instanceof Function) {
        return new controller(dom);
      } else {
        return controller(dom);
      }
    };


    /*
      Bind new controllers for dom elements
     */

    Knockdown.prototype.applyBindings = function(node) {
      var attr, container, controller, dom, key, subContainer, subDom, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (node == null) {
        node = document;
      }
      _ref = node.querySelectorAll("[" + this.attr.controller + "]");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dom = _ref[_i];
        attr = dom.getAttribute(this.attr.controller);
        if (attr == null) {
          continue;
        }
        container = this.container.get(attr);
        _ref1 = dom.querySelectorAll("[" + this.attr.controller + "]");
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          subDom = _ref1[_j];
          subContainer = this.container.get(subDom.getAttribute(this.attr.controller));
          subDom.removeAttribute(this.attr.controller);
          key = 'subController' + Math.round(Math.random() * 100000);
          container.prototype[key] = this.instance(subContainer, subDom);
          subDom.setAttribute('nd-with', key);
        }
        controller = this.instance(container, dom);
        dom.removeAttribute("" + this.attr.controller);
        _results.push(ko.applyBindings(controller, this.invokeBindings(dom)));
      }
      return _results;
    };


    /*
      Ready events
     */

    Knockdown.prototype.onReady = function(cb) {
      var readyCallback;
      if (cb == null) {
        cb = (function() {});
      }
      readyCallback = (function(_this) {
        return function() {
          _this.ready = true;
          return cb();
        };
      })(this);
      if (this.ready) {
        return readyCallback();
      }
      if (document.addEventListener) {
        return document.addEventListener('DOMContentLoaded', (function(_this) {
          return function() {
            document.removeEventListener('DOMContentLoaded', arguments.callee, false);
            return readyCallback();
          };
        })(this), false);
      } else if (document.attachEvent) {
        return document.attachEvent('onreadystatechange', (function(_this) {
          return function() {
            if (document.readyState === 'complete') {
              document.detachEvent('onreadystatechange', arguments.callee);
              return readyCallback();
            }
          };
        })(this));
      }
    };

    return Knockdown;

  })();

  window.nd = new Knockdown;

}).call(this);
