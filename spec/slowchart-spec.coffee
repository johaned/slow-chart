describe "slowchart", ->
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
      flowchart: "#flowchart"
  describe "create", ->
    it "parametrizes the main engine", ->
      flowchart = slowchart.create settings
      expect(flowchart).toBeDefined()
      expect(flowchart.initialVariables.length).toEqual(7)
      expect(flowchart.startNodeName).toEqual("start")
      expect(flowchart.endNodeName).toEqual("bind alarm")
      expect(flowchart.domContainerSelector).toEqual("#flowchart")
    it "initializes the main engine", ->
      flowchart = slowchart.create settings
      flowchart.initialize()
      mainNode = document.getElementById("flowchart")
      expect(mainNode).toBeDefined()





