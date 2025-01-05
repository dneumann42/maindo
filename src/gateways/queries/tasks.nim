import db_connector/db_sqlite
import ../../domain/tasks
export tasks

type TaskQueries* = object
  db: DbConn

proc init*(T: type TaskQueries, db: DbConn): T =
  result = T(db: db)

method getTasks*(self: TaskQueries): seq[Task] =
  discard
