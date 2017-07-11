//
//  resurrectCountDownCircle.swift
//  tri-tri
//
//  Created by mac on 2017-07-11.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
import SpriteKit

class resurrectCountDownCircle: SKScene{
    
    func pause_screen_x_transform(_ x: Double) -> CGFloat {
        let const = x/Double(375)
        let new_x = Double((view?.frame.width)!)*const
        return CGFloat(new_x)
        
    }
    func pause_screen_y_transform(_ y: Double) -> CGFloat {
        let const = y/Double(667)
        let new_y = Double((view?.frame.height)!)*const
        return CGFloat(new_y)
    }
    
    override func didMove(to:SKView) {
        
        let circle = SKShapeNode(circleOfRadius: 125)
        circle.fillColor = UIColor(red:CGFloat(0/255.0), green:CGFloat(0/255.0), blue:CGFloat(0/255.0), alpha:CGFloat(0.5))
        circle.strokeColor = SKColor.clear
        circle.zRotation = CGFloat.pi / 2
        addChild(circle)
        
        countdown(circle: circle, steps: 20, duration: 5) {
            print("done")
        }
    }
    
    // Creates an animated countdown timer
    func countdown(circle:SKShapeNode, steps:Int, duration:TimeInterval, completion:@escaping ()->Void) {
        guard let path = circle.path else {
            return
        }
        let radius = path.boundingBox.width/2
        let timeInterval = duration/TimeInterval(steps)
        let incr = 1 / CGFloat(steps)
        var percent = CGFloat(1.0)
        
        let animate = SKAction.run {
            percent -= incr
            circle.path = self.circle(radius: radius, percent:percent)
        }
        let wait = SKAction.wait(forDuration:timeInterval)
        let action = SKAction.sequence([wait, animate])
        
        run(SKAction.repeat(action,count:steps-1)) {
            self.run(SKAction.wait(forDuration:timeInterval)) {
                circle.path = nil
                completion()
            }
        }
    }
    
    // Creates a CGPath in the shape of a pie with slices missing
    func circle(radius:CGFloat, percent:CGFloat) -> CGPath {
        let start:CGFloat = 0
        let end = CGFloat.pi * 2 * percent
        let center = CGPoint(x: 125, y: -125)
        let bezierPath = UIBezierPath()
        bezierPath.move(to:center)
        bezierPath.addArc(withCenter:center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        bezierPath.addLine(to:center)
        return bezierPath.cgPath
    }
}
