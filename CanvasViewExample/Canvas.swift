//
//  Canvas.swift
//  Paddie
//
//  Created by Danny Yassine on 2015-10-01.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

class Canvas: UIView {

    var lastPoint: CGPoint!
    var swiped: Bool!
    var opacity: CGFloat!
    
    var currentBrush: Brush!
    
    var tempImageView: UIImageView!
    var mainImageView: UIImageView!
    var previewImageView: UIImageView!
    
    var tempShapeLayer: CAShapeLayer!
    var mainShapeLayer: CAShapeLayer!
    var previewShapeLayer: CAShapeLayer!
    
    var normalFrame: CGRect!
    
    var points = [CGPoint](count:5, repeatedValue: CGPoint.zero)
    var count: Int = 0
    var averageVelocity: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.lastPoint = CGPoint.zero
        self.currentBrush = Brush()
        self.opacity = 1.0
        self.swiped = false
        self.mainImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        self.mainImageView.contentMode = .ScaleAspectFit
        
        let pan = UIPanGestureRecognizer(target: self, action: "panInCanvas:")
        self.addGestureRecognizer(pan)
        
        self.mainImageView = UIImageView(frame: self.bounds)
        self.addSubview(self.mainImageView)
        
        self.previewImageView = UIImageView(frame: self.bounds)
        self.previewImageView.alpha = 0.5
        self.addSubview(self.previewImageView)
        self.normalFrame = self.frame
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.lastPoint = CGPoint.zero
        self.currentBrush = Brush()
        self.opacity = 1.0
        self.swiped = false
        self.mainImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        self.mainImageView.contentMode = .ScaleAspectFit
        
        let pan = UIPanGestureRecognizer(target: self, action: "panInCanvas:")
        self.addGestureRecognizer(pan)
        
        self.mainImageView = UIImageView(frame: self.bounds)
        self.addSubview(self.mainImageView)
        
        self.previewImageView = UIImageView(frame: self.bounds)
        self.previewImageView.alpha = 0.5
        self.addSubview(self.previewImageView)
        self.normalFrame = self.frame
        
    }
    
    override func layoutSubviews() {
        self.mainImageView.frame = self.bounds
        self.previewImageView.frame = self.bounds
        
        if self.tempImageView != nil {
            self.tempImageView.frame = self.bounds
        }

    }
    
    func panInCanvas(pan: UIPanGestureRecognizer) {
        
        let location = pan.locationInView(pan.view)
        let velocity = pan.velocityInView(pan.view)
        
        if pan.state == UIGestureRecognizerState.Began {
            
            self.swiped = false
            // User is continuning drawing and hasnt saved the frame yet
            // We enter IF if the user started a new frame drawing
            if self.tempImageView == nil {
                self.tempImageView = UIImageView(frame: self.bounds)
                self.insertSubview(self.tempImageView, aboveSubview: self.previewImageView)
            }
            
            self.count = 0
            
            self.lastPoint = location
            
            self.points[0] = location
            
        } else if pan.state == UIGestureRecognizerState.Changed {
            
            self.swiped = true
            let currentPoint = location
            self.drawLine(fromPoint: self.lastPoint, toPoint: currentPoint, inView: self, withVelocity: velocity)
            
            self.lastPoint = currentPoint
            
        } else if pan.state == UIGestureRecognizerState.Ended {
            if !self.swiped {
                self.drawLine(fromPoint: self.lastPoint, toPoint: self.lastPoint, inView: self, withVelocity: velocity)
            }
            self.count = 0
        }
        
    }
    
    func drawLine(fromPoint fromPoint: CGPoint, toPoint: CGPoint, inView view: UIView, withVelocity velocity: CGPoint) {
        
        let resultant = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
        
        let ratio =  resultant / 2000.0 // trial and error
        let additionalWidth = (ratio * self.currentBrush.brushWidth)
        
        print(self.count)
        self.count = self.count + 1
        self.points[self.count] = fromPoint

        if self.count == 4 {
            
        self.points[3] = CGPointMake((self.points[2].x + self.points[4].x)/2, (self.points[2].y + self.points[4].y)/2)
            
            
        let bezier = UIBezierPath()

        bezier.moveToPoint(self.points[0])
        bezier.addCurveToPoint(self.points[3], controlPoint1: self.points[1], controlPoint2: self.points[2])
            
        let tempShapeLayer1 = CAShapeLayer()
        tempShapeLayer1.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tempShapeLayer1.path = bezier.CGPath
        
        tempShapeLayer1.lineCap = kCALineCapRound
        tempShapeLayer1.lineWidth = self.currentBrush.brushWidth + additionalWidth
        tempShapeLayer1.strokeColor = self.currentBrush.brushColor.CGColor
        tempShapeLayer1.lineJoin = kCALineJoinBevel
        tempShapeLayer1.fillColor = UIColor.clearColor().CGColor
        tempShapeLayer1.anchorPoint = CGPointMake(0.0, 0.0)
        tempShapeLayer1.shouldRasterize = true
        tempShapeLayer1.rasterizationScale = UIScreen.mainScreen().scale

        self.tempImageView.layer.addSublayer(tempShapeLayer1)
        
            self.points[0] = self.points[3]
            self.points[1] = self.points[4]
            self.count = 1
            
        }
    }

    func setDrawingToMainCanvas() {
        
        // Defensive Code, in case we add a camera picture first.
        if self.tempImageView != nil {
            UIGraphicsBeginImageContextWithOptions(self.tempImageView.bounds.size, false, UIScreen.mainScreen().scale)
            self.mainImageView.image?.drawInRect(self.mainImageView.bounds, blendMode: CGBlendMode.Normal, alpha: self.opacity)
            self.tempImageView.drawViewHierarchyInRect(self.tempImageView.bounds, afterScreenUpdates: false)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.mainImageView.image = nil
            self.mainImageView.image = newImage
            
            self.tempImageView.removeFromSuperview()
            self.tempImageView = nil
        } else {
            // no drawing was done
        }
        
    }
    
    func goFullScreenMode() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        self.layoutSubviews()
    }
    
    func goToEditMode() {
        self.frame = self.normalFrame
        self.layoutSubviews()
    }
    
}
