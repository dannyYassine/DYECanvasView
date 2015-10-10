//
//  CanvasView.swift
//  CanvasViewExample
//
//  Created by Danny Yassine on 2015-10-09.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

class BrushLayer: CAShapeLayer {
    override init() {
        super.init()
        self.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        self.strokeColor = UIColor.blackColor().CGColor
        self.lineWidth = 5.0
        self.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.fillColor = UIColor.clearColor().CGColor
        self.lineCap = kCALineCapRound
        self.lineJoin = kCALineJoinBevel
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CanvasView: UIView {

    var previousPoint: CGPoint!
    var drawingView: UIView!
    var brush: Brush!
    var layers = [CAShapeLayer]()
    var undoLayers = [CAShapeLayer]()
    var path: UIBezierPath!
    
    func commonInit() {
        
        
        let pan = UIPanGestureRecognizer(target: self, action: "pan:")
        self.addGestureRecognizer(pan)
//        path = UIBezierPath()
//        path.lineWidth = 5.0
//        path.lineCapStyle = CGLineCap.Round
//        path.lineJoinStyle = CGLineJoin.Round
        UIColor.clearColor().setFill()
        UIColor.blackColor().setStroke()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func drawRect(rect: CGRect) {
//        self.path.stroke()
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        
        let location: CGPoint = pan.locationInView(self)
        
        if pan.state == .Began {
            self.drawingView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
            self.addSubview(self.drawingView)
            self.path = UIBezierPath()
        } else if pan.state == .Changed {
            
            
            if self.previousPoint == nil {
                self.previousPoint = location
                path.moveToPoint(location)
            }
            
            let middlePoint = self.getMidPoint(self.previousPoint, secondPoint: location)
            path.addQuadCurveToPoint(middlePoint, controlPoint: self.previousPoint)
            self.previousPoint = location
            self.addNewLayer(path)

            
        } else if pan.state == .Ended {
            // add layers
            
            self.extractDrawingToLayer(self.createNewLayer(path))
            self.previousPoint = nil
            self.path = nil
        }
        
        
    }
    
    func getMidPoint(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        return CGPointMake((firstPoint.x + secondPoint.x) / 2, (firstPoint.y + secondPoint.y) / 2)
    }
    
    func addNewLayer(drawedPath: UIBezierPath) {
        
        let newLayer = BrushLayer()
        newLayer.path = drawedPath.CGPath
        newLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        newLayer.strokeColor = UIColor.blackColor().CGColor
        newLayer.lineWidth = 5.0
        newLayer.fillColor = UIColor.clearColor().CGColor
        newLayer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.drawingView.layer.addSublayer(newLayer)
    }
    
    func createNewLayer(path: UIBezierPath) -> CAShapeLayer {
        
        let newLayer = BrushLayer()
        newLayer.path = path.CGPath
        newLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        newLayer.strokeColor = UIColor.blackColor().CGColor
        newLayer.lineWidth = 5.0
        newLayer.fillColor = UIColor.clearColor().CGColor
        newLayer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        return newLayer
    }
    
    func extractDrawingToLayer(SubLayer: CAShapeLayer) {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawingView.drawViewHierarchyInRect(self.drawingView.bounds, afterScreenUpdates: false)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let layer = BrushLayer()
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.lineWidth = 5.0
        layer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        layer.fillColor = UIColor.clearColor().CGColor
        layer.contents = newImage.CGImage
        self.layers.append(layer)
        self.layer.addSublayer(layer)
        
        self.drawingView.removeFromSuperview()
        self.drawingView = nil
    }
    
    func undo() {
        let layer = self.layers.removeAtIndex(self.layers.count - 1)
        self.undoLayers.append(layer)
        layer.removeFromSuperlayer()
    }
    
    func redo() {
        let layer = self.undoLayers.removeAtIndex(self.undoLayers.count - 1)
        self.layers.append(layer)
        self.layer.addSublayer(layer)
    }

}
