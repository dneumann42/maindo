{.compile: "clay/clay.c".}

proc Clay_MinMemorySize(): uint64 {.importc.}

# proc handleClayErrors(errorData: Clay_ErrorData) =
#   discard

proc initSuit() =
  let totalMemorySize = Clay_MinMemorySize()
  echo totalMemorySize

when isMainModule:
  initSuit()
