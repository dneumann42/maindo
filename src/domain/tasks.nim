import std/macros

import ../lib/constructors
import statuses

type
  Task* = object
    title*: string
    status*: Status
