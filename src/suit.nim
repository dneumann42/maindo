import system / [ ctypes ]
import std / logging

{.emit: """
#define CLAY_IMPLEMENTATION
#include "clay.h"
"""}

type
  Clay_Arena {.importc, header: "clay.h".} = object
  Clay_Dimensions {.importc, header: "clay.h".} = object
    width, height: float32
  Clay_StringSlice {.importc, header: "clay.h".} = object
    length: cuint
  Clay_TextElementConfig {.importc, header: "clay.h".} = object
    fontSize: uint16
  Clay_ElementDeclaration {.importc, header: "clay.h".} = object
  Clay_ErrorType {.importc, header: "clay.h".} = object
  Clay_String {.importc, header: "clay.h".} = object
    chars: cstring
  Clay_ErrorData* {.bycopy.} = object
    errorType*: Clay_ErrorType
    errorText*: Clay_String
    userData*: pointer
  Clay_ErrorHandler* {.bycopy.} = object
    errorHandlerFunction*: proc (errorText: Clay_ErrorData)
    userData*: pointer
  Clay_Context* {.importc, header: "clay.h".} = object

proc Clay_MinMemorySize(): cuint {.importc.}
proc Clay_CreateArenaWithCapacityAndMemory(capacity: cuint, memory: pointer): Clay_Arena {.importc, header: "clay.h".}
proc Clay_Initialize(arena: Clay_Arena, layoutDimensions: Clay_Dimensions, errorHandler: Clay_ErrorHandler): Clay_Context {.importc.}

proc handleClayErrors(data: Clay_ErrorData) =
  error(data.errorText.chars)

proc measureText(text: Clay_StringSlice, config: ptr Clay_TextElementConfig, userData: pointer): Clay_Dimensions =
  Clay_Dimensions(width: (text.length * config.fontSize).float32, height: config.fontSize.float32)

proc initSuit(screenWidth, screenHeight: int) =
  let totalMemorySize = Clay_MinMemorySize()
  var buffer = newSeq[byte](totalMemorySize)
  let arena: Clay_Arena = Clay_CreateArenaWithCapacityAndMemory(totalMemorySize, addr buffer[0]);
  let ctx = Clay_Initialize(arena, Clay_Dimensions(width: screenWidth.float32, height: screenHeight.float32), 
    Clay_ErrorHandler(errorHandlerFunction: handleClayErrors))

when isMainModule:
  initSuit(1280, 720)
