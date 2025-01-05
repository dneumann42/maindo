import owlkettle, owlkettle/[playground, adw]

import ui/card

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window(title = "Maindo"):
      defaultSize = (1280, 720)

      HeaderBar {.addTitlebar.}:
        discard

      Grid:
        margin = 12
        rowSpacing = 6
        columnSpacing = 12

        rowHomogeneous = true
        columnHomogeneous = true

        Box {.x: 0, y: 0.}:
          orient=OrientY
          Card() {.expand: false.}

        Box {.x: 1, y: 0.}:
          orient=OrientY

        Box {.x: 2, y: 0.}:
          orient=OrientY

        Box {.x: 3, y: 0.}:
          orient=OrientY
          
when isMainModule:
  adw.brew(gui(App())) 
