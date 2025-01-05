import owlkettle
import std/tables
import owlkettle/widgetutils
import owlkettle/bindings/gtk

## TODO implement drag drop

renderable BaseCard of BaseWidget:
  child: Widget

  proc clicked()

  hooks:
    beforeBuild:
      state.internalWidget = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6)

  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_box_append)

  adder add:
    widget.hasChild = true
    widget.valChild = child

type CardModel* = object
  title = ""
  description = ""

proc init*(T: type CardModel, title, description: string): T =
  T(title: title, description: description)

viewable Card:  
  discard

export Card

method view(card: CardState): Widget =
  result = gui:
    Box(style=[StyleClass("card")], orient=OrientY):
      Label(text="Hello, World") 
