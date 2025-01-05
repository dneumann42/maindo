import db_connector/db_sqlite

type ProjectMutations* = object
  db: DbConn

proc init*(T: type ProjectMutations, db: DbConn): T =
  result = T(db: db)

proc createProject*(self: ProjectMutations, title: string) =
  self.db.exec(sql """
  INSERT INTO Project (title) VALUES (?);
  """, title)
