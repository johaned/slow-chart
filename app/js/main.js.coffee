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
    core: (settings)->
      settings = settings || {}

      this.isCore = true

      this.defaultValues =
        domContainerSelector: "#flowchart"
        startNodeName: "start node"
        endNodeName: "end node"

      this.domHierarchy =
        toolBoxClass: "toolbox"
        flowSpaceClass: "flowspace"
        subcanvasClass: "canvas"
        toolBoxSelector: () ->
          "."+this.toolBoxClass
        flowSpaceSelector: () ->
          "."+this.flowSpaceClass
        toolBoxCanvasSelector: () ->
          "."+this.toolBoxClass+" ."+this.subcanvasClass
        flowSpaceCanvasSelector: () ->
          "."+this.flowSpaceClass+" ."+this.subcanvasClass


      # Initializes a array of initial variables that will be loaded in the components
      # of flow chart, this variables are loaded through create function as a parameter
      # assignment agent which could received the data from Rest API
      this.initialVariables = settings.initialVariables || []

      # start node Name that will be show in main gui into workspace, this can be changed
      # from settings obteined from create function
      this.startNodeName = settings.startNodeName || this.defaultValues.startNodeName

      # start node Name that will be show in main gui into workspace, this can be changed
      # from settings obteined from create function
      this.endNodeName = settings.endNodeName || this.defaultValues.endNodeName

      # Reference to tool box oCanvas object, the instance is created through toolbox method
      this.toolboxCanvas = null

      # Reference to flowchart oCanvas object, the instance is created through flowspace method
      this.flowspaceCanvas = null

      # Setup the main container node in DOM
      this.domContainerSelector = settings.flowchart || this.defaultValues.domContainerSelector

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
    # @param settings [Object], contains the initial variables, start node name, end node name
    # and selector of main container node
    create: (settings) ->
      new this.core settings

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
      this.build.setup()
      this.build.toolbox()
      this.build.flowspace()
      return this

  # Attach the slowchart object to the window object for access outside of this file
  window.slowchart = slowchart

  # Define Object.create if not available
  if typeof Object.create isnt "function"
    Object.create = (o) ->
      F = ->
      F:: = o
      new F()

  build = ->
    # Return an object when instantiated

    # Check if node ID gave from settings points to real node in document, if not, it creates
    # a new main container with id value by default and updates the
    setup: ->
      unless document.querySelectorAll(this.core.domContainerSelector).length == 1
        this.core.domContainerSelector = this.core.defaultValues.domContainerSelector
        this.core.build.mainContainer(this.core.defaultValues.domContainerSelector)
      return this

    # build the main container node, it creates a div element an inserts into the body document
    mainContainer: (id)->
      div = document.createElement("div")
      div.id = id.replace('#','')
      document.body.appendChild(div)
      return this

    # build the the toolbox located in left side of page, this contains the flow nodes and some
    # actions to interact between them
    toolbox: ->
      mainNode = document.querySelector(this.core.domContainerSelector)
      toolBoxElement = "<div class='"+this.core.domHierarchy.toolBoxClass+"'></div>"
      this.core.misc.insertElement(toolBoxElement, mainNode)
      canvasElement = "<canvas class='"+this.core.domHierarchy.subcanvasClass+"'></canvas>"
      toolbox = document.querySelector(this.core.domHierarchy.toolBoxSelector())
      this.core.misc.insertElement(canvasElement, toolbox)
      this.core.toolboxCanvas = oCanvas.create (canvas: this.core.domContainerSelector + " " + this.core.domHierarchy.toolBoxCanvasSelector())
      return this

    # build the the flowspace located in right side of page, this contains the flow chart 
    flowspace: ->
      mainNode = document.querySelector(this.core.domContainerSelector)
      flowspaceElement = "<div class='"+this.core.domHierarchy.flowSpaceClass+"'></div>"
      this.core.misc.insertElement(flowspaceElement, mainNode)
      canvasElement = "<canvas class='"+this.core.domHierarchy.subcanvasClass+"'></canvas>"
      flowspace = document.querySelector(this.core.domHierarchy.flowSpaceSelector())
      this.core.misc.insertElement(canvasElement, flowspace)
      this.core.flowspaceCanvas = oCanvas.create (canvas: this.core.domContainerSelector + " " + this.core.domHierarchy.flowSpaceCanvasSelector())
      return this

  slowchart.registerModule("build", build);

  misc = ->
    # Return an object when instantiated

    # Create a node element based on string definition of object
    insertElement: (element, parent) ->
      parent.innerHTML = element + parent.innerHTML
      return this

  slowchart.registerModule("misc", misc);
) window, document
