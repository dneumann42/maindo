import std/[sequtils, sugar]
import db_connector/db_sqlite
import ../../domain/projects
export projects

type ProjectQueries* = object
  db: DbConn

proc init*(T: type ProjectQueries, db: DbConn): T =
  T(db: db)

proc fromRow(T: type Project, row: Row): T =
  result = Project.init(row[0])

proc getProject*(self: ProjectQueries, project_title: string): Project =
  let row =  self.db.getRow(sql "SELECT (title) FROM Project WHERE title = ?", project_title)
  result = Project.fromRow(row)

proc getProjects*(self: ProjectQueries): seq[Project] =
  let rows = self.db.getAllRows(sql "SELECT (title) FROM Project")
  rows.mapIt(Project.fromRow(it))
