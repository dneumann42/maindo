import db_connector/db_sqlite
import ../../domain/tasks

type TaskMutations* = object
  db: DbConn

proc init*(T: type TaskMutations, db: DbConn): T =
  result = T(db: db)

proc addTask*(self: TaskMutations, project_title: string, title: string, status: Status) =
  self.db.exec(sql """
  INSERT INTO Task (title, status, project_title) VALUES (?, ?, ?)
  """, project_title, title, status.string)
