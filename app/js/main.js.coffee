###
Created by johaned on 12/15/13.
###
((window, document, undefined_) ->
  slowchart =
  # Object containing all the registered modules
    modules: {}
  # Object containing all the registered init methods
    inits: {}
  # Define the core class
    core: (options)->
      options = options || {}

      @isCore = true

      @defaultValues =
        startNodeName: "start node"
        endNodeName: "end node"

      @domHierarchy =
        toolBoxClass: "toolbox"
        flowSpaceClass: "flowspace"
        subcanvasClass: "canvas"
        toolBoxSelector: () ->
          "."+@toolBoxClass
        flowSpaceSelector: () ->
          "."+@flowSpaceClass
        toolBoxCanvasSelector: () ->
          "."+@toolBoxClass+" ."+@subcanvasClass
        flowSpaceCanvasSelector: () ->
          "."+@flowSpaceClass+" ."+@subcanvasClass

      # Common slowchart settings
      @settings =
        domContainerID: "#flowchart"
        htmlID: ->
          @domContainerID.replace('#','')

      # Initializes a array of initial variables that will be loaded in the components
      # of flow chart, this variables are loaded through create function as a parameter
      # assignment agent which could received the data from Rest API
      @initialVariables = options.initialVariables || []

      # start node Name that will be show in main gui into workspace, this can be changed
      # from options obteined from create function
      @startNodeName = options.startNodeName || @defaultValues.startNodeName

      # start node Name that will be show in main gui into workspace, this can be changed
      # from options obteined from create function
      @endNodeName = options.endNodeName || @defaultValues.endNodeName

      # Reference to tool box oCanvas object, the instance is created through toolbox method
      @toolbox =
        oCanvasElement: null
        dimensions:
          width: 400
          height: 800
        tools:
          operation: null
          decision: null
          relation: null

      # Reference to flowchart oCanvas object, the instance is created through flowspace method
      @flowspace =
        oCanvasElement: null
        elements: null

      # Graphical settings
      @graphicalSettings =
        text:
          title:
            width: 300
            height: 25
            origin: { x: "left", y: "top" }
            align: "left"
            font: "bold 16px helvetica"
            fill: "#999"
          subtitle:
            width: 300
            height: 15
            origin: { x: "left", y: "top" }
            align: "left"
            font: "bold 15px helvetica"
            fill: "#eee"
        tools:
          operation:
            width: 150
            height: 30
            fill: "#8cc"
            stroke: "2px #079"
            onHoverStroke: "2px #65E"
            join: "round"
            origin:
              x: "center"
              y: "center"
          decision:
            sides: 4
            radius: 30
            rotation: 0
            fill: "#eba"
            stroke: "2px #e55"
            onHoverStroke: "2px #65E"
            origin:
              x: "center"
              y: "center"
          relation:
            stroke: "4px #bE5"
            onHoverStroke: "2px #65E"
            cap: "round"

      # Setup the main container node in DOM
      @domContainerID = @settings.domContainerID
      
      # Defines if html flowchart node is located in root spot or if it has a parent container
      @hasParentContainer = false
      @containerSelector = options.cssContainerSelector || ''
      @fullSlowchartSelector = @domContainerID
      if @containerSelector != '' && document.querySelectorAll(@containerSelector).length == 1
        @hasParentContainer = true
        @fullSlowchartSelector = @containerSelector+" "+@domContainerID

      # Config file
      @config =
        areToolsCreated : false

      # Add the registered modules to the new instance of core
      for m of slowchart.modules
        if typeof slowchart.modules[m] is "function"
          this[m] = slowchart.modules[m]()
        else
          this[m] = Object.create(slowchart.modules[m])

      # Set the core instance in all modules to enable access of core properties inside of modules
      for m of slowchart.modules
        # Add core access to modules that reside directly in the core
        this[m].core = this

      # Initialize added modules that have registered init methods
      for name of slowchart.inits
        # Modules directly on the slowchart object
        if (typeof slowchart.inits[name] is "string") and (typeof this[name][slowchart.inits[name]] is "function")
          this[name][slowchart.inits[name]]()

      return

    # Creates an instance of slowchart's core
    # @param options [Object], contains the initial variables, start node name, end node name
    # and selector of main container node
    create: (options) ->
      new @core options

    # Method for registering a new module
    # @param name [String], name which the module will be registered
    # @param module [function], reference to function that describe the module
    registerModule: (name, module) ->
      if ~name.indexOf(".")
        parts = name.split(".")
        slowchart.modules[parts[0]][parts[1]] = module
      else
        slowchart.modules[name] = module

  # Methods the core instances will have access to
  slowchart.core.prototype =
    initialize: ->
      # Populate the misc class2type map (object types)
      class2type = []
      @misc.each "Boolean Number String Function Array Date RegExp Object Error".split(" "), (i, name) ->
        class2type["[object " + name + "]"] = name.toLowerCase()
        return
      @misc.class2type = class2type
      # builds first Slowchart structure
      @builder.setup()
      # oCanvas objects were built by using isolated way, because strange behaviour
      # appears when they are built into the scaffold method
      @builder.createCanvasObjects()
      @builder.toolbox()
      return this

  # Attach the slowchart object to the window object for access outside of this file
  window.slowchart = slowchart

  # Define Object.create if not available
  if typeof Object.create isnt "function"
    Object.create = (o) ->
      F = ->
      F:: = o
      new F()

  # Module that support the slowchart scaffolding process
  builder = ->
    # Return an object when instantiated

    # Check if node ID gave from options points to real node in document, if not, it creates
    # a new main container with id value by default and updates the container. Also, it creates
    # both toolbox and flowspace scaffold
    setup: ->
      # Builds a flowchart div into specific container
      if @core.hasParentContainer
        parent = document.querySelector(@core.containerSelector)
      else
        parent = document.body
      flowchartContainer = "<div id='"+@core.settings.htmlID()+"'></div>"
      @core.misc.insertElement(flowchartContainer, parent)
      # builds the the toolbox located in left side of page, this contains the flow nodes and some
      # actions to interact between them
      @core.builder.createScaffold(@core.domHierarchy.toolBoxClass, @core.domHierarchy.toolBoxSelector(), 200, 700)
      # builds the the flowspace located in right side of page, this contains the flow chart
      @core.builder.createScaffold(@core.domHierarchy.flowSpaceClass, @core.domHierarchy.flowSpaceSelector(), 800, 1000)
      return

    # Creates the common scaffold to flowspace and toolbox
    createScaffold: (className, selector, canvasWidth, canvasHeight)->
      mainNode = document.querySelector(@core.domContainerID)
      spaceElement = "<div class='"+className+"'></div>"
      @core.misc.insertElement(spaceElement, mainNode)
      canvasElement = "<canvas class='"+@core.domHierarchy.subcanvasClass+"' width="+canvasWidth+" height="+canvasHeight+"></canvas>"
      space = document.querySelector(@core.domContainerID+' '+selector)
      @core.misc.insertElement(canvasElement, space)
      return

    createCanvasObjects: ->
      selector = @core.domContainerID + " " + @core.domHierarchy.toolBoxCanvasSelector()
      @core.toolbox.oCanvasElement = @core.builder.oCanvasFactory(selector)
      selector = @core.domContainerID + " " + @core.domHierarchy.flowSpaceCanvasSelector()
      @core.flowspace.oCanvasElement = @core.builder.oCanvasFactory(selector)

    # Creates oCanvas object
    oCanvasFactory: (selector)->
      oCanvas.create (
        canvas: selector
        background: "#555"
      )

    # creates all necessary tools in flowchart toolbox
    toolbox: ->
      canvas = @core.toolbox.oCanvasElement
      canvas.display.text(
        x: 10
        y: 10
        width: 300
        height: 25
        origin: { x: "left", y: "top" }
        align: "left"
        font: "bold 16px helvetica"
        text: "TOOLBOX"
        fill: "#999"
      ).add()
      canvas.display.text(
        x: 10
        y: 60
        width: 300
        height: 15
        origin: { x: "left", y: "top" }
        align: "left"
        font: "bold 15px helvetica"
        text: "Operation"
        fill: "#eee"
      ).add()
      canvas.display.text(
        x: 10
        y: 160
        width: 300
        height: 15
        origin: { x: "left", y: "top" }
        align: "left"
        font: "bold 15px helvetica"
        text: "Decision"
        fill: "#eee"
      ).add()
      canvas.display.text(
        x: 10
        y: 260
        width: 300
        height: 15
        origin: { x: "left", y: "top" }
        align: "left"
        font: "bold 15px helvetica"
        text: "Relation"
        fill: "#eee"
      ).add()
      @core.toolbox.tools.operation = canvas.display.rectangle(
        x: 100
        y: 115
        origin:
          x: "center"
          y: "center"
        width: 150
        height: 30
        fill: "#8cc"
        stroke: "2px #079"
        join: "round"
      )
      @core.toolbox.tools.decision = canvas.display.polygon(
        x: 100
        y: 215
        origin:
          x: "center"
          y: "center"
        sides: 4
        radius: 30
        rotation: 0
        fill: "#eba"
        stroke: "2px #e55"
      )
      @core.toolbox.tools.relation = canvas.display.line(
        start:
          x: 180
          y: 290
        end:
          x: 20
          y: 340
        stroke: "4px #bE5"
        cap: "round"
      )
      canvas.addChild(@core.toolbox.tools.operation)
      canvas.addChild(@core.toolbox.tools.decision)
      canvas.addChild(@core.toolbox.tools.relation)
      @core.toolbox.tools.decision.bind "mouseenter", ->
        @fill = "hsl(" + Math.random() * 360 + ", 50%, 50%)"
        @draw();
        return

  slowchart.registerModule("builder", builder);

  # module that support operations over dom hierarchy
  misc = ->
    # Return an object when instantiated

    # Class common types
    class2type: {}

    # Variation in String format of classType object
    toString: ->
      @class2type.toString

    # Properties (types) of classType Object
    hasOwn: ->
      @class2type.hasOwnProperty

    # Iterates on a specific array
    each: (obj, callback, args) ->
      i = undefined
      isArray = undefined
      length = undefined
      value = undefined
      value = undefined
      i = 0
      length = obj.length
      isArray = @isArraylike(obj)
      if args
        if isArray
          while i < length
            value = callback.apply(obj[i], args)
            break  if value is false
            i++
        else
          for i of obj
            value = callback.apply(obj[i], args)
            break  if value is false
      else
        if isArray
          while i < length
            value = callback.call(obj[i], i, obj[i])
            break  if value is false
            i++
        else
          for i of obj
            value = callback.call(obj[i], i, obj[i])
            break  if value is false
      obj

    # Checkis if object is window
    isWindow: (obj) ->
      (obj?) and obj is obj.window

    # Returns object type taking into account clas2type object
    type: (obj) ->
      return obj + ""  unless obj?
      if typeof obj is "object" or typeof obj is "function"
        @class2type[@toString().call(obj)] or "object"
      else
        typeof obj

    isArraylike: (obj) ->
      length = obj.length
      type = @type(obj)
      return false  if type is "function" or @isWindow(obj)
      return true  if obj.nodeType is 1 and length
      type is "array" or length is 0 or typeof length is "number" and length > 0 and (length - 1) of obj

    # Inspects if object is function, DOM methods and functions like alert
    # aren't supported. They return false on IE (#2968).
    isFunction: (obj) ->
      @type(obj) is "function"

    # Checks if object is plainObject
    isPlainObject: (obj) ->
      key = undefined
      # Must be an Object.
      # Because of IE, we also have to check the presence of the constructor property.
      # Make sure that DOM nodes and window objects don't pass through, as well
      return false  if not obj or @type(obj) isnt "object" or obj.nodeType or @isWindow(obj)
      try
      # Not own constructor property must be Object
        return false  if obj.constructor and not @hasOwn.call(obj, "constructor") and not @hasOwn.call(obj.constructor::, "isPrototypeOf")
      catch e
      # IE8,9 Will throw exceptions on certain host objects #9897
        return false

      # Own properties are enumerated firstly, so to speed up,
      # if last one is own, then all properties are own.
      for key of obj
        continue
      key is `undefined` or @hasOwn.call(obj, key)

    # Checks if object is Array
    isArray: (obj) ->
      @type(obj) is "array"

    # Merge the contents of two or more objects together into the first object.
    extend: ->
      src = undefined
      copyIsArray = undefined
      copy = undefined
      name = undefined
      options = undefined
      clone = undefined
      target = arguments[0] or {}
      i = 1
      length = arguments.length
      deep = false

      # Handle a deep copy situation
      if typeof target is "boolean"
        deep = target

        # skip the boolean and the target
        target = arguments[i] or {}
        i++

      # Handle case when target is a string or something (possible in deep copy)
      target = {}  if typeof target isnt "object" and not @isFunction(target)

      # extend jQuery itself if only one argument is passed
      if i is length
        target = this
        i--
      while i < length

        # Only deal with non-null/undefined values
        if (options = arguments[i])?

          # Extend the base object
          for name of options
            src = target[name]
            copy = options[name]

            # Prevent never-ending loop
            continue  if target is copy

            # Recurse if we're merging plain objects or arrays
            if deep and copy and (@isPlainObject(copy) or (copyIsArray = @isArray(copy)))
              if copyIsArray
                copyIsArray = false
                clone = (if src and @isArray(src) then src else [])
              else
                clone = (if src and @isPlainObject(src) then src else {})

              # Never move original objects, clone them
              target[name] = @extend(deep, clone, copy)

              # Don't bring in undefined values
            else target[name] = copy  if copy isnt `undefined`
        i++

      # Return the modified object
      target

    # Create a node element based on string definition of object
    # param element [String], element css selector that will be inserted in parent
    # param parent [HTML Node], new parent of html element
    insertElement: (element, parent) ->
      parent.innerHTML = element + parent.innerHTML
      return

  slowchart.registerModule("misc", misc);

  # Supports objects making process that will be used to build canvas elements
  canvasShapeFactory = ->
    text: (element, options)->
      @core.misc.extend(@core.graphicalSettings.text[element], options)
    tool: (element, options)->
      @core.misc.extend(@core.graphicalSettings.tools[element], options)

  slowchart.registerModule("canvasShapeFactory", canvasShapeFactory);
) window, document
