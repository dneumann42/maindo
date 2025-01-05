import db_connector/db_sqlite
import ../../domain/tasks
export tasks

type TaskQueries* = object
  db: DbConn

proc init*(T: type TaskQueries, db: DbConn): T =
  result = T(db: db)

proc getTasks*(self: TaskQueries, project_title: string): seq[Task] =
  let rows = self.db.getAllRows(sql """
  SELECT (id, title, status) FROM Task WHERE project_title = ?
  """, project_title)
