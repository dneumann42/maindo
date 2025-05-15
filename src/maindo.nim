import coral

const Width = 1280
const Height = 720

type
  MaindoApp = ref object of CanvasPlugin

proc init* (T: type MaindoApp, canvas: Canvas): T =
  result = T(canvas: canvas)

method load(self: MaindoApp) =
  echo "Loaded the main app"

method render(self: MaindoApp, artist: Artist) =
  self.canvas.color = Transparent
  artist.canvas(self.canvas):
    artist.debugText("Hello", 1.0, 1.0)

proc start =
  let config = ApplicationConfig(width: Width, height: Height, organization: "dneumann", name: "Maindo")

  var app = Application
    .init(config)
    .get()

  app
    .add(MaindoApp.init(app.artist.newCanvas(Width, Height)))
    .run()

when isMainModule:
  start()
