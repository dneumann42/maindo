#include "tables.h"
#include <stdio.h>

#define SQL(s) #s

const char sql[] =
    SQL(CREATE TABLE IF NOT EXISTS libraries(name TEXT UNIQUE PRIMARY KEY);
        CREATE TABLE IF NOT EXISTS modules(
            name TEXT UNIQUE PRIMARY KEY, library_name TEXT,
            FOREIGN KEY(library_name) REFERENCES libraries(name));
        CREATE TABLE IF NOT EXISTS functions(name TEXT UNIQUE PRIMARY KEY,
                                             body TEXT));

int maindo_create_tables(sqlite3 *db) {
  sqlite3_exec(db, "PRAGMA foreign_keys = ON;", NULL, NULL, NULL);

  char *err_msg = NULL;
  int rc = sqlite3_exec(db, sql, 0, 0, &err_msg);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "SQL error: %s\n", err_msg);
    sqlite3_free(err_msg);
    return 1;
  }
  printf("Initialized tables.\n");
  return 0;
}
