###
Created by johaned on 12/15/13.
###
window.slowchart = do ->
  Slowchart = (els) ->
    console.log('test from constructor')
  slowchart =
    modules: {}
    # Define the core class
    core: (settings) ->
      settings = settings || {}

      # Initializes a array of initial variables that will be loaded in the components
      # of flow chart, this variables are loaded through create function as a parameter
      # assignment agent which could received the data from Rest API
      this.initialVariables = settings.initialVariables || []

      # start node Name that will be show in main gui into workspace, this can be changed
      # from settings obteined from create function
      this.startNodeName = settings.startNodeName || "start node"

      # start node Name that will be show in main gui into workspace, this can be changed
      # from settings obteined from create function
      this.endNodeName = settings.endNodeName || "end node"

      # Add the registered modules to the new instance of core
      for m of slowchart.modules
        if typeof slowchart.modules[m] is "function"
          this[m] = slowchart.modules[m]()
        else
          this[m] = Object.create(slowchart.modules[m])

      # Set the core instance in all modules to enable access of core properties inside of modules
      for m of slowchart.modules
      
        # Add core access to modules in a wrapper module (like display objects that reside in the wrapper display)
        if this[m].wrapper is true
          for wm of this[m]
            if typeof this[m][wm] is "object" and typeof this[m][wm].setCore is "function"
              this[m][wm] = this[m][wm].setCore(this)
            else this[m][wm].setCore this  if typeof this[m][wm].setCore is "function"
            this[m].core = this
      
        # Add core access to modules that reside directly in the core
        this[m].core = this
      
      # Initialize added modules that have registered init methods
      for name of slowchart.inits
      
        # Modules directly on the slowchart object
        if (typeof slowchart.inits[name] is "string") and (typeof this[name][slowchart.inits[name]] is "function")
          this[name][slowchart.inits[name]]()
      
          # Modules that are parts of a wrapper module
        else if slowchart.inits[name] is "object"
          for subname of slowchart.inits[name]
            this[name][slowchart.inits[name][subname]]()  if typeof this[name][slowchart.inits[name][subname]] is "function"

      return
    create: (settings) ->
      new slowchart.core settings
    registerModule: (name, module, init) ->
      if ~name.indexOf(".")
        parts = name.split(".")
        slowchart.modules[parts[0]][parts[1]] = module
        if init isnt `undefined`
          slowchart.inits[parts[0]] = {}  unless slowchart.inits[parts[0]]
          slowchart.inits[parts[0]][parts[1]] = init
      else
        slowchart.modules[name] = module
        slowchart.inits[name] = init  if init isnt `undefined`

  slowchart.core.prototype =
    build: ->

  slowchart
