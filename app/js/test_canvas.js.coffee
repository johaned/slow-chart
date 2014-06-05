###
Created by johaned on 11/27/13.
###
#$(window).load ->
#  canvas = oCanvas.create(canvas: "#canvas")
#  button = canvas.display.rectangle(
#    x: canvas.width / 2
#    y: canvas.width / 5
#    origin:
#      x: "center"
#      y: "center"
#
#    width: 300
#    height: 40
#    fill: "#079"
#    stroke: "10px #079"
#    join: "round"
#  )
#  buttonText = canvas.display.text(
#    x: 0
#    y: 0
#    origin:
#      x: "center"
#      y: "center"
#
#    align: "center"
#    font: "bold 25px sans-serif"
#    text: "Toggle Rotation"
#    fill: "#fff"
#  )
#  button.addChild buttonText
#  arc = canvas.display.arc(
#    x: canvas.width / 3.5
#    y: button.y + 150
#    radius: 60
#    start: 40
#    end: 260
#    fill: "#079"
#    pieSection: true
#  )
#  pentagon = canvas.display.polygon(
#    x: canvas.width / 1.5
#    y: arc.y
#    sides: 5
#    radius: 60
#    fill: "#18a"
#  )
#  hexagon = pentagon.clone(
#    sides: 6
#    x: arc.x
#    y: pentagon.y + 180
#    fill: "#29b"
#  )
#  heptagon = pentagon.clone(
#    sides: 7
#    x: pentagon.x
#    y: hexagon.y
#    fill: "#3ac"
#  )
#  canvas.addChild arc
#  canvas.addChild pentagon
#  canvas.addChild hexagon
#  canvas.addChild heptagon
#  canvas.addChild button
#  dragOptions = changeZindex: true
#  arc.dragAndDrop dragOptions
#  pentagon.dragAndDrop dragOptions
#  hexagon.dragAndDrop dragOptions
#  heptagon.dragAndDrop dragOptions
#  canvas.setLoop ->
#    arc.rotation++
#    pentagon.rotation--
#    hexagon.rotation++
#    heptagon.rotation--
#
#  button.bind "click tap", ->
#    if canvas.timeline.running
#      canvas.timeline.stop()
#    else
#      canvas.timeline.start()