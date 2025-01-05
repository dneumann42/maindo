import statuses
export statuses

type
  TaskId* {.borrow: `hash`.} = distinct int
  Task* = object
    id*: TaskId
    title*: string
    status*: Status

proc init(T: type Task, id: TaskId, title: string, status: Status): T =
  T(id: id, title: title, status: status)
