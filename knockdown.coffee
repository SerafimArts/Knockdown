###
  This file is part of Knockdown package.

  @author serafim <nesk@xakep.ru> (30.12.2014 1:24)
  @version: 1.2.1

  For the full copyright and license information, please view the LICENSE
  file that was distributed with this source code.
###



class Knockdown
  @::version = '1.2.1'

  ###
    Attributes
  ###
  class Attributes
    toObject         = 'toObject'

    constructor: ->
      @prefix    = 'nd-'
      controller = 'controller'
      node       = 'node'

      # nd-controller
      Object.defineProperty @, 'controller', {
        get:       => @prefix + controller
        set: (val) => controller = val
      }

      # nd-node
      Object.defineProperty @, 'node', {
        get:       => @prefix + node
        set: (val) => node = val
      }

      # original knockout bindings
      @template = {}
      @template[binding] = binding for binding of ko.bindingHandlers

      # transform bindings
      @transform   = {
        attr:       toObject
        event:      toObject
        css:        toObject
        style:      toObject
        component:  toObject
        template:   toObject
      }

    with: (rule) => @prefix + rule


  ###
    Di Container
  ###
  class Container
    constructor: (items = {}) ->
      @items = {
        window: window
      }

      @[key] = value for key, value of items

    get: (key) => @items[key]

    has: (key) => !!@get(key)

    set: (key, val) =>
      @items[key] = val
      @

    with: (items) => new Container(items)



  ###
    Initialize
  ###
  constructor: ->
    @attr       = new Attributes
    @container  = new Container

    @ready      = false
    @onReady    => @applyBindings()



  ###
    Add to container
  ###
  controller: (name, controller) =>
    if !controller? && name instanceof Function
      [controller, name] = [name, name.name]
    @container.set(name, controller)



  ###
    Replace bindings
  ###
  invokeBindings: (dom) =>
    parent = dom.parentNode

    for rule, replace of @attr.template
      for node in parent.querySelectorAll("[#{@attr.with(rule)}]")
        node.bindings = node.bindings || []
        value = node.getAttribute("#{@attr.with(rule)}")

        # Реплейсы в значениях биндингов
        if @attr.transform[replace]?
          if @attr.transform[replace] is 'toObject'
            value = "{ #{value} }"
          else
            throw new Error 'Undefined keyword type'

        node.bindings.push "#{replace}: #{value}"

    for rule, replace of @attr.template
      for node in parent.querySelectorAll("[#{@attr.with(rule)}]")
        node.setAttribute('data-bind', node.bindings.join(', '))
        node.removeAttribute("#{@attr.with(rule)}")

    dom


  ###
    Create container for controller
  ###
  instance: (controller, dom) =>
    return if controller instanceof Function
      new controller(dom)
    else
      controller(dom)


  ###
    Bind new controllers for dom elements
  ###
  applyBindings: (node = document) =>
    controllers = [];

    for dom in node.querySelectorAll("[#{@attr.controller}]")
      attr = dom.getAttribute(@attr.controller)
      continue unless attr?

      container = @container.get(attr)
      applies = {}

      for subDom in dom.querySelectorAll("[#{@attr.controller}]")
        attr = subDom.getAttribute(@attr.controller)
        subContainer = @container.get(attr)
        subDom.removeAttribute(@attr.controller)

        key = subDom.getAttribute('nd-id') || "#{attr}$" + @uuid()
        instance = @instance(subContainer, subDom)
        applies[key] = instance
        container::[key] = instance

        @insertAfter(document.createComment('/ko'), subDom)
        @insertBefore(document.createComment('ko with: ' + key), subDom)

      controller = @instance(container, dom)

      # move from prototype to instance
      for k of applies
        controller[k] = container::[k]
        delete container::[k]

      dom.removeAttribute("#{@attr.controller}")
      controllers.push controller
      ko.applyBindings controller, @invokeBindings(dom)

    controllers

  uuid: =>
    d = new Date().getTime();
    uuid = 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = (d + Math.random()*16)%16 | 0;
      d = Math.floor(d/16)
      (if c is 'x' then r else (r&0x3|0x8)).toString(16);

    return uuid;



  insertBefore: (newElement, targetElement) =>
    targetElement.parentNode.insertBefore newElement, targetElement

  insertAfter: (newElement, targetElement) =>
    parent = targetElement.parentNode
    if twin = targetElement.nextSibling
      parent.insertBefore newElement, twin
    else
      parent.appendChild newElement






  ###
    Ready events
  ###
  onReady: (cb = (->)) =>
    readyCallback = =>
      @ready = true
      cb()

    return readyCallback() if @ready

    if document.addEventListener
      document.addEventListener 'DOMContentLoaded', =>
        document.removeEventListener 'DOMContentLoaded', arguments.callee, false
        readyCallback()
      , false
    else if document.attachEvent
      document.attachEvent 'onreadystatechange', =>
        if document.readyState is 'complete'
          document.detachEvent 'onreadystatechange', arguments.callee
          readyCallback()


window.nd = new Knockdown
