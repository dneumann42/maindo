import owlkettle, owlkettle/[playground, adw]

import std/[sequtils, algorithm]

import ../domain/[projects, notes]
import ../gateways/gateways
import card, note_dialog

type ProjectViewModel* = object
  gw: Gateways
  project_title: string
  project_notes: seq[Note]

viewable ProjectView:
  m: ProjectViewModel

export ProjectView, ProjectViewState

proc init*(T: type ProjectViewModel, gw: Gateways, project_title: string, project_notes: seq[Note]): T =
  T(gw: gw, project_title: project_title, project_notes: project_notes)

proc queries*(self: ProjectViewState): auto = self.m.gw.queries
proc mutations*(self: ProjectViewState): auto = self.m.gw.mutations

method view(app: ProjectViewState): Widget =
  let project_notes = app.m.project_notes
  let project_title = app.m.project_title

  result = gui:
    Box(orient=OrientX):
      Box(orient=OrientY, spacing=6, margin=6):
        sizeRequest = (200, -1)
      
        for note in project_notes:
          Box(style=[StyleClass("card")]) {.expand: false.}:
            Label(text=note.text)
            Button {.expand: false.}:
              icon = "user-trash-symbolic"
              proc clicked() =
                app.mutations.notes.deleteNote(note.id)

      Separator() {.expand: false.}

      Box(orient=OrientY, spacing=6, margin=6):
        Label(text=project_title) {.expand: false.}
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
