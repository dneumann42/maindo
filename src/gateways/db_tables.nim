import db_connector/db_sqlite

const Script = staticRead("sql/tables.sql")

proc buildTables*(db: DbConn) =
  db.exec(sql Script) 
