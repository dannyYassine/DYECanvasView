# DYECanvasView (with undos and redos built in)

Add a DYECanvasView as a subview in a Storyboard or programmatically then draw away!

![](https://raw.githubusercontent.com/dannyYassine/DYECanvasView/master/hello.png)

# Undos and Redos
Just call the methods to redo and undo!
    
    // Undo drawed layers
    self.canvasView.undo()
    
    // Redo the layers that were removed
    self.canvasView.redo()
