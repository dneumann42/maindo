import std/[sequtils, sugar, strutils]
import db_connector/db_sqlite
import ../../domain/notes
export notes

type NoteQueries* = object
  db: DbConn

proc init*(T: type NoteQueries, db: DbConn): T =
  T(db: db)

proc fromRow(T: type Note, row: Row): T =
  let id = row[0].parseInt.NoteId
  result = Note.init(id, row[1])

proc getNotes*(self: NoteQueries, project_title: string): seq[Note] =
  let rows = self.db.getAllRows(
    sql "SELECT id, text FROM Notes WHERE project_title = ?", project_title)
  rows.mapIt(Note.fromRow(it))
