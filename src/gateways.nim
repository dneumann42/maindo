import db_connector / db_sqlite
import std / strformat

let db = open("maindo.db", "", "", "")

proc createTables* () =
  db.exec(sql"""
    CREATE TABLE IF NOT EXISTS libraries (
      name VARCHAR(256) PRIMARY KEY NOT NULL
    );
  """)

proc createLibrary* (name: string) =
  db.exec(sql(&"""
    INSERT INTO libraries (name) VALUES ('{name}');
  """))
