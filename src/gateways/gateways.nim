import db_connector/db_sqlite

import db_tables
import queries/queries
import mutations/mutations

type Gateways* = object
  db: DbConn
  queries*: Queries
  mutations*: Mutations

template transaction(self: Gateways, blk: untyped): auto =
  self.db.exec(sql "BEGIN")
  blk
  self.db.exec(sql "COMMIT") 

proc init*(T: type Gateways): T =
  var db = open("data.db", "", "", "")
  result = T(
    db: db,
    queries: Queries.init(db),
    mutations: Mutations.init(db),
  )

when isMainModule:
  var gateways = Gateways.init()
  gateways.db.buildTables()

  gateways.transaction:
    gateways.mutations.status.addStatus("backlog")
    gateways.mutations.status.addStatus("working")
    gateways.mutations.status.addStatus("review")
    gateways.mutations.status.addStatus("completed")
