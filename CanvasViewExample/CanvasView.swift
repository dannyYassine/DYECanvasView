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
        self.lineWidth = 2.0
        self.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.fillColor = UIColor.clearColor().CGColor
        self.lineCap = kCALineCapRound
        self.lineJoin = kCALineJoinBevel
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DrawView: UIView {
    
    var drawPath: UIBezierPath!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.drawPath = UIBezierPath()
        self.drawPath = UIBezierPath()
        self.drawPath.lineWidth = 2.0
        self.drawPath.lineCapStyle = CGLineCap.Round
        self.drawPath.lineJoinStyle = CGLineJoin.Round
        UIColor.clearColor().setFill()
        UIColor.blackColor().setStroke()
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.drawPath.stroke()
    }
}

class CanvasView: UIView {

    var previousPoint: CGPoint!
    var drawingView: DrawView!
    var brush: Brush!
    var layers = [CAShapeLayer]()
    var undoLayers = [CAShapeLayer]()
    
    func commonInit() {
        
        let pan = UIPanGestureRecognizer(target: self, action: "pan:")
        
        self.drawingView = DrawView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.addSubview(self.drawingView)
        self.drawingView.addGestureRecognizer(pan)

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        
        let location: CGPoint = pan.locationInView(self)
        
        if pan.state == .Began {

        } else if pan.state == .Changed {
            
            
            if self.previousPoint == nil {
                self.previousPoint = location
                self.drawingView.drawPath.moveToPoint(location)
            }
            
            let middlePoint = self.getMidPoint(self.previousPoint, secondPoint: location)
            self.drawingView.drawPath.addQuadCurveToPoint(middlePoint, controlPoint: self.previousPoint)
            self.previousPoint = location
//            self.addNewLayer(self.drawingView.drawPath)
            
            self.drawingView.setNeedsDisplay()
            
        } else if pan.state == .Ended {
            // add layers
            
            self.extractDrawingToLayer()
            self.previousPoint = nil
            
            self.drawingView.drawPath = UIBezierPath()
            self.drawingView.setNeedsDisplay()
            
        }
        
        
    }
    
    func getMidPoint(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        return CGPointMake((firstPoint.x + secondPoint.x) / 2, (firstPoint.y + secondPoint.y) / 2)
    }
    
    func addNewLayer(drawedPath: UIBezierPath) {
        
//        let newLayer = BrushLayer()
//        newLayer.path = drawedPath.CGPath
//        newLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
//        newLayer.strokeColor = UIColor.blackColor().CGColor
//        newLayer.lineWidth = 5.0
//        newLayer.fillColor = UIColor.clearColor().CGColor
//        newLayer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
//        self.drawingView.layer.addSublayer(newLayer)
    }
    
    func extractDrawingToLayer() {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawingView.drawViewHierarchyInRect(self.drawingView.bounds, afterScreenUpdates: false)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let layer = BrushLayer()
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.lineWidth = self.drawingView.drawPath.lineWidth
        layer.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        layer.fillColor = UIColor.clearColor().CGColor
        layer.contents = newImage.CGImage
        self.layers.append(layer)
        self.layer.addSublayer(layer)
        
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
