type
  NoteId* {.borrow: `hash`.} = distinct int
  Note* = object
    id*: NoteId
    text*: string

proc init*(T: type Note, id: NoteId, text: string): T =
  result = T(id: id, text: text) 
