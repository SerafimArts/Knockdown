###
  @version: 1.0.0
###

class window.nd
  @version = '1.0.0'

  ndBindings = {
    prefix:     'nd-'
    controller: 'controller'
  }

  templateBindings = {}
  templateBindings[binding] = binding for binding of ko.bindingHandlers


  @container = {
    $window: window
  }


  @controller: (name, controller) =>
    @container[name] = controller



  @invokeBindings: (dom) =>
    parent = dom.parentNode

    for rule, replace of templateBindings
      for node in parent.querySelectorAll("[#{ndBindings.prefix + rule}]")
        node.bindings = node.bindings || []
        node.bindings.push "#{replace}: #{node.getAttribute("#{ndBindings.prefix + rule}")}"

    for rule, replace of templateBindings
      for node in parent.querySelectorAll("[#{ndBindings.prefix + rule}]")
        node.setAttribute('data-bind', node.bindings.join(', '))

    dom



  @invoke: (controller, dom) =>
    @dynamic = {
      dom: dom
    }


    args = (controller
    .toString()
    .match(/function\s*[\$_A-Z0-9a-z]+\s*\((.*?)\)/)[1]
    )
    .replace(/\s*/g, '')
    .split(',')


    invoke = (arg) =>
      if arg.substr(0, 1) is '$'
        key = arg.substr(1)
        if @container[key]?
          return @container[key]
        else if @dynamic[key]?
          return @dynamic[key]
      null


    [invoker, invokerString, iterator] = [[], [], 0]
    for arg in args
      invokerString.push "invoker[#{iterator++}]"
      invoker.push invoke(arg)
    return eval "new controller(#{invokerString.join(',')})"


  @extend: (cls) ->
    cls


  @init: =>
    for dom in document.querySelectorAll("[#{ndBindings.prefix + ndBindings.controller}]")
      attr = dom.getAttribute(ndBindings.prefix + ndBindings.controller)
      if @container[attr]?
        controller = @invoke(@extend(@container[attr]), dom)
        ko.applyBindings controller, @invokeBindings(dom)


  if document.addEventListener
    document.addEventListener 'DOMContentLoaded', =>
      document.removeEventListener 'DOMContentLoaded', arguments.callee, false
      @init()
    , false
  else if document.attachEvent
    document.attachEvent 'onreadystatechange', =>
      if document.readyState is 'complete'
        document.detachEvent 'onreadystatechange', arguments.callee
        @init()
