//
//  Common.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 19/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import CoreGraphics
import GameplayKit
import UIKit

public struct NamedGoal
{
    let name: String
    let goal: GKGoal

    var weight: Float
    var weightMultiplier: Float
    
    init(name: String, goal: GKGoal, weight: Float, weightMultiplier: Float = 1)
    {
        self.name = name
        self.goal = goal
        self.weight = weight
        self.weightMultiplier = weightMultiplier
    }
}

extension CGPoint
{
    func offset(dx: Float, dy: Float) -> CGPoint {
        return offset(dx: CGFloat(dx), dy: CGFloat(dy))
    }
    
    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x - dx, y: y - dy)
    }
}

extension UIBezierPath {
    func appendCircleOfRadius(radius: Float, atPosition position: vector_float2, inFrame frame: CGRect) {
        let position = CGPoint(x: frame.width / 2 + CGFloat(position.x),
            y: frame.height / 2 + CGFloat(position.y))
        
        let circle = UIBezierPath(ovalIn: CGRect(origin: position.offset(dx: radius, dy: radius),
            size: CGSize(width: CGFloat(radius * 2), height: CGFloat(radius * 2))))
        
        append(circle)
    }
}
