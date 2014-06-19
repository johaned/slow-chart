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

      this.isCore = true

      this.defaultValues =
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

      # Common slowchart settings
      this.settings =
        domContainerID: "#flowchart"
        htmlID: ->
          @domContainerID.replace('#','')

      # Initializes a array of initial variables that will be loaded in the components
      # of flow chart, this variables are loaded through create function as a parameter
      # assignment agent which could received the data from Rest API
      this.initialVariables = options.initialVariables || []

      # start node Name that will be show in main gui into workspace, this can be changed
      # from options obteined from create function
      this.startNodeName = options.startNodeName || this.defaultValues.startNodeName

      # start node Name that will be show in main gui into workspace, this can be changed
      # from options obteined from create function
      this.endNodeName = options.endNodeName || this.defaultValues.endNodeName

      # Reference to tool box oCanvas object, the instance is created through toolbox method
      this.toolbox =
        oCanvasElement: null
        dimensions:
          width: 400
          height: 800
        tools:
          operation: null
          decision: null
          relation: null


      # Reference to flowchart oCanvas object, the instance is created through flowspace method
      this.flowspace =
        oCanvasElement: null
        elements: null

      # Setup the main container node in DOM
      this.domContainerID = this.settings.domContainerID
      
      # Defines if html flowchart node is located in root spot or if it has a parent container
      @hasParentContainer = false
      @containerSelector = options.cssContainerSelector || ''
      @fullSlowchartSelector = @domContainerID
      if document.querySelectorAll(@containerSelector).length == 1 && @containerSelector != ''
        @hasParentContainer = true
        @fullSlowchartSelector = @containerSelector+" "+@domContainerID

      # Config file
      this.config =
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
      new this.core options

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
      this.builder.setup()
      # oCanvas objects were built by using isolated way, because strange behaviour
      # appears when they are built into the scaffold method
      this.builder.createCanvasObjects()
      this.builder.createTools()
      return this

  # Attach the slowchart object to the window object for access outside of this file
  window.slowchart = slowchart

  # Define Object.create if not available
  if typeof Object.create isnt "function"
    Object.create = (o) ->
      F = ->
      F:: = o
      new F()

  builder = ->
    # Return an object when instantiated

    # Check if node ID gave from options points to real node in document, if not, it creates
    # a new main container with id value by default and updates the container. Also, it creates
    # both toolbox and flowspace scaffold
    setup: ->
      # Builds a flowchart div into specific container
      if this.core.hasParentContainer
        parent = document.querySelector(this.core.containerSelector)
      else
        parent = document.body
      flowchartContainer = "<div id='"+this.core.settings.htmlID()+"'></div>"
      this.core.misc.insertElement(flowchartContainer, parent)
      # builds the the toolbox located in left side of page, this contains the flow nodes and some
      # actions to interact between them
      this.core.builder.createScaffold(this.core.domHierarchy.toolBoxClass, this.core.domHierarchy.toolBoxSelector())
      # builds the the flowspace located in right side of page, this contains the flow chart
      this.core.builder.createScaffold(this.core.domHierarchy.flowSpaceClass, this.core.domHierarchy.flowSpaceSelector())
      return

    # Creates the common scaffold to flowspace and toolbox
    createScaffold: (className, selector)->
      mainNode = document.querySelector(this.core.domContainerID)
      spaceElement = "<div class='"+className+"'></div>"
      this.core.misc.insertElement(spaceElement, mainNode)
      canvasElement = "<canvas class='"+this.core.domHierarchy.subcanvasClass+"'></canvas>"
      space = document.querySelector(this.core.domContainerID+' '+selector)
      this.core.misc.insertElement(canvasElement, space)
      return

    createCanvasObjects: ->
      core = this.core
      selector = core.domContainerID + " " + core.domHierarchy.flowSpaceCanvasSelector()
      core.toolbox.oCanvasElement = core.builder.oCanvasFactory(selector)
      selector = core.domContainerID + " " + core.domHierarchy.toolBoxCanvasSelector()
      core.flowspace.oCanvasElement = core.builder.oCanvasFactory(selector)

    # Creates oCanvas object
    oCanvasFactory: (selector)->
      oCanvas.create (
        canvas: selector
        background: "#0cc"
      )

    # creates all necessary tools in flowchart toolbox
    createTools: ->
      canvas = this.core.toolbox.oCanvasElement
      this.core.toolbox.tools.operation = canvas.display.rectangle(
        x: canvas.width / 2
        y: canvas.width / 5
        origin:
          x: "center"
          y: "center"

        width: 300
        height: 40
        fill: "#079"
        stroke: "10px #079"
        join: "round"
      )
      canvas.addChild(this.core.toolbox.tools.operation)

  slowchart.registerModule("builder", builder);

  misc = ->
    # Return an object when instantiated

    # Create a node element based on string definition of object
    # param element [String], element css selector that will be inserted in parent
    # param parent [HTML Node], new parent of html element
    insertElement: (element, parent) ->
      parent.innerHTML = element + parent.innerHTML
      return

  slowchart.registerModule("misc", misc);
) window, document
