# Hotloading nimja files

import prologue, gateways, nimja, fsnotify, os
import std / [ htmlgen, strformat, logging, locks, tables ]

import nimja, strformat

var L: Lock

proc templatePath* (name: string): string {.inline.} =
  getScriptDir() / "templates/" & name & ".nimja" 

proc getTemplate* (name: static[string]): string {.gcsafe.} =
  compileTemplateFile(templatePath(name))

# proc startTemplatesWatcher() {.thread.} =
#   withLock L:
#     echo "Starting watcher thread"
#
#   var watcher = initWatcher()
#   proc onTemplateEvent(event: seq[PathEvent]) =
#     for e in event:
#       if e.action == Modify:
#         withLock L:
#           echo "EVENT: "
#           echo event
#
#   watcher.register("src" / "templates", onTemplateEvent)
#
#   while true:
#     sleep(200)
#     watcher.process()
#
# var watcherThread: Thread[void]
# L.initLock()
# watcherThread.createThread(startTemplatesWatcher)
# L.deinitLock()

