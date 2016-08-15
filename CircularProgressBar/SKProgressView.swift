//
//  SKProgressView.swift
//  CircularProgressBar
//
//  Created by Kusal Shrestha on 7/17/16.
//  Copyright © 2016 Kusal Shrestha. All rights reserved.
//

import UIKit

// Use this function for animation
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
    var steps = [CAReplicatorLayer]()
    var title = ""
    var showStepsAroundCircle = false
    var progressBarWidth: CGFloat = 5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var linearProgress: CGFloat = 0.25 {
        didSet {
            circularProgress = -π / 2 + 2 * π * linearProgress
        }
    }
    
    private var circularProgress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    static let lineStepSize = CGSize(width: 1.25, height: 15)
    
    let gradientLayer = CAGradientLayer()
    let progressShapeLayer = CAShapeLayer()
    let endCircle = CAShapeLayer()
    let maskEndCircle = CALayer()
    let insidePadding: CGFloat = lineStepSize.height * 2 + 26
    let numberOfSteps: CGFloat = 70
    
    //font
    let ultraLightfont = "HelveticaNeue-UltraLight"
    let Lightfont = "HelveticaNeue-Light"
    
    // Basic Colors
    let insideCirleFillColor = UIColor ( red: 0.086, green: 0.1492, blue: 0.2117, alpha: 1.0 )
    let circularStrokePathColor = UIColor ( red: 0.1405, green: 0.217, blue: 0.2959, alpha: 1.0 )
    let stepDefaultColor = UIColor ( red: 0.3294, green: 0.3961, blue: 0.4471, alpha: 1.0 )
    let textColor = UIColor.whiteColor()
    let endCircleColor = UIColor.whiteColor()
    
    // Gradient Colors
    var gradientStartColor = UIColor ( red: 0.3681, green: 0.5123, blue: 0.4753, alpha: 1.0 )
    var gradientMidColor = UIColor ( red: 0.674, green: 0.9678, blue: 0.5098, alpha: 1.0 )
    var gradientEndColor = UIColor ( red: 0.702, green: 1.0, blue: 0.3624, alpha: 1.0 )
    var isFirstRun = true

    // MARK:- Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    // MARK:- View setup
    
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
    
    // MARK:- Gradient Background
    
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

        secondHalfGradient.locations = [0, 0.9]
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
    
    // MARK:- Drawing function
    
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
        
        /*
         Progress Steps Around the Circle
         */
        if showStepsAroundCircle {
            createProgressStepsAroundCircle(center)
        }
    }
    
    // MARK:- Steps around circle
    
    func createProgressStepsAroundCircle(center: CGPoint) {
        if isFirstRun {
            isFirstRun = false
            for i in 0...Int(numberOfSteps - 1) {
                let lineStep = CAReplicatorLayer()
                steps.append(lineStep)
                lineStep.frame = CGRect(origin: CGPoint(x: bounds.width / 2 - SKProgressView.lineStepSize.width / 2, y: center.y - SKProgressView.lineStepSize.height / 2), size: SKProgressView.lineStepSize)
                lineStep.backgroundColor = stepDefaultColor.CGColor
                //TODO: Anchor point to be make dynamic
                // Anchor point: Hit and trail :P
                lineStep.anchorPoint = CGPoint(x: 0, y: 8)
                lineStep.transform = CATransform3DMakeRotation(CGFloat(i) * π / 180 * (360 / numberOfSteps), 0, 0, 1)
                lineStep.shouldRasterize = true
                lineStep.rasterizationScale = 1
                self.layer.addSublayer(lineStep)
            }
        }
        
        let completedSteps = Int((numberOfSteps - 1) * linearProgress)
        
        for incomplete in completedSteps...Int(numberOfSteps - 1) {
            steps[incomplete].backgroundColor = stepDefaultColor.CGColor
        }
        
        for complete in 0...completedSteps {
            steps[complete].backgroundColor = gradientEndColor.CGColor
        }
        if linearProgress == 0 {
            steps.first!.backgroundColor = stepDefaultColor.CGColor
        }
    }
    
    // MARK:- Text inside Circle
    
    func addText(text: String) {
        //-------------- Progress text
        let myString: NSString = text as NSString
        var attrib = [NSFontAttributeName: UIFont(name: ultraLightfont, size: 65)!,
                      NSForegroundColorAttributeName: textColor]
        let size: CGSize = myString.sizeWithAttributes(attrib)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        
        var rect = CGRect(origin: CGPoint(x: self.bounds.width / 2 - size.width / 2, y: self.bounds.height / 2 - size.height / 2), size: size)
        text.drawInRect(rect, withAttributes: attrib)
        
        //-------------- "/ 100"
        attrib = [NSFontAttributeName: UIFont(name: Lightfont, size: 18)!,
                  NSForegroundColorAttributeName: textColor,
                  NSParagraphStyleAttributeName: style]
        
        var newSize = "/ 100 ".sizeWithAttributes(attrib)
        rect = CGRect(origin: CGPoint(x: self.bounds.width / 2 - newSize.width / 2, y: self.bounds.height / 2 + size.height / 2.2), size: newSize)
        "/100".drawInRect(rect, withAttributes: attrib)
        
        //------------- "Wholeness Score"
        attrib = [NSFontAttributeName: UIFont(name: ultraLightfont, size: 18)!,
                  NSForegroundColorAttributeName: textColor,
                  NSParagraphStyleAttributeName: style]
        
        newSize = title.sizeWithAttributes(attrib)
        rect = CGRect(origin: CGPoint(x: self.bounds.width / 2 - newSize.width / 2, y: newSize.height * 1.25), size: newSize)
        "Wholeness \n Score".drawInRect(rect, withAttributes: attrib)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bounds = squareBounds
    }
    
}
