//
//  ViewController.swift
//  CanvasViewExample
//
//  Created by Danny Yassine on 2015-10-09.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var canvasView: CanvasView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let doubleTap = UITapGestureRecognizer(target: self, action: "undoButton")
        doubleTap.numberOfTapsRequired = 2

        let longPress = UILongPressGestureRecognizer(target: self, action: "redo")
        longPress.minimumPressDuration = 0.5
        
        self.view.addGestureRecognizer(doubleTap)
        self.view.addGestureRecognizer(longPress)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        let image = self.canvasView.extractDrawing()
        self.canvasView.previousView.image = image
    }

    func undoButton() {
        self.canvasView.undo()
    }

    func redo() {
        self.canvasView.redo()
    }
}

