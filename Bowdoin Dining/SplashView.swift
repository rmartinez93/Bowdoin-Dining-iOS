//
//  SplashView.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/19/14.
//
//

import Foundation
import QuartzCore
import UIKit

class SplashView : UIView {
    var trueBlue : UIColor = UIColor(red: 0.0, green:0.50, blue:1, alpha:1)
    
    init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        self.setLayerProperties()
        self.animate()
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)  {
        if anim.valueForKey("id").isEqualToString("grow") && flag {
            UIView.animateWithDuration(
                0.2,
                animations: {
                    void in
                    self.alpha = 0
                },
                completion:{
                    bool in
                    self.removeFromSuperview()
                })
        }
    }
    
    override func drawRect(rect: CGRect) {
        var splashImage = UIImage(named: "splash.png")
        var splashView  = UIImageView(image: splashImage)
        splashView.contentMode = UIViewContentMode.ScaleAspectFill
        splashView.clipsToBounds = true
        self.addSubview(splashView)
    }
    
    func setLayerProperties() {
        var layer : CAShapeLayer = self.layer as CAShapeLayer
        var size  : CGFloat = 128
        var centerRect = CGRectMake(self.bounds.size.width/2 - size/2,
            self.bounds.size.height/2 - size/2,
            size,
            size)
        layer.path = UIBezierPath(ovalInRect: centerRect).CGPath
        layer.fillColor = trueBlue.CGColor
    }
    
    func animate() {
        var animation = self.animationWithKeyPath("path")
        animation.setValue("grow", forKey: "id")
        var encompassingRect = CGRectMake(self.bounds.size.width/2-self.bounds.size.height,
            self.bounds.size.height/2-self.bounds.size.height,
            self.bounds.size.height*2,
            self.bounds.size.height*2)
        animation.toValue = UIBezierPath(ovalInRect: CGRectInset(encompassingRect, 4, 4)).CGPath
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func animationWithKeyPath(keyPath : NSString) -> CABasicAnimation {
        var animation = CABasicAnimation(keyPath: keyPath)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        animation.repeatCount = 1
        animation.duration = 0.5
        animation.delegate = self
        
        return animation
    }
}