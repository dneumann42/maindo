import markdown, strutils

import db_connector/[db_sqlite]

type ScriptKind* = enum
  Create
  Update
  Insert
  Delete

proc getColumnType(kind: ColKind): string =
  case kind
  of Number: "FLOAT"
  of Text: "TEXT"

proc sql*(blk: Block, name: string, kind: ScriptKind): seq[SqlQuery] =
  assert(blk.kind == Table)

  if blk.rows.len == 0:
    return

  var lines = @["CREATE TABLE IF NOT EXISTS " & name & "("]
  for i in 0 ..< blk.header.cols.len:
    let headerName = blk.header.cols[i].text.strip()
    let valueCol = blk.rows[0].cols[i]
    let colType = valueCol.kind.getColumnType()
    var line = headerName & " " & colType
    if i < blk.header.cols.len - 1:
      line &= ","
    lines.add(line)
  lines.add(");")
  result.add(sql lines.join("\n"))

  for rowIdx in 0 ..< blk.rows.len:
    var line = "INSERT INTO " & name & " VALUES ("
    var values = newSeq[string]()
    for i in 0 ..< blk.header.cols.len:
      let headerName = blk.header.cols[i].text.strip()
      let valueCol = blk.rows[rowIdx].cols[i]
      case valueCol.kind
      of Number:
        values.add($valueCol.number)
      of Text:
        values.add("'" & valueCol.text & "'")
    line &= values.join(", ")
    result.add(sql(line & ");"))
