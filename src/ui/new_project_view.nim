import owlkettle

type NewProjectModel* = object
  title*: string

viewable NewProject:
  m: NewProjectModel

export NewProject, NewProjectState

proc init*(T: type NewProjectModel): T = 
  T()

method view(self: NewProjectState): Widget = 
  result = gui:
    Box:
      orient = OrientY
      spacing = 4
      margin = 12

      Entry {.expand: false.}:
        text = self.m.title
        proc changed(new_title: string) =
          self.m.title = new_title
