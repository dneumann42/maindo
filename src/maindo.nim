import owlkettle, owlkettle/[playground, adw]

import std/[sequtils, algorithm]

import domain/[projects]
import gateways/gateways
import ui/[card, note_dialog, project_view]

type AppView = enum
  project
  new_note

type AppModel = object
  view: AppView
  gw: Gateways
  current_project: string

viewable App:
  m: AppModel

proc queries*(self: AppState): auto = self.m.gw.queries
proc mutations*(self: AppState): auto = self.m.gw.mutations

method view(app: AppState): Widget =
  let projects = app.queries.projects.getProjects()

  if app.m.current_project == "" and projects.len == 1:
    app.m.current_project = projects[0].name

  let selected_index = projects.mapIt(it.name).find(app.m.current_project)
  let project_title = app.m.current_project

  let project_notes = app.queries.notes.getNotes(project_title)

  result = gui:
    Window:
      defaultSize = (1280, 720)

      HeaderBar {.addTitlebar.}:
        MenuButton {.addLeft.}:
          icon = "list-add-symbolic"
          Popover:
            Box(orient=OrientY, spacing=6, margin=6):
              Button:
                text = "New Project"
              Button:
                text = "New Note"
                proc clicked() =
                  app.m.view = new_note

        DropDown {.addLeft.}:
          items = projects.mapIt(it.name)
          selected = selected_index
          enableSearch = true
      
      case app.m.view:
      of project:
        ProjectView(m = ProjectViewModel.init(app.m.gw, project_title, project_notes))
      of new_note:
        let model = NewNoteModel.init()
        Box:
          orient = OrientY
          margin = 12
          NewNote(m = model)
          Box {.expand: false.}:
            orient = OrientX
            spacing=6
            margin=6
            Button {.expand: false.}:
              text = "Cancel"
              proc clicked() =
                app.m.view = project
            Button {.expand: false.}:
              text = "Create"
              style = [ButtonSuggested]
              proc clicked() =
                let text = model.getText()
                app.mutations.notes.addNote(project_title, text)
                app.m.view = project

when isMainModule:
  let gw = Gateways.init()
  adw.brew(gui(App(m = AppModel(gw: gw)))) 
