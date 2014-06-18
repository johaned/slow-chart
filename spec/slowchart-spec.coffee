describe "slowchart engine creation", ->
  initialVariables = {}
  settings = {}
  beforeEach ->
    initialVariables = variables: [
      id: "01b32e025f01f4150"
      name: "first numeric attr"
      type: "integer"
      description: "integer attr"
    ,
      id: "01b32e025f01f4151"
      name: "second numeric attr"
      type: "float"
      description: "float attr"
    ,
      id: "01b32e025f01f4152"
      name: "third numeric attr"
      type: "double"
      description: "double attr"
    ,
      id: "01b32e025f01f4153"
      name: "first string attr"
      type: "string"
      description: "string attr"
    ,
      id: "01b32e025f01f4154"
      name: "second string attr"
      type: "string"
      description: "string attr"
    ,
      id: "01b32e025f01f4155"
      name: "first boolean attr"
      type: "boolean"
      description: "boolean attr"
    ,
      id: "01b32e025f01f4156"
      name: "second boolean attr"
      type: "boolean"
      description: "attr"
    ]
    settings =
      initialVariables: initialVariables.variables
      startNodeName: "start"
      endNodeName: "bind alarm"
      flowchart: "#neo-flowchart"

  afterEach ->
    document.body.innerHTML= ""

  describe "setup", ->
    it "parametrizes the main engine", ->
      flowchart = slowchart.create settings
      expect(flowchart).toBeDefined()
      expect(flowchart.initialVariables.length).toEqual(initialVariables.variables.length)
      expect(flowchart.startNodeName).toEqual(settings.startNodeName)
      expect(flowchart.endNodeName).toEqual(settings.endNodeName)
      expect(flowchart.domContainerSelector).toEqual(settings.flowchart)

    describe "engine initialization when main container does not exists", ->
      beforeEach ->
        @flowchart = slowchart.create settings
        @flowchart.initialize()
      it "checks if the main container is created", ->
        mainNode = document.querySelector("#flowchart")
        expect(mainNode).not.toBe(null);
      it "checks if the toolbox container is created", ->
        toolBox = document.querySelector("#flowchart .toolbox")
        expect(toolBox).not.toBe(null)
      it "checks if the canvas container is created", ->
        canvas = document.querySelector("#flowchart .toolbox .canvas")
        expect(canvas).not.toBe(null)
      it "checks if the flowspace canvas container is created", ->
        canvas = document.querySelector("#flowchart .flowspace .canvas")
        expect(canvas).not.toBe(null)
      it "checks if toolbox canvas has been referenced in flowchart object", ->
        expect(@flowchart.toolbox.oCanvasElement).not.toBe(null)
        expect(@flowchart.toolbox.oCanvasElement).toEqual(jasmine.any(Object))
      it "checks if flowspace canvas has been referenced in flowchart object", ->
        expect(@flowchart.flowspace.oCanvasElement).not.toBe(null)
        expect(@flowchart.flowspace.oCanvasElement).toEqual(jasmine.any(Object))

    describe "engine initialization when main container exists", ->
      beforeEach ->
        div = document.createElement("div")
        div.id = settings.flowchart.replace('#','')
        document.body.appendChild(div)
        @flowchart = slowchart.create settings
        @flowchart.initialize()
      it "checks if the main container is created", ->
        mainNode = document.querySelector(settings.flowchart)
        expect(mainNode).not.toBe(null)
      it "checks if the toolbox container is created", ->
        toolBox = document.querySelector(settings.flowchart + " .toolbox")
        expect(toolBox).not.toBe(null)
      it "checks if the toolbox canvas container is created", ->
        canvas = document.querySelector(settings.flowchart + " .toolbox .canvas")
        expect(canvas).not.toBe(null)
      it "checks if the flowspace canvas container is created", ->
        canvas = document.querySelector(settings.flowchart + " .flowspace .canvas")
        expect(canvas).not.toBe(null)
      it "checks if toolbox canvas has been referenced in flowchart object", ->
        expect(@flowchart.toolbox.oCanvasElement).not.toBe(null)
        expect(@flowchart.toolbox.oCanvasElement).toEqual(jasmine.any(Object))
      it "checks if flowspace canvas has been referenced in flowchart object", ->
        expect(@flowchart.flowspace.oCanvasElement).not.toBe(null)
        expect(@flowchart.flowspace.oCanvasElement).toEqual(jasmine.any(Object))




