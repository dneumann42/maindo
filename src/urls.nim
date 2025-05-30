import prologue
import views

const urlPatterns* = @[
  pattern("/", index),
  pattern("/api/library/new", newLibrary),
]
