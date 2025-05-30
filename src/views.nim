import prologue, gateways, nimja
import std / [ htmlgen, strformat ]

import templates, maindo_context

const Htmx = htmlgen.script(
  src="https://unpkg.com/htmx.org@2.0.4",
  crossorigin="anonymous"
)

proc indexView* (): string {.gcsafe.} =
  getTemplate("index")

proc index* (ctx: Context) {.async, gcsafe.} =
  resp htmlResponse(indexView())

proc newLibrary* (ctx: Context) {.async.} =
  let m = ctx.request.reqMethod
  resp htmlResponse(&""" {m} """)
