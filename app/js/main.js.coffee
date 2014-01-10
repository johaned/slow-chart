###
Created by johaned on 12/15/13.
###
window.slowchart = do ->
  Slowchart = (els) ->
    console.log('test from constructor')
  slowchart =
    # Define the core class
    core: (settings) ->
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

    create: (settings) ->
      new slowchart.core settings
  slowchart
