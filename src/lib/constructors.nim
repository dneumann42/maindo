import std / macros

macro ini*(t) =
  quote do:
    proc init*(T: type `t`): auto =
      result = T.default()
