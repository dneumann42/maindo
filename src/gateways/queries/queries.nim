import db_connector/db_sqlite

import tasks, projects, notes
export tasks, projects, notes

type Queries* = object
  tasks*: TaskQueries 
  projects*: ProjectQueries
  notes*: NoteQueries

proc init*(T: type Queries, db: DbConn): T =
  result = T(
    tasks: TaskQueries.init(db),
    projects: ProjectQueries.init(db),
    notes: NoteQueries.init(db),
  )
