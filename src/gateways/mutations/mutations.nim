import db_connector/db_sqlite

import tasks, statuses, projects, notes
export tasks, statuses, projects, notes

type Mutations* = object
  task*: TaskMutations
  status*: StatusMutations
  projects*: ProjectMutations
  notes*: NoteMutations

proc init*(T: type Mutations, db: DbConn): T =
  result = T(
    task: TaskMutations.init(db),
    status: StatusMutations.init(db),
    projects: ProjectMutations.init(db),
    notes: NoteMutations.init(db)
  )


