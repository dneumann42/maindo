import db_connector/db_sqlite

import tasks, statuses
export tasks, statuses

type Mutations* = object
  task*: TaskMutations
  status*: StatusMutations

proc init*(T: type Mutations, db: DbConn): T =
  result = T(
    task: TaskMutations.init(db),
    status: StatusMutations.init(db)
  )


