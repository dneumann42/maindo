import std / [ tables ]
import prologue

type
  MaindoContext* = ref object of Context
    templates*: Table[string, string]

method extend* (ctx: MaindoContext) {.gcsafe.} =
  ctx.templates = initTable[string, string]()
