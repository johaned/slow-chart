describe "slowchart", ->
  initialVariables = undefined
  startNodeName = undefined
  endNodeName = undefined
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
    startNodeName = "start"
    endNodeName = "bind alarm"
  describe "create", ->
    it "parametrizes the slowchart engine", ->
      slowchart.create initialVariables, startNodeName, endNodeName



