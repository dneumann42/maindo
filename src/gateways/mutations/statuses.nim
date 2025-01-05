import db_connector/db_sqlite

type StatusMutations* = object
  db: DbConn

proc init*(T: type StatusMutations, db: DbConn): T =
  result = T(db: db)

proc addStatus*(self: StatusMutations, status: string) =
  self.db.exec(sql """
    INSERT OR IGNORE INTO Status (title) VALUES (?);
  """, status) 
