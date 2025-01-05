import owlkettle

type NewNoteModel* = object
  buffer: TextBuffer
  monospace: bool = false
  cursorVisible: bool = true
  editable: bool = true
  acceptsTab: bool = true
  indent: int = 0
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1) 
  tooltip: string = "" 

viewable NoteDialog:
  m: NewNoteModel

export NoteDialog, NoteDialogState

viewable NewNote:
  m: NewNoteModel

export NewNote, NewNoteState

proc getText*(state: NewNoteModel): string =
  result = state.buffer.text

method view(self: NewNoteState): Widget =
  let m = self.m
  result = gui:
    Box:
      orient = OrientY
      spacing = 0
      margin = 0

      TextView:
        margin = 4
        buffer = m.buffer
        monospace = m.monospace
        cursorVisible = m.cursorVisible
        editable = m.editable
        acceptsTab = m.acceptsTab
        indent = m.indent
        sensitive = m.sensitive
        tooltip = m.tooltip
        sizeRequest = m.sizeRequest

proc init*(T: type NewNoteModel): T =
  result = T(buffer: newTextBuffer())

proc getText*(state: NoteDialogState): string =
  result = state.m.buffer.text

method view(self: NoteDialogState): Widget =
  result = gui:
    Dialog:
      title = "New Note"
      defaultSize = (320, 320)

      DialogButton {.addButton.}:
        text = "Create"
        style = [ButtonSuggested]
        res = DialogAccept

      DialogButton {.addButton.}:
        text = "Cancel"
        res = DialogCancel

      NewNote(m = self.m)
