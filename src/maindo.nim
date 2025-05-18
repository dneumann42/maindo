import coral

type
  WorkspacePlugin = ref object of Plugin

method load(p: WorkspacePlugin) =
  discard

method update(p: WorkspacePlugin) =
  discard

method render(p: WorkspacePlugin, artist: Artist) =
  let (ww, wh) = artist.windowSize()
  artist.rect(0, 0, ww.toFloat, wh.toFloat, filled = true, color=DarkBlue)

  # draw grid
  for x in 0 .. 100:
    artist.line(x.float * 32.0, 0.0, x.float * 32.0, wh.float, color=Blue)

  for y in 0 .. 100:
    artist.line(0.0, y.float * 32.0, ww.float, y.float * 32.0, color=Blue)

when isMainModule:
  var cfg = ApplicationConfig(width: 1280, height: 720)
  var app = Application.init(cfg).get()
  app
    .add(WorkspacePlugin())
    .run()
