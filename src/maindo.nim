import std / logging
import prologue
import prologue / middlewares / [ utils, staticfile ]
import urls, gateways, templates, maindo_context

var consoleLog = newConsoleLogger()
addHandler(consoleLog)

proc app() =
  let 
    env = loadPrologueEnv(".env")
    settings = newSettings(
      appName = env.getOrDefault("appName", "Prologue"),
      debug = env.getOrDefault("debug", true),
      port = Port(env.getOrDefault("port", 8080)),
      secretKey = env.getOrDefault("secretKey", "")
    )

  createTables()

  var app = newApp(settings = settings)
  app.use(staticFileMiddleware(env.get("staticDir")))
  app.use(debugRequestMiddleware())
  app.addRoute(urls.urlPatterns, "")

  app.run(MaindoContext)

when isMainModule:
  app()
