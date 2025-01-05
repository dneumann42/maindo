import db_connector/db_sqlite

import ../../domain/notes
export notes

type NoteMutations* = object
  db: DbConn

proc init*(T: type NoteMutations, db: DbConn): T =
  result = T(db: db)

proc addNote*(self: NoteMutations, project_title: string, text: string) =
  self.db.exec(sql """
    INSERT INTO Notes (project_title, text) VALUES (?, ?)
  """, project_title, text) 

proc deleteNote*(self: NoteMutations, note_id: NoteId) =
  self.db.exec(sql """
  DELETE FROM Notes WHERE id = ?
  """, note_id.int)
