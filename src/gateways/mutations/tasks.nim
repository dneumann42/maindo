import db_connector/db_sqlite
import ../../domain/tasks

type TaskMutations* = object
  db: DbConn

proc init*(T: type TaskMutations, db: DbConn): T =
  result = T(db: db)

proc addTask*(self: TaskMutations, task: Task) =
  discard
