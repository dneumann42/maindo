import db_connector/db_sqlite

import tasks
export tasks

type Queries* = object
  task*: TaskQueries 

proc init*(T: type Queries, db: DbConn): T =
  result = T(
    task: TaskQueries.init(db)
  )
