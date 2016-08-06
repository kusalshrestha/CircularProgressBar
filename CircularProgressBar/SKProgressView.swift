//
//  SKProgressView.swift
//  CircularProgressBar
//
//  Created by Kusal Shrestha on 7/17/16.
//  Copyright © 2016 Kusal Shrestha. All rights reserved.
//

import UIKit


extension CALayer {
    
    public class func animateWithDuration(duration: NSTimeInterval, animation: () -> Void, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        animation()
        CATransaction.commit()
    }

}

let π: CGFloat = CGFloat(M_PI)

class SKProgressView: UIView {

    var squareBounds = CGRectZero
    var progressBarWidth: CGFloat = 5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var linearProgress: CGFloat = 0 {
        didSet {
            circularProgress = -π / 2 + 2 * π * linearProgress
        }
    }
    
    private var circularProgress: CGFloat = 0 {
        didSet {
            print(circularProgress)
            self.setNeedsDisplay()
        }
    }

    let gradientLayer = CAGradientLayer()
    let progressShapeLayer = CAShapeLayer()
    let endCircle = CAShapeLayer()
    let maskEndCircle = CALayer()
    let insidePadding: CGFloat = 16
    
    // Basic Colors
    let insideCirleFillColor = UIColor ( red: 0.0696, green: 0.1111, blue: 0.157, alpha: 0.7 )
    let circularStrokePathColor = UIColor ( red: 0.1405, green: 0.217, blue: 0.2959, alpha: 1.0 )
    let textColor = UIColor.whiteColor()
    let endCircleColor = UIColor.whiteColor()
    
    // Gradient Colors
    let gradientStartColor = UIColor ( red: 0.7647, green: 0.098, blue: 0.0, alpha: 1.0 )
    let gradientMidColor = UIColor ( red: 1.0, green: 0.8588, blue: 0.0039, alpha: 1.0 )
    let gradientEndColor = UIColor ( red: 0.0235, green: 0.8667, blue: 0.1412, alpha: 1.0 )

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    func setUpView() {
        self.backgroundColor = UIColor.clearColor()
        makeASquareBounds()
        addgradientBackGround()
        endCircleLayer()
    }
    
    func endCircleLayer() {
        maskEndCircle.frame = bounds
        maskEndCircle.backgroundColor = endCircleColor.CGColor
        layer.addSublayer(maskEndCircle)
    }
    
    func addgradientBackGround() {
        /*
          ___________________________________________
         |                    |                      |
         | first HalfGradient | Second Half Gradient |
         |____________________|______________________|
         
         */
        
        let firstHalfGradient = CAGradientLayer()
        let secondHalfGradient = CAGradientLayer()
        
        firstHalfGradient.frame = CGRect(origin: CGPointZero, size: CGSize(width: squareBounds.width / 2, height: squareBounds.height))
        secondHalfGradient.frame = CGRect(origin: CGPoint(x: squareBounds.width / 2, y: 0), size: CGSize(width: squareBounds.width / 2, height: squareBounds.height))
        secondHalfGradient.colors = [gradientStartColor.CGColor, gradientMidColor.CGColor]
        firstHalfGradient.colors = [gradientEndColor.CGColor, gradientMidColor.CGColor]

        secondHalfGradient.locations = [0, 1]
        firstHalfGradient.locations = [0, 1]

        gradientLayer.addSublayer(firstHalfGradient)
        gradientLayer.addSublayer(secondHalfGradient)
        
        gradientLayer.frame = self.squareBounds
        self.layer.addSublayer(gradientLayer)

        progressShapeLayer.fillColor = UIColor.clearColor().CGColor
        progressShapeLayer.strokeColor = UIColor.whiteColor().CGColor
    }
 
    func makeASquareBounds() {
        let width = self.bounds.width > self.bounds.height ? self.bounds.height : self.bounds.width
        squareBounds = CGRect(origin: CGPointZero, size: CGSize(width: width, height: width))
    }
    
    override func drawRect(rect: CGRect) {
       super.drawRect(rect)

        let endCircleSize = CGSize(width: progressBarWidth + 5, height: progressBarWidth + 5)   // small circle at the progress end
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let arcWidth: CGFloat = progressBarWidth
        let radius: CGFloat = (bounds.height - insidePadding) / 2
        let startAngle: CGFloat = -π / 2
        let endAngle: CGFloat = π * 2
        
        // inside fill circle for background color
        let insidePath = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        insidePath.lineWidth = 0.5
        insideCirleFillColor.setFill()
        insidePath.fill()
        
        // circular path
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = arcWidth
        progressShapeLayer.lineWidth = arcWidth
        circularStrokePathColor.setStroke()
        path.stroke()

        // circular progress path
        let progressPath = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: circularProgress,
                                clockwise: true)

        progressPath.lineWidth = arcWidth
        progressPath.lineCapStyle = .Round
        progressShapeLayer.path = progressPath.CGPath
        gradientLayer.mask = progressShapeLayer

        // circle at the end
        /*
         Parametric equation of the circle
         x = cx + r * cos(a)
         y = cy + r * sin(a)
         */
        let centerX = center.x + cos(circularProgress) * radius - endCircleSize.width / 2
        let centerY = center.y + sin(circularProgress) * radius - endCircleSize.width / 2

        let circleCenter = CGPoint(x: centerX, y: centerY)
        let circlePath = UIBezierPath(ovalInRect: CGRect(origin: circleCenter, size: endCircleSize))
        endCircle.path = circlePath.CGPath
        maskEndCircle.mask = endCircle
        
        let ctx = UIGraphicsGetCurrentContext()
        // Copy the path of the shape and turn it into a stroke.
        let shapeCopyPath = CGPathCreateCopyByStrokingPath(progressPath.CGPath, nil, 4, .Butt, .Bevel, 0)
        
        CGContextSaveGState(ctx)
        
        // Add the stroked path to the context and clip to it.
        CGContextAddPath(ctx, shapeCopyPath)
        CGContextClip(ctx)
        
        CGContextRestoreGState(ctx)
        addText(String(Int(linearProgress * 100)))
    }
    
    
    func addText(text: String) {
        let myString: NSString = text as NSString
        var attrib = [NSFontAttributeName: UIFont.boldSystemFontOfSize(25),
                      NSForegroundColorAttributeName: textColor]
        let size: CGSize = myString.sizeWithAttributes(attrib)
        
        var rect = CGRect(origin: CGPoint(x: self.bounds.width / 2 - size.width / 2, y: self.bounds.height / 2 - size.height / 2), size: size)
        text.drawInRect(rect, withAttributes: attrib)
        
        // "/ 100"
        attrib = [NSFontAttributeName: UIFont.systemFontOfSize(12),
                  NSForegroundColorAttributeName: textColor]
        let newSize = "/ 100 ".sizeWithAttributes(attrib)
        rect = CGRect(origin: CGPoint(x: self.bounds.width / 2 - newSize.width / 2, y: self.bounds.height / 2 + size.height / 2 + 2), size: newSize)
        "/ 100".drawInRect(rect, withAttributes: attrib)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bounds = squareBounds
    }
    
}
