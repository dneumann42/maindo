import std / [sets, hashes]

type
  Status* {.borrow: `hash`.} = distinct string
  Statuses* = object
    keys: HashSet[Status] 
