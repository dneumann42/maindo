import std / parseopt

import markdown

proc cli () =
  let lines = @[" ### Hello"]

when isMainModule:
  cli()
