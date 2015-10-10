//
//  Brush.swift
//  Paddie
//
//  Created by Danny Yassine on 2015-10-01.
//  Copyright © 2015 Danny Yassine. All rights reserved.
//

import UIKit

class Brush: NSObject {

    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var brushWidth: CGFloat!
    var brushOpacity: CGFloat!
    var lineCap: CGLineCap!
    var lineJoin: CGLineJoin!
    var image: UIImage!
    
    var brushColor: UIColor {
        set {
            let newColor = newValue
            newColor.getRed(&self.red!, green: &self.green!, blue: &self.blue!, alpha: &self.brushOpacity!)
        }
        get {
            return UIColor(red: self.red, green: self.green, blue: self.blue, alpha: self.brushOpacity)
        }
    }
    
    override init() {
        super.init()
        
        self.red = 0.0
        self.green = 0.0
        self.blue = 0.0
        self.brushWidth = 2.0
        self.brushOpacity = 1.0
        self.lineCap = CGLineCap.Round
        self.lineJoin = CGLineJoin.Miter
//        self.image = UIImage(named: "brush")
        
    }
    
    
    
}
