import std / [ parseopt, os, options, strutils, enumerate ]
import db_connector / [ db_sqlite ]

import markdown, sql, pretty

proc format(files: seq[string]) =
  for file in files:
    let contents = readFile(file)
    let doc = parseBlocks(contents)
    writeFile(file, $doc)

let db = open(":memory:", "", "", "")

proc execute(file: string, codeBlockName: string) =
  let contents = readFile(file)
  var doc = parseBlocks(contents)
  var newBlocks = newSeq[Block]()
  var replaceNext = none(Block)

  proc findTableName(i: int): Option[string] =
    if i <= 0: return
    for idx in countdown(i - 1, 0):
      let prev = doc.blocks[idx]
      if prev.kind != Heading:
        continue
      return prev.heading.strip().some()

  for i in 0 ..< doc.blocks.len:
    let b = doc.blocks[i]

    if replaceNext.isSome():
      newBlocks.add(replaceNext.get())
      replaceNext = none(Block)
      continue

    if b.kind == Table:
      let maybeTableName = findTableName(i)
      if maybeTableName.isNone:
        continue

      if i > 0 and doc.blocks[i - 1].kind == Code:
        continue

      let tableName = maybeTableName.get()
      let queries = b.sql(tableName, Create)
      for query in queries:
        try:
          db.exec(query)
        except:
          stderr.writeLine(getCurrentExceptionMsg())
          print queries
      newBlocks.add(b)
    elif b.kind == Code and b.lang == "sql":
      newBlocks.add(b)

      let codeName = findTableName(i).get("")
      let rows = db.getAllRows(sql(b.code))
      
      var resultsTable = Block(kind: Table)
      for row in rows:
        var rrow = markdown.Row()
        if resultsTable.header.cols.len == 0:
          for idx, col in enumerate(row): 
            resultsTable.header.cols.add(
              Col(kind: Text, text: "_"& $idx))
        for col in row: 
          var ccol = Col(kind: Text, text: col)
          rrow.cols.add(ccol)
        resultsTable.rows.add(rrow)

      let queries = resultsTable.sql(codeName, Create)
      for query in queries:
        try:
          db.exec(query)
        except:
          stderr.writeLine(getCurrentExceptionMsg())
          print queries

      # replace or insert results table
      if i < doc.blocks.len - 1:
        let next = doc.blocks[i + 1]
        if next.kind == Table:
          replaceNext = some(resultsTable)
        else:
          newBlocks.add(resultsTable)
    else:
      newBlocks.add(b)

  doc.blocks = newBlocks
  writeFile(file, $doc)

proc cli () =
  let lines = @[" ### Hello"]
  let params = commandLineParams()
  var p = initOptParser(params)

  var files = newSeq[string]()
  var shouldParse = false
  var executeBlock: Option[string]

  while true:
    p.next()
    case p.kind:
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      if p.key == "f" or p.key == "format":
        shouldParse = true
      if p.key == "e":
        executeBlock = some(p.val)
          
    of cmdArgument:
      files.add(p.key)

  if shouldParse:
    format(files)

  if executeBlock.isSome() and files.len > 0:
    execute(files[0], executeBlock.get())

when isMainModule:
  cli()
