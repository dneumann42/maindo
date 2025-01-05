type
  Project* = object
    name*: string

proc init*(T: type Project, name: string): T =
  result = T(name: name)

