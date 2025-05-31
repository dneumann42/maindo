import 
  std / [ tables, os, strutils, options, sequtils, sugar ]

type
  ColKind* = enum
    Number
    Text

  Col* = object
    case kind*: ColKind
    of Number:
      number*: float
    of Text:
      text*: string
      
  Row* = object
    cols*: seq[Col] 

  MTable* = Table[string, Row]

  BlockKind* = enum
    Text
    Table

  Block* = object
    case kind*: BlockKind
    of Text:
      text*: string
    of Table:
      header*: Row
      rows*: seq[Row]

  Document* = object
    blocks*: seq[Block]

  MarkdownError* = object of CatchableError

template err* (msg) =
  raise MarkdownError.newException(msg)

proc `$`* (col: Col): string =
  case col.kind:
  of Number:
    $col.number
  of Text:
    col.text

proc `$`* (blk: Block): string =
  if blk.kind == Text:
    return blk.text
  var stbl = @[collect(for h in blk.header.cols: $h)]
  for row in blk.rows:
    stbl.add(collect(for c in row.cols: $c))
  var colWidths = newSeq[int]()
  for colIdx in 0 ..< stbl[0].len:
    var maxWidth = 0
    for rowIdx in 0 ..< stbl.len:
      maxWidth = max(maxWidth, stbl[rowIdx][colIdx].len)   
    colWidths.add(maxWidth)
    for rowIdx in 0 ..< stbl.len:
      stbl[rowIdx][colIdx] = stbl[rowIdx][colIdx].alignleft(maxWidth)
  var lines = collect(
    for line in stbl: "| " & line.join(" | ") & " |")
  var divider = "|" & repeat('-', (lines[0].len) - 2) & "|"
  var cursor = 0
  for w in colWidths:
    cursor += w + 3
    divider[cursor] = '|'
  lines.insert(divider, 1)
  result = lines.join("\n")

proc startChar(line: string): int =
  result = -1
  for i in 0..<line.len:
    if line[i] notin Whitespace:
      return i 

proc skipWhitespace(line: string, cursor: var int) =
  while cursor < line.len and line[cursor] in Whitespace:
    inc cursor

proc identify* (line: string): BlockKind =
  result = Text
  let start = startChar(line)
  if start < 0:
    return
  if line[start] == '|':
    return Table

proc parseText* (lines: seq[string], lineIndex: var int): Block =
  var start = lineIndex
  inc lineIndex
  while lineIndex < lines.len:
    if identify(lines[lineIndex]) != Text:
      break
    inc lineIndex
  let textLines = lines[start ..< lineIndex].toSeq()
  result = Block(
    kind: Text,
    text: textLines.join("\n")
  )

proc parseColumns* (line: string): Row =
  result = Row(cols: @[])
  if line.len == 0:
    return
  var tokens = newSeq[string]()
  var cursor = startChar(line)
  if line[cursor] != '|':
    err("Not a table, expected '|' but got " & $line[cursor])
  cursor += 1
  while cursor < line.len:
    skipWhitespace(line, cursor) 
    var start = cursor
    if line[cursor] == '|':
      tokens.add(line[start ..< cursor])
      cursor += 1
      start = cursor
      continue
    while cursor < line.len and line[cursor] != '|':
      cursor += 1 
    skipWhitespace(line, cursor)
    if cursor >= line.len or line[cursor] == '|':
      let last = 
        if line[cursor] != '|':
          cursor - 1
        else:
          cursor
      tokens.add(line[start ..< last].strip())
      cursor += 1
      start = cursor

  for tok in tokens:
    try:
      result.cols.add(Col(kind: Number, number: parseFloat(tok)))
    except:
      result.cols.add(Col(kind: Text, text: tok))

proc onlyWhitespace(lexeme: string): bool =
  result = true
  for c in lexeme:
    if c notin Whitespace:
      return false

proc parseTable* (lines: seq[string], lineIndex: var int): Block =
  result = Block(kind: Table)
  if lines.len == 0:
    discard
  result.header = parseColumns(lines[lineIndex])
  lineIndex += 2 # TODO: validate the table header divider 
  while lineIndex < lines.len:
    if identify(lines[lineIndex]) != Table:
      break
    result.rows.add(parseColumns(lines[lineIndex]))
    lineIndex += 1

proc parseBlocks* (doc: string): Document =
  result.blocks = @[]
  let lines = doc.split(Newlines)
  var lineIndex = 0
  while lineIndex < lines.len:
    let line = lines[lineIndex]
    let blk = 
      case identify(line):
      of Text:
        parseText(lines, lineIndex)
      of Table:
        parseTable(lines, lineIndex)
    result.blocks.add(blk)

when isMainModule:
  const Doc = """
# Music Albums

| Name                  | Artist            | Rating |
|-----------------------|-------------------|--------|
| Exercises in Futility | Mgła              | 5.0    |
| Reflektor             | Arcade Fire       | 4.65   |
| Vicious Delicious     | Infected Mushroom | 4.5    |
  """

  writeFile("music.md", Doc)

  let doc = parseBlocks(Doc)
  echo doc.blocks[1]
