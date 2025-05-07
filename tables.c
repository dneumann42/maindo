#include "tables.h"
#include <stdio.h>

const char sql[] = R"(
  CREATE TABLE IF NOT EXISTS tasks (
    task_id INTEGER PRIMARY KEY,
    title TEXT UNIQUE
  );
)";

int maindo_create_tables(sqlite3 *db) {
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
